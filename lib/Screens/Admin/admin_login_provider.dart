import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class AdminAuthProvider extends ChangeNotifier {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;

  // Toggle for password visibility
  bool obscurePassword = true;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void toggleObscure() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  // Basic validation
  String? validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Please enter an email';
    final email = v.trim();
    final re = RegExp(r'^[\w\-.]+@([\w\-]+\.)+[\w\-]{2,4}$');
    if (!re.hasMatch(email)) return 'Enter a valid email';
    return null;
  }

  String? validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Please enter a password';
    if (v.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  // Check if signed-in user is an admin by checking Firestore collection 'admins'
  Future<bool> _checkIsAdmin(String uid) async {
    try {
      final doc = await _firestore.collection('Admin').doc(uid).get();
      return doc.exists;
    } catch (e) {
      // Firestore read failed: treat as not admin (caller will handle messaging)
      // ignore: avoid_print
      print('Admin check error: $e');
      return false;
    }
  }

  /// Attempts sign-in; returns true on success (and verified admin).
  /// Caller can navigate after this completes.
  Future<bool> signIn() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    // local validation
    final emailError = validateEmail(email);
    final passError = validatePassword(password);
    if (emailError != null || passError != null) {
      errorMessage = emailError ?? passError;
      notifyListeners();
      return false;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
      final user = cred.user;
      if (user == null) {
        errorMessage = 'Authentication failed.';
        return false;
      }

      final uid = user.uid;
      final isAdmin = await _checkIsAdmin(uid);
      if (!isAdmin) {
        // sign out immediately and raise friendly message
        await _auth.signOut();
        errorMessage = 'This account does not have admin privileges.';
        return false;
      }

      // success
      errorMessage = null;
      return true;
    } on FirebaseAuthException catch (ex) {
      // friendly messages for common codes
      switch (ex.code) {
        case 'user-not-found':
          errorMessage = 'No account found for this email.';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password.';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address.';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled.';
          break;
        default:
          errorMessage = ex.message ?? 'Authentication failed.';
      }
      return false;
    } catch (e) {
      errorMessage = 'An unexpected error occurred.';
      // ignore: avoid_print
      print('Sign-in error: $e');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
