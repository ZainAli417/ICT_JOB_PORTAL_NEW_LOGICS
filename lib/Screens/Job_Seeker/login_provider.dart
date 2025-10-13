// lib/providers/login_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  bool _isLoading = false;
  String? _errorMessage;
  User? _currentUser;

  // getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _currentUser;
  bool get isSignedIn => _currentUser != null;

  // private setter for loading state
  set _loading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// Initialize auth state listener (call this once from app startup if desired)
  void initAuthStateListener() {
    _auth.authStateChanges().listen((User? user) {
      _currentUser = user;
      notifyListeners();
    });
  }

  /// Normalize role strings for comparison (remove underscores, lowercase).
  String _normalizeRole(String r) {
    return r.replaceAll(RegExp(r'[_\s\-]'), '').toLowerCase();
  }

  /// Find UID by email and expected role using collectionGroup on 'user_data'.
  /// Returns the UID if a matching document is found, otherwise null.
  Future<String?> _findUidForEmailAndRole(String email, String expectedRole) async {
    try {
      final normExpected = _normalizeRole(expectedRole);

      // Query all subcollections named 'user_data' for the given email.
      final q = await _firestore
          .collectionGroup('user_data')
          .where('email', isEqualTo: email)
          .get();

      if (q.docs.isEmpty) return null;

      // Look for a doc whose 'role' field matches expectedRole (normalized)
      for (final doc in q.docs) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data == null) continue;
        final roleField = (data['role'] ?? '').toString();
        if (_normalizeRole(roleField) == normExpected) {
          // doc.reference points to: /<collectionParent>/{uid}/user_data/{docId}
          // doc.reference.parent -> 'user_data' collection
          // doc.reference.parent.parent -> the user document (job_seeker/{uid})
          final parent = doc.reference.parent.parent;
          if (parent != null) return parent.id;
          // Fallback: sometimes the doc might be at job_seeker/{uid} directly
          if (doc.reference.parent.parent == null) {
            // try to find uid by retrieving parent path segments
            final segments = doc.reference.path.split('/');
            // path like "job_seeker/{uid}/user_data/{user_data}"
            if (segments.length >= 2) return segments[1];
          }
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error finding uid by email & role: $e');
      return null;
    }
  }

  /// Main login flow:
  /// 1) quick Firestore check: does this email exist for the expectedRole?
  /// 2) If yes, sign-in with Firebase Auth.
  /// 3) Verify that the signed-in uid matches the Firestore UID we found.
  Future<bool> login({
    required String email,
    required String password,
    required String expectedRole,
  }) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      _setError('Email and password cannot be empty');
      return false;
    }

    _loading = true;
    clearError();

    try {
      // 0) Lookup uid by email & role to avoid wrong-role logins
      final foundUid = await _findUidForEmailAndRole(email.trim(), expectedRole);
      if (foundUid == null) {
        _setError('No account found for this email as "$expectedRole". Please register or choose the correct role.');
        return false;
      }

      // 1) Authenticate with Firebase Auth
      final UserCredential cred = await _auth.signInWithEmailAndPassword(email: email.trim(), password: password);
      final User? user = cred.user;
      if (user == null) {
        _setError('Authentication failed');
        return false;
      }

      // 2) Make sure the auth uid matches the Firestore uid we discovered
      if (user.uid != foundUid) {
        // This means the email is registered (in user_data) under another uid,
        // but the credentials used signed into a different auth account.
        await _auth.signOut();
        _setError('Account mismatch. Please use the account registered for this email or reset your password.');
        return false;
      }

      // Optionally re-verify role from the exact path (defensive)
      final roleVerified = await _verifyUserRole(user.uid, expectedRole);
      if (!roleVerified) {
        await _auth.signOut();
        _setError('This account is not registered as "$expectedRole".');
        return false;
      }

      _currentUser = user;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      await _handleAuthException(e);
      return false;
    } catch (e) {
      _setError('Unexpected error occurred. Please try again.');
      debugPrint('Login error: $e');
      return false;
    } finally {
      _loading = false;
    }
  }

  /// Verify user role from the specific nested path you use:
  /// job_seeker/{uid}/user_data/user_data  OR recruiter/{uid}/user_data/user_data
  Future<bool> _verifyUserRole(String uid, String expectedRole) async {
    try {
      final normExpected = _normalizeRole(expectedRole);

      // Job seeker path
      final jobDocRef = _firestore.collection('job_seeker').doc(uid).collection('user_data').doc('user_data');
      final jobSnap = await jobDocRef.get();
      if (jobSnap.exists) {
        final data = jobSnap.data();
        final roleField = (data?['role'] ?? '').toString();
        final emailField = (data?['email'] ?? '').toString();
        if (_normalizeRole(roleField) == normExpected) return true;
      }

      // Recruiter path
      final recDocRef = _firestore.collection('recruiter').doc(uid).collection('user_data').doc('user_data');
      final recSnap = await recDocRef.get();
      if (recSnap.exists) {
        final data = recSnap.data();
        final roleField = (data?['role'] ?? '').toString();
        if (_normalizeRole(roleField) == normExpected) return true;
      }

      return false;
    } catch (e) {
      debugPrint('Role verification error: $e');
      return false;
    }
  }

  /// Handle FirebaseAuth exceptions and set friendly messages
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

  /// Google Sign-In: creates a nested user_data doc under job_seeker/{uid}/user_data/user_data
  Future<bool> signInWithGoogle() async {
    _loading = true;
    clearError();

    try {
      await _googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // cancelled
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

      // if newly created user, create the nested user_data doc under job_seeker/{uid}/user_data/user_data
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

          // write nested doc exactly where your signup code expects it
          final userDataDocRef = _firestore.collection('job_seeker').doc(user.uid).collection('user_data').doc('user_data');
          await userDataDocRef.set(baseUserData, SetOptions(merge: true));

          // optionally create an empty profile doc for consistency
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

  /// Update last login timestamp in the nested user_data doc
  Future<void> updateLastLogin() async {
    if (_currentUser == null) return;
    try {
      final uid = _currentUser!.uid;

      // Try job_seeker path first
      final jobRef = _firestore.collection('job_seeker').doc(uid).collection('user_data').doc('user_data');
      final jobSnap = await jobRef.get();
      if (jobSnap.exists) {
        await jobRef.update({'lastLoginAt': FieldValue.serverTimestamp()});
        return;
      }

      // Try recruiter path
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

  /// Sign out
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

  /// Reset password
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

  /// Check current user
  Future<void> checkCurrentUser() async {
    _currentUser = _auth.currentUser;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
