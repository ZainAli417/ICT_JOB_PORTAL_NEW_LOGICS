// JS_TopNavProvider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Fetches the current user’s full name from Firestore, then exposes
/// the first two letters as `initials`.
class JS_TopNavProvider extends ChangeNotifier {
  String _initials = '';
  String get initials => _initials;

  JS_TopNavProvider() {
    _fetchInitials();
  }

  Future<void> _fetchInitials() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final uid = user.uid;

      final doc = await FirebaseFirestore.instance
          .collection('Job_Seeker')
          .doc(uid)
          .get();

      if (doc.exists) {
        final data = doc.data();
        if (data != null && data['name'] is String) {
          final fullName = (data['name'] as String).trim();
          if (fullName.isNotEmpty) {
            final letters = fullName.replaceAll(' ', '');
            _initials = letters.substring(0, letters.length >= 2 ? 2 : 1)
                .toUpperCase();
            notifyListeners();
          }
        }
      }
    } catch (e) {
      // If anything fails, leave initials as empty string
      _initials = '';
      notifyListeners();
    }
  }
}
