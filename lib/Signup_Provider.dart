import 'dart:convert';
import 'dart:typed_data';
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class SignUpProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  bool isLoading = false;
  String? errorMessage;
  double uploadProgress = 0.0;

  static const int _batchSize = 500;
  static const Duration _timeout = Duration(seconds: 30);
  static const int _maxRetries = 3;

  void _setLoading(bool v) {
    isLoading = v;
    notifyListeners();
  }

  void _setUploadProgress(double progress) {
    uploadProgress = progress;
    notifyListeners();
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  Future<String?> _uploadImageDataUrl(String uid, String imageDataUrl) async {
    try {
      if (imageDataUrl.isEmpty) return null;
      final uriSplit = imageDataUrl.split(',');
      if (uriSplit.isEmpty) return null;
      final base64Str = uriSplit.length == 2 ? uriSplit[1] : imageDataUrl;
      final bytes = base64Decode(base64Str);
      const maxSize = 2 * 1024 * 1024;
      if (bytes.length > maxSize) {
        errorMessage = 'Image size exceeds 2MB limit';
        return null;
      }
      final ext = _detectImageExtensionFromDataUrl(imageDataUrl) ?? 'jpg';
      final mimeType = _getMimeType(ext);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final ref = _storage.ref().child('profile_images/$uid/$timestamp.$ext');
      final metadata = SettableMetadata(
        contentType: mimeType,
        customMetadata: {
          'uploadedBy': uid,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
        cacheControl: 'public, max-age=31536000',
      );
      final uploadTask = ref.putData(Uint8List.fromList(bytes), metadata);
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        _setUploadProgress(progress);
      });
      final snapshot = await uploadTask.timeout(
        _timeout,
        onTimeout: () => throw TimeoutException('Image upload timed out'),
      );
      final url = await snapshot.ref.getDownloadURL();
      _setUploadProgress(0.0);
      return url;
    } on FirebaseException catch (e) {
      debugPrint('Firebase Storage error: ${e.code} - ${e.message}');
      errorMessage = _handleStorageError(e);
      return null;
    } on TimeoutException catch (e) {
      debugPrint('Upload timeout: $e');
      errorMessage = 'Upload timed out. Please try again.';
      return null;
    } catch (e) {
      debugPrint('Image upload failed: $e');
      errorMessage = 'Failed to upload image';
      return null;
    }
  }

  String? _detectImageExtensionFromDataUrl(String dataUrl) {
    try {
      if (dataUrl.startsWith('data:image/')) {
        final rest = dataUrl.substring('data:image/'.length);
        final ext = rest.split(';').first.toLowerCase();
        if (['jpg', 'jpeg', 'png', 'webp', 'gif'].contains(ext)) {
          return ext;
        }
      }
    } catch (_) {}
    return null;
  }

  String _getMimeType(String ext) {
    final mimeTypes = {
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
      'webp': 'image/webp',
      'gif': 'image/gif',
    };
    return mimeTypes[ext.toLowerCase()] ?? 'image/jpeg';
  }

  String _handleStorageError(FirebaseException e) {
    switch (e.code) {
      case 'unauthorized':
        return 'You do not have permission to upload images';
      case 'canceled':
        return 'Upload was canceled';
      case 'unknown':
        return 'An unknown error occurred during upload';
      case 'object-not-found':
        return 'File not found';
      case 'bucket-not-found':
        return 'Storage bucket not found';
      case 'project-not-found':
        return 'Project not found';
      case 'quota-exceeded':
        return 'Storage quota exceeded';
      case 'unauthenticated':
        return 'User not authenticated';
      case 'invalid-checksum':
        return 'File upload failed verification';
      case 'retry-limit-exceeded':
        return 'Maximum retry limit exceeded';
      default:
        return e.message ?? 'Upload failed';
    }
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  bool _isValidPhone(String phone) {
    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]{7,}$');
    return phoneRegex.hasMatch(phone);
  }

  String _sanitizeInput(String input) {
    return input.trim().replaceAll(RegExp(r'[<>]'), '');
  }

  Future<bool> registerAndSaveAll(
      BuildContext context, {
        required String email,
        required String password,
        required String role,
        required Map<String, dynamic> userData,
        required Map<String, dynamic> profileData,
      }) async {
    _setLoading(true);
    errorMessage = null;
    _setUploadProgress(0.0);
    UserCredential? cred;
    String? uid;
    try {
      final sanitizedEmail = _sanitizeInput(email.toLowerCase());
      final sanitizedRole = _sanitizeInput(role);
      if (!_isValidEmail(sanitizedEmail)) {
        throw Exception('Invalid email format');
      }
      if (password.length < 6) {
        throw Exception('Password must be at least 6 characters');
      }
      if (!['Job Seeker', 'Recruiter'].contains(sanitizedRole)) {
        throw Exception('Invalid role selected');
      }
      final name = _sanitizeInput(userData['name'] ?? '');
      if (name.isEmpty) {
        throw Exception('Name is required');
      }
      final phone = _sanitizeInput(userData['phone'] ?? '');
      if (phone.isNotEmpty && !_isValidPhone(phone)) {
        throw Exception('Invalid phone number format');
      }
      try {
        cred = await _auth.createUserWithEmailAndPassword(
          email: sanitizedEmail,
          password: password,
        ).timeout(_timeout);
        uid = cred.user!.uid;
        await cred.user!.updateDisplayName(name);
      } on FirebaseAuthException catch (e) {
        throw Exception(_handleAuthError(e));
      }
      String? photoUrl;
      final imageDataUrl = profileData['image_data_url'] as String?;
      if (imageDataUrl != null && imageDataUrl.isNotEmpty) {
        photoUrl = await _uploadImageDataUrl(uid, imageDataUrl);
      }
      final now = FieldValue.serverTimestamp();
      final createdAtString = DateTime.now().toUtc().toIso8601String();
      final baseUserData = <String, dynamic>{
        'email': sanitizedEmail,
        'name': name,
        'phone': phone,
        'nationality': _sanitizeInput(userData['nationality'] ?? ''),
        'role': sanitizedRole,
        'picture_url': photoUrl ?? '',
        'created_at': now,
        'created_at_string': createdAtString,
        'uid': uid,
        'psid': userData['psid'],
        'ispaid': false,
        'active': false,
        'updated_at': now,
      };
      final isRecruiter = sanitizedRole.toLowerCase().contains('recruiter');
      final collection = isRecruiter ? 'recruiter' : 'job_seeker';
      final docRef = _firestore.collection(collection).doc(uid);
      if (isRecruiter) {
        try {
          await docRef.set({
            'user_data': baseUserData,
            'user_profile': <String, dynamic>{
              'picture_url': photoUrl ?? '',
              'last_updated': now,
            },
          }, SetOptions(merge: false));
        } catch (e) {
          debugPrint('Failed to write recruiter doc: $e');
          try {
            await cred?.user?.delete();
            debugPrint('Rolled back auth user due to Firestore failure');
          } catch (delErr) {
            debugPrint('Failed to delete auth user after Firestore failure: $delErr');
          }
          throw Exception('Failed to save recruiter data. Please try again.');
        }
        try {
          await _firestore.collection('users').add({
            'name': name,
            'uid':uid,
            'email': sanitizedEmail,
            'role': sanitizedRole,
            'created_at': now,
          });
        } catch (e) {
          debugPrint('Failed to write shadow user doc (recruiter): $e');
        }
      } else {
        final profilePayload = <String, dynamic>{
          'dob': userData['dob'],
          'father_name': _sanitizeInput(userData['father_name'] ?? ''),
          'educations': _sanitizeList(profileData['educations'] ?? []),
          'experiences': _sanitizeList(profileData['experiences'] ?? []),
          'skills': _sanitizeStringList(profileData['skills'] ?? []),
          'certifications': _sanitizeStringList(profileData['certifications'] ?? []),
          'references': _sanitizeStringList(profileData['references'] ?? []),
          'misc': _sanitizeStringList(profileData['misc'] ?? []),
          'picture_url': photoUrl ?? '',
          'last_updated': now,
          'profile_completion': _calculateProfileCompletion(profileData),
        };
        try {
          await docRef.set({
            'user_data': baseUserData,
            'user_profile': profilePayload,
          }, SetOptions(merge: false));
        } catch (e) {
          debugPrint('Failed to write job_seeker doc: $e');
          try {
            await cred?.user?.delete();
            debugPrint('Rolled back auth user due to Firestore failure');
          } catch (delErr) {
            debugPrint('Failed to delete auth user after Firestore failure: $delErr');
          }
          throw Exception('Failed to save job seeker data. Please try again.');
        }
        try {
          await _firestore
              .collection('user_activity')
              .doc(uid)
              .collection('logs')
              .add({
            'action': 'registration',
            'timestamp': now,
            'role': sanitizedRole,
            'ip_address': null,
          });
        } catch (e) {
          debugPrint('Failed to write activity log: $e');
        }
        try {
          await _firestore.collection('users').add({
            'name': name,
            'email': sanitizedEmail,
            'role': sanitizedRole,
            'created_at': now,
          });
        } catch (e) {
          debugPrint('Failed to write shadow user doc (job_seeker): $e');
        }
      }
      try {
        await cred?.user?.sendEmailVerification();
      } catch (e) {
        debugPrint('Email verification failed: $e');
      }
      _setLoading(false);
      _setUploadProgress(0.0);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Registration successful! Please verify your email.',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
          ),
        );
      }
      return true;
    } on FirebaseAuthException catch (e) {
      errorMessage = _handleAuthError(e);
      debugPrint('Auth error: ${e.code} - ${e.message}');
      _setLoading(false);
      _showErrorSnackbar(context, errorMessage!);
      return false;
    } on FirebaseException catch (e) {
      errorMessage = _handleFirestoreError(e);
      debugPrint('Firestore error: ${e.code} - ${e.message}');
      _setLoading(false);
      _showErrorSnackbar(context, errorMessage!);
      return false;
    } on TimeoutException catch (e) {
      errorMessage = 'Operation timed out. Please check your connection.';
      debugPrint('Timeout: $e');
      _setLoading(false);
      _showErrorSnackbar(context, errorMessage!);
      return false;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      debugPrint('Registration error: $e');
      _setLoading(false);
      _showErrorSnackbar(context, errorMessage!);
      return false;
    }
  }

  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already registered';
      case 'invalid-email':
        return 'Invalid email address';
      case 'operation-not-allowed':
        return 'Operation not allowed';
      case 'weak-password':
        return 'Password is too weak';
      case 'network-request-failed':
        return 'Network error. Please check your connection';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      default:
        return e.message ?? 'Authentication error occurred';
    }
  }

  String _handleFirestoreError(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return 'Permission denied. Please try again';
      case 'unavailable':
        return 'Service unavailable. Please try again';
      case 'deadline-exceeded':
        return 'Request timeout. Please try again';
      case 'already-exists':
        return 'Record already exists';
      case 'resource-exhausted':
        return 'Too many requests. Please try later';
      case 'cancelled':
        return 'Operation was cancelled';
      case 'data-loss':
        return 'Data error occurred';
      case 'unauthenticated':
        return 'Authentication required';
      case 'invalid-argument':
        return 'Invalid data provided';
      default:
        return e.message ?? 'Database error occurred';
    }
  }

  List<Map<String, String>> _sanitizeList(List<dynamic> list) {
    return list.map((item) {
      if (item is Map) {
        return item.map((key, value) => MapEntry(
          key.toString(),
          _sanitizeInput(value?.toString() ?? ''),
        ));
      }
      return <String, String>{};
    }).toList();
  }

  List<String> _sanitizeStringList(List<dynamic> list) {
    return list
        .map((item) => _sanitizeInput(item?.toString() ?? ''))
        .where((item) => item.isNotEmpty)
        .toList();
  }

  int _calculateProfileCompletion(Map<String, dynamic> profileData) {
    int completed = 0;
    int total = 7;
    if ((profileData['educations'] as List?)?.isNotEmpty ?? false) completed++;
    if ((profileData['experiences'] as List?)?.isNotEmpty ?? false) completed++;
    if ((profileData['skills'] as List?)?.isNotEmpty ?? false) completed++;
    if ((profileData['certifications'] as List?)?.isNotEmpty ?? false) completed++;
    if ((profileData['references'] as List?)?.isNotEmpty ?? false) completed++;
    if (profileData['image_data_url'] != null) completed++;
    if (profileData['dob'] != null) completed++;
    return ((completed / total) * 100).round();
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  Future<void> setPaymentStatus({
    required String uid,
    required bool paid,
  }) async {
    int retries = 0;
    while (retries < _maxRetries) {
      try {
        final userDoc = _firestore.collection('job_seeker').doc(uid);
        await _firestore.runTransaction((transaction) async {
          final snapshot = await transaction.get(userDoc);
          if (!snapshot.exists) {
            throw Exception('User document not found');
          }
          transaction.update(userDoc, {
            'user_data.paid': paid,
            'user_data.active': paid,
            'user_data.payment_verified_at': paid ? FieldValue.serverTimestamp() : null,
            'user_data.updated_at': FieldValue.serverTimestamp(),
          });
        }).timeout(_timeout);
        await _firestore
            .collection('user_activity')
            .doc(uid)
            .collection('logs')
            .add({
          'action': 'payment_${paid ? 'verified' : 'revoked'}',
          'timestamp': FieldValue.serverTimestamp(),
          'amount': null,
        });
        return;
      } catch (e) {
        retries++;
        if (retries >= _maxRetries) {
          debugPrint('Failed to update payment status after $retries attempts: $e');
          rethrow;
        }
        await Future.delayed(Duration(milliseconds: 100 * (2 ^ retries)));
      }
    }
  }

  Future<void> cleanupUnverifiedAccounts({int daysOld = 7000}) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
      final snapshot = await _firestore
          .collection('job_seeker')
          .where('user_data.email_verified', isEqualTo: false)
          .where('user_data.created_at_string', isLessThan: cutoffDate.toIso8601String())
          .limit(_batchSize)
          .get()
          .timeout(_timeout);
      if (snapshot.docs.isEmpty) return;
      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      debugPrint('Cleaned up ${snapshot.docs.length} unverified accounts');
    } catch (e) {
      debugPrint('Cleanup failed: $e');
    }
  }
}
