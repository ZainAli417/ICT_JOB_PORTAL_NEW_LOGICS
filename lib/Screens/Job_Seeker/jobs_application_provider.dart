// lib/providers/job_applications_provider.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class JobApplicationsProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isApplying = false;
  String? _errorMessage;
  final Set<String> _appliedJobs = {};

  bool get isApplying => _isApplying;
  String? get errorMessage => _errorMessage;
  bool hasApplied(String jobId) => _appliedJobs.contains(jobId);
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Load all job IDs the current user has applied to.
  Future<void> loadAppliedJobs() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final userApps = await _firestore
          .collection('applications')
          .doc(user.uid)
          .collection('applied_jobs')
          .get();

      _appliedJobs
        ..clear()
        ..addAll(userApps.docs.map((doc) => doc.data()['jobId'] as String));
      notifyListeners();
    } catch (e) {
      // optionally set an error field here
      debugPrint('loadAppliedJobs error: $e');
    }
  }

  /// Apply to [jobId], take a snapshot of the seeker profile,
  /// and atomically increment both counters.

  Future<void> applyForJob(String jobId) async {
    final user = _auth.currentUser;
    if (user == null) {
      _errorMessage = 'You must be logged in to apply.';
      notifyListeners();
      return;
    }

    // 1️⃣ Local guard
    if (hasApplied(jobId)) {
      _errorMessage = 'You have already applied to this job.';
      notifyListeners();
      return;
    }

    // 2️⃣ Server‑side guard in case local state is stale
    final appliedRef = _firestore
        .collection('applications')
        .doc(user.uid)
        .collection('applied_jobs');
    final existing = await appliedRef
        .where('jobId', isEqualTo: jobId)
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) {
      _errorMessage = 'You have already applied to this job.';
      notifyListeners();
      return;
    }

    // 3️⃣ Begin apply flow
    _isApplying = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // ─── Fetch seeker profile ───────────────────────────────────────
      final seekerRef = _firestore.collection('Job_Seeker').doc(user.uid);
      final seekerSnap = await seekerRef.get();
      if (!seekerSnap.exists) {
        throw Exception('Seeker profile not found.');
      }
      final mainData = seekerSnap.data()!;

      final sectionsSnap = await seekerRef
          .collection('user_profile')
          .doc('sections')
          .get();
      final subProfiles = sectionsSnap.exists
          ? sectionsSnap.data()!
          : <String, dynamic>{};

      // ─── Prepare payload ───────────────────────────────────────────
      final applicationData = {
        'userId': user.uid,
        'jobId': jobId,
        'appliedAt': FieldValue.serverTimestamp(),
        'status': 'pending',
        'profileSnapshot': {
          'user_Account_Data': mainData,
          'user_Profile_Sections': subProfiles,
        },
      };

      // ─── Batch write: new application + increment counters ─────────
      final batch = _firestore.batch();
      final newAppRef = appliedRef.doc();
      batch.set(newAppRef, applicationData);

      final jobRef =
      _firestore.collection('Posted_jobs_public').doc(jobId);
      batch.update(jobRef, {
        'applicationCount': FieldValue.increment(1),
        'viewCount': FieldValue.increment(1),
      });

      await batch.commit();

      // ─── Mark locally so UI updates immediately ───────────────────
      _appliedJobs.add(jobId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isApplying = false;
      notifyListeners();
    }
  }


}
