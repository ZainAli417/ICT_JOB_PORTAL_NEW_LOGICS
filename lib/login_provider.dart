// lib/providers/login_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:go_router/go_router.dart';

class LoginProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  bool _isLoading = false;
  String? _errorMessage;
  User? _currentUser;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _currentUser;
  bool get isSignedIn => _currentUser != null;

  set _loading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void initAuthStateListener() {
    _auth.authStateChanges().listen((User? user) {
      _currentUser = user;
      notifyListeners();
    });
  }

  String _normalizeRole(String r) {
    return r.replaceAll(RegExp(r'[_\s\-]'), '').toLowerCase();
  }

  Future<String?> _findUidForEmailAndRole(String email, String expectedRole) async {
    try {
      final normalizedEmail = email.trim().toLowerCase();
      final normExpected = _normalizeRole(expectedRole);

      final usersQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: normalizedEmail)
          .get();

      if (usersQuery.docs.isEmpty) return null;

      for (final userDoc in usersQuery.docs) {
        final data = userDoc.data();
        if (data == null) continue;
        final roleField = (data['role'] ?? '').toString();
        if (_normalizeRole(roleField) == normExpected) {
          final snapshotRecruiter = await _firestore
              .collection('recruiter')
              .where('user_data.email', isEqualTo: normalizedEmail)
              .limit(1)
              .get();
          if (snapshotRecruiter.docs.isNotEmpty) {
            return snapshotRecruiter.docs.first.id;
          }

          final snapshotJobSeeker = await _firestore
              .collection('job_seeker')
              .where('user_data.email', isEqualTo: normalizedEmail)
              .limit(1)
              .get();
          if (snapshotJobSeeker.docs.isNotEmpty) {
            return snapshotJobSeeker.docs.first.id;
          }

          return null;
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error finding uid by email & role: $e');
      return null;
    }
  }

  Future<bool> login({
    required BuildContext context,
    required String email,
    required String password,
    required String expectedRole,
  }) async {
    debugPrint('LOGIN: started -> email="$email", expectedRole="$expectedRole"');
    if (email.trim().isEmpty || password.trim().isEmpty) {
      _setError('Email and password cannot be empty');
      debugPrint('LOGIN: validation failed - empty email/password');
      return false;
    }

    _loading = true;
    clearError();
    debugPrint('LOGIN: beginning lookup for uid by email & role');

    try {
      final foundUid = await _findUidForEmailAndRole(email.trim(), expectedRole);
      debugPrint('LOGIN: _findUidForEmailAndRole returned uid="$foundUid"');
      if (foundUid == null) {
        _setError('No account found for this email as "$expectedRole". Please register or choose the correct role.');
        debugPrint('LOGIN: no uid found for email and role -> aborting');
        return false;
      }

      debugPrint('LOGIN: attempting FirebaseAuth signInWithEmailAndPassword for "$email"');
      final UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final User? user = cred.user;
      debugPrint('LOGIN: signInWithEmailAndPassword returned user=${user?.uid}');
      if (user == null) {
        _setError('Authentication failed');
        await _auth.signOut();
        debugPrint('LOGIN: auth returned null user -> aborting');
        return false;
      }

      if (user.uid != foundUid) {
        await _auth.signOut();
        _setError('Account mismatch. Please use the account registered for this email or reset your password.');
        debugPrint('LOGIN: uid mismatch -> auth uid="${user.uid}" vs foundUid="$foundUid" -> aborting');
        return false;
      }

      debugPrint('LOGIN: verifying role for uid="${user.uid}" against expectedRole="$expectedRole"');
      final roleVerified = await _verifyUserRole(user.uid, expectedRole, email: email.trim());
      debugPrint('LOGIN: _verifyUserRole returned $roleVerified');
      if (!roleVerified) {
        await _auth.signOut();
        _setError('This account is not registered as "$expectedRole".');
        debugPrint('LOGIN: role verification failed -> aborting');
        return false;
      }

      debugPrint('LOGIN: updating last login timestamp for uid="${user.uid}"');
      await updateLastLogin();

      _currentUser = user;
      notifyListeners();

      final norm = _normalizeRole(expectedRole);
      if (norm.contains('recruiter')) {
        debugPrint('LOGIN: navigation -> /recruiter-dashboard');
        GoRouter.of(context).go('/recruiter-dashboard');
      } else {
        debugPrint('LOGIN: navigation -> /dashboard');
        GoRouter.of(context).go('/dashboard');
      }

      debugPrint('LOGIN: completed successfully for uid="${user.uid}"');
      return true;
    } on FirebaseAuthException catch (e) {
      await _handleAuthException(e);
      debugPrint('LOGIN: FirebaseAuthException: ${e.code} - ${e.message}');
      return false;
    } catch (e, st) {
      _setError('Unexpected error occurred. Please try again.');
      debugPrint('LOGIN: Unexpected exception: $e\n$st');
      return false;
    } finally {
      _loading = false;
      debugPrint('LOGIN: finished (loading=false)');
    }
  }

  Future<bool> _verifyUserRole(String uid, String expectedRole, {String? email}) async {
    debugPrint('VERIFY_ROLE: start -> uid="$uid", expectedRole="$expectedRole", email="$email"');
    try {
      final normExpected = _normalizeRole(expectedRole);
      final normalizedEmailArg = email?.trim().toLowerCase();

      try {
        final recruiterDocRef = _firestore.collection('recruiter').doc(uid);
        final recruiterSnap = await recruiterDocRef.get();
        if (recruiterSnap.exists) {
          final data = recruiterSnap.data() as Map<String, dynamic>?;
          final roleField = (data?['user_data']?['role'] ?? '').toString();
          final emailField = (data?['user_data']?['email'] ?? '').toString().trim().toLowerCase();
          final roleMatches = _normalizeRole(roleField) == normExpected;
          final emailMatches = normalizedEmailArg == null ? true : (emailField == normalizedEmailArg);
          debugPrint('VERIFY_ROLE: recruiter -> role="$roleField", email="$emailField", roleMatches=$roleMatches, emailMatches=$emailMatches');
          if (roleMatches && emailMatches) {
            debugPrint('VERIFY_ROLE: matched on recruiter collection');
            return true;
          }
        }
      } catch (e) {
        debugPrint('VERIFY_ROLE: error checking recruiter collection: $e');
      }

      try {
        final jobDocRef = _firestore.collection('job_seeker').doc(uid);
        final jobSnap = await jobDocRef.get();
        if (jobSnap.exists) {
          final data = jobSnap.data() as Map<String, dynamic>?;
          final roleField = (data?['user_data']?['role'] ?? '').toString();
          final emailField = (data?['user_data']?['email'] ?? '').toString().trim().toLowerCase();
          final roleMatches = _normalizeRole(roleField) == normExpected;
          final emailMatches = normalizedEmailArg == null ? true : (emailField == normalizedEmailArg);
          debugPrint('VERIFY_ROLE: job_seeker -> role="$roleField", email="$emailField", roleMatches=$roleMatches, emailMatches=$emailMatches');
          if (roleMatches && emailMatches) {
            debugPrint('VERIFY_ROLE: matched on job_seeker collection');
            return true;
          }
        }
      } catch (e) {
        debugPrint('VERIFY_ROLE: error checking job_seeker collection: $e');
      }

      debugPrint('VERIFY_ROLE: no match found for uid="$uid" with expectedRole="$expectedRole"');
      return false;
    } catch (e) {
      debugPrint('VERIFY_ROLE: unexpected error: $e');
      return false;
    }
  }

  Future<void> _handleAuthException(FirebaseAuthException e) async {
    switch (e.code) {
      case 'user-not-found':
        _setError('No account found with this email. Please register first.');
        break;
      case 'wrong-password':
        _setError('Incorrect password. Please try again.');
        break;
      case 'invalid-email':
        _setError('Invalid email format.');
        break;
      case 'user-disabled':
        _setError('This account has been disabled.');
        break;
      case 'too-many-requests':
        _setError('Too many failed attempts. Please try again later.');
        break;
      case 'network-request-failed':
        _setError('Network error. Please check your connection.');
        break;
      default:
        _setError(e.message ?? 'Authentication failed. Please try again.');
    }
  }

  Future<bool> signInWithGoogle() async {
    _loading = true;
    clearError();
    try {
      await _googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return false;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;
      if (user == null) {
        _setError('Google sign-in failed. Please try again.');
        return false;
      }
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        try {
          final baseUserData = <String, dynamic>{
            'uid': user.uid,
            'name': user.displayName ?? '',
            'email': user.email ?? '',
            'picture_url': user.photoURL ?? '',
            'role': 'Job_Seeker',
            'created_at': FieldValue.serverTimestamp(),
            'lastLoginAt': FieldValue.serverTimestamp(),
            'loginMethod': 'google',
            'paid': false,
            'active': false,
          };
          final userDataDocRef = _firestore.collection('job_seeker').doc(user.uid).collection('user_data').doc('user_data');
          await userDataDocRef.set(baseUserData, SetOptions(merge: true));
          final profileDocRef = _firestore.collection('job_seeker').doc(user.uid).collection('user_profile').doc('user_profile');
          await profileDocRef.set({'last_updated': FieldValue.serverTimestamp()}, SetOptions(merge: true));
        } catch (e) {
          debugPrint('Failed to create job_seeker docs after Google sign-in: $e');
        }
      }
      _currentUser = user;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      await _handleAuthException(e);
      return false;
    } catch (e) {
      _setError('Google sign-in failed. Please try again.');
      debugPrint('Google sign-in error: $e');
      return false;
    } finally {
      _loading = false;
    }
  }

  Future<void> updateLastLogin() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;
      final jobRef = _firestore.collection('job_seeker').doc(uid).collection('user_data').doc('user_data');
      final jobSnap = await jobRef.get();
      if (jobSnap.exists) {
        await jobRef.update({'lastLoginAt': FieldValue.serverTimestamp()});
        return;
      }
      final recRef = _firestore.collection('recruiter').doc(uid).collection('user_data').doc('user_data');
      final recSnap = await recRef.get();
      if (recSnap.exists) {
        await recRef.update({'lastLoginAt': FieldValue.serverTimestamp()});
        return;
      }
    } catch (e) {
      debugPrint('Error updating last login: $e');
    }
  }

  Future<void> signOut() async {
    _loading = true;
    clearError();
    try {
      await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      _setError('Error signing out. Please try again.');
      debugPrint('Sign out error: $e');
    } finally {
      _loading = false;
    }
  }

  Future<bool> resetPassword(String email) async {
    if (email.trim().isEmpty) {
      _setError('Please enter your email address');
      return false;
    }
    _loading = true;
    clearError();
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return true;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          _setError('No account found with this email');
          break;
        case 'invalid-email':
          _setError('Invalid email format');
          break;
        default:
          _setError(e.message ?? 'Error sending reset email');
      }
      return false;
    } catch (e) {
      _setError('Unexpected error occurred');
      debugPrint('Password reset error: $e');
      return false;
    } finally {
      _loading = false;
    }
  }

  Future<void> checkCurrentUser() async {
    _currentUser = _auth.currentUser;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
