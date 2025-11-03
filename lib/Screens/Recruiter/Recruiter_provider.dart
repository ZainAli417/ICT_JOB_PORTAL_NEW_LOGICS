// recruiter_dashboard_provider.dart
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Candidate {
  final String uid;
  final String email;
  final String name;
  final String phone;
  final String nationality;
  final String pictureUrl;
  Map<String, dynamic>? profile;

  Candidate({
    required this.uid,
    required this.email,
    required this.name,
    required this.phone,
    required this.nationality,
    required this.pictureUrl,
    this.profile,
  });

  factory Candidate.fromUserDataDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    String uid = doc.reference.parent.parent?.id ?? doc.id;
    return Candidate(
      uid: uid,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      phone: data['phone number'] ?? data['phone'] ?? '',
      nationality: data['nationality'] ?? '',
      pictureUrl: data['picture_url'] ?? data['pictureUrl'] ?? data['picture'] ?? '',
    );
  }

  factory Candidate.fromMap(Map<String, dynamic> data, String uid) {
    return Candidate(
      uid: uid,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      phone: data['phone number'] ?? data['phone'] ?? '',
      nationality: data['nationality'] ?? '',
      pictureUrl: data['picture_url'] ?? data['pictureUrl'] ?? data['picture'] ?? '',
      profile: data,
    );
  }

  // Helper for safe comparison
  String get nameLower => name.toLowerCase().trim();
}

class RecruiterProvider2 extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Core data
  List<Candidate> _candidates = [];
  List<Candidate> get candidates => _candidates;

  List<Candidate> _filtered = [];
  List<Candidate> get filtered => _filtered;

  // State management
  bool loading = false;
  bool _isDisposed = false;
  String searchQuery = '';

  // Filter options (dynamically populated)
  Set<String> nationalityOptions = {};

  // Filter selections
  String? selectedNationality;
  String sortOption = 'None'; // 'None', 'Name A→Z', 'Name Z→A'

  // Selected candidates for batch operations
  final Set<String> selectedUids = {};

  // Cache for profiles to avoid redundant fetches
  final Map<String, Map<String, dynamic>> _profileCache = {};

  StreamSubscription<QuerySnapshot>? _subscription;

  RecruiterProvider2() {
    _init();
  }

  Future<void> _init() async {
    final user = _auth.currentUser;
    if (user == null) {
      debugPrint('❌ No authenticated user found');
      return;
    }
    debugPrint('✅ Initializing RecruiterProvider for user: ${user.email}');
    await subscribeCandidates();
  }

  /// Optimized: Loads all candidates in a single query with better error handling
  Future<void> subscribeCandidates() async {
    if (_isDisposed) return;

    loading = true;
    _safeNotify();

    try {
      debugPrint('📥 Fetching candidates from Firestore...');
      final snap = await _firestore
          .collection('job_seeker')
          .get(const GetOptions(source: Source.serverAndCache));

      final List<Candidate> list = [];
      int validCount = 0;
      int skippedCount = 0;

      for (final doc in snap.docs) {
        try {
          final d = doc.data();

          // Priority 1: Check for user_data map
          if (d.containsKey('user_data') && d['user_data'] is Map<String, dynamic>) {
            final userData = d['user_data'] as Map<String, dynamic>;
            if (_isValidCandidateData(userData)) {
              list.add(Candidate.fromMap(userData, doc.id));
              validCount++;
              continue;
            }
          }

          // Priority 2: Check root level data
          if (_isValidCandidateData(d)) {
            list.add(Candidate.fromMap(d, doc.id));
            validCount++;
            continue;
          }

          skippedCount++;
        } catch (e) {
          debugPrint('⚠️ Error parsing candidate ${doc.id}: $e');
          skippedCount++;
        }
      }

      _candidates = list;
      debugPrint('✅ Loaded $validCount candidates (skipped $skippedCount invalid entries)');
    } catch (e) {
      debugPrint('❌ subscribeCandidates error: $e');
      _candidates = [];
    }

    _populateOptions();
    _applyFilter();
    loading = false;
    _safeNotify();
  }

  /// Validates if candidate data has minimum required fields
  bool _isValidCandidateData(Map<String, dynamic> data) {
    return data.containsKey('email') ||
        data.containsKey('name') ||
        data.containsKey('phone') ||
        data.containsKey('phone number');
  }

  /// Extracts unique filter options from loaded candidates
  void _populateOptions() {
    nationalityOptions = _candidates
        .map((c) => c.nationality.trim())
        .where((s) => s.isNotEmpty)
        .toSet();

    debugPrint('📊 Found ${nationalityOptions.length} unique nationalities');
  }

  /// Updates search query and reapplies filters
  void setSearch(String q) {
    searchQuery = q.trim();
    debugPrint('🔍 Search query: "$searchQuery"');
    _applyFilter();
    _safeNotify();
  }

  /// Updates nationality filter
  void setNationalityFilter(String? nat) {
    selectedNationality = nat;
    debugPrint('🌍 Nationality filter: ${nat ?? "All"}');
    _applyFilter();
    _safeNotify();
  }

  /// Updates sort option - FIXED for proper A→Z and Z→A sorting
  void setSortOption(String opt) {
    sortOption = opt;
    debugPrint('🔄 Sort option: $opt');
    _applyFilter();
    _safeNotify();
  }

  /// Core filtering and sorting logic - OPTIMIZED
  void _applyFilter() {
    List<Candidate> tmp = List.from(_candidates);
    int originalCount = tmp.length;

    // STEP 1: Apply search filter
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      tmp = tmp.where((c) {
        final searchableText = '${c.name} ${c.email} ${c.phone} ${c.nationality}'.toLowerCase();
        return searchableText.contains(q);
      }).toList();
      debugPrint('🔍 Search filtered: ${tmp.length}/$originalCount candidates');
    }

    // STEP 2: Apply nationality filter
    if (selectedNationality != null && selectedNationality!.isNotEmpty) {
      tmp = tmp.where((c) =>
      c.nationality.trim().toLowerCase() == selectedNationality!.trim().toLowerCase()
      ).toList();
      debugPrint('🌍 Nationality filtered: ${tmp.length} candidates');
    }

    // STEP 3: Apply sorting - FIXED IMPLEMENTATION
    if (sortOption == 'Name A→Z') {
      tmp.sort((a, b) {
        final nameA = a.nameLower;
        final nameB = b.nameLower;
        return nameA.compareTo(nameB);
      });
      debugPrint('📊 Sorted A→Z: ${tmp.take(3).map((c) => c.name).join(", ")}...');
    } else if (sortOption == 'Name Z→A') {
      tmp.sort((a, b) {
        final nameA = a.nameLower;
        final nameB = b.nameLower;
        return nameB.compareTo(nameA);
      });
      debugPrint('📊 Sorted Z→A: ${tmp.take(3).map((c) => c.name).join(", ")}...');
    }

    _filtered = tmp;
    debugPrint('✅ Final filtered list: ${_filtered.length} candidates');
  }

  /// Optimized profile fetching with caching
  Future<Map<String, dynamic>?> fetchProfile(String uid) async {
    // Return cached profile if available
    if (_profileCache.containsKey(uid)) {
      debugPrint('💾 Using cached profile for $uid');
      return _profileCache[uid];
    }

    try {
      debugPrint('📥 Fetching profile for candidate: $uid');

      // Strategy 1: Check parent document for user_profile map
      final parentSnap = await _firestore
          .collection('job_seeker')
          .doc(uid)
          .get(const GetOptions(source: Source.serverAndCache));

      if (!parentSnap.exists) {
        debugPrint('⚠️ Candidate document not found: $uid');
        return null;
      }

      final parentData = parentSnap.data() ?? {};

      // Check for user_profile in parent document
      if (parentData.containsKey('user_profile') &&
          parentData['user_profile'] is Map<String, dynamic>) {
        final profile = Map<String, dynamic>.from(parentData['user_profile'] as Map);
        _cacheProfile(uid, profile);
        debugPrint('✅ Profile loaded from parent doc for $uid');
        return profile;
      }

      // Strategy 2: Check subcollection (legacy structure)
      final subDocSnap = await _firestore
          .doc('job_seeker/$uid/user_profile/profile')
          .get(const GetOptions(source: Source.serverAndCache));

      if (subDocSnap.exists) {
        final profile = subDocSnap.data() as Map<String, dynamic>;
        _cacheProfile(uid, profile);
        debugPrint('✅ Profile loaded from subcollection for $uid');
        return profile;
      }

      debugPrint('⚠️ No profile found for $uid');
      return null;
    } catch (e) {
      debugPrint('❌ fetchProfile error for $uid: $e');
      return null;
    }
  }

  /// Cache profile and update candidate object
  void _cacheProfile(String uid, Map<String, dynamic> profile) {
    _profileCache[uid] = profile;
    final idx = _candidates.indexWhere((c) => c.uid == uid);
    if (idx != -1) {
      _candidates[idx].profile = profile;
      _safeNotify();
    }
  }

  /// Toggle candidate selection for batch operations
  void toggleSelection(String uid, {bool? value}) {
    if (value == true) {
      selectedUids.add(uid);
    } else if (value == false) {
      selectedUids.remove(uid);
    } else {
      if (selectedUids.contains(uid)) {
        selectedUids.remove(uid);
      } else {
        selectedUids.add(uid);
      }
    }
    debugPrint('✅ Selected: ${selectedUids.length} candidates');
    _safeNotify();
  }

  /// Clear all selections
  void clearSelection() {
    selectedUids.clear();
    debugPrint('🧹 Cleared all selections');
    _safeNotify();
  }

  /// Extract CV URL from profile with multiple fallback keys
  String? _extractCvUrlFromProfile(Map<String, dynamic>? profile) {
    if (profile == null) return null;

    // Primary keys to check
    const cvKeys = [
      'Cv/Resume', 'cv', 'cv_url', 'resume', 'resume_url',
      'cvLink', 'resumeLink', 'cv_link', 'resume_link',
      'cvUrl', 'resumeUrl', 'CV', 'Resume'
    ];

    for (final key in cvKeys) {
      if (profile.containsKey(key) &&
          profile[key] is String &&
          (profile[key] as String).isNotEmpty) {
        return profile[key] as String;
      }
    }

    // Check nested documents object
    if (profile['documents'] is Map<String, dynamic>) {
      final docs = profile['documents'] as Map<String, dynamic>;
      for (final key in cvKeys) {
        if (docs.containsKey(key) &&
            docs[key] is String &&
            (docs[key] as String).isNotEmpty) {
          return docs[key] as String;
        }
      }
    }

    return null;
  }

  Future<String?> sendSelectedCandidatesToAdmin({String? notes}) async {
    if (selectedUids.isEmpty) {
      debugPrint('⚠️ No candidates selected');
      return null;
    }

    final recruiter = _auth.currentUser;
    if (recruiter == null) {
      debugPrint('❌ No authenticated recruiter');
      return null;
    }

    final recruiterId = recruiter.uid;
    final recruiterEmail = recruiter.email ?? '';

    // Resolve selected candidate objects from loaded candidates
    final selected = _candidates.where((c) => selectedUids.contains(c.uid)).toList();
    if (selected.isEmpty) {
      debugPrint('⚠️ Selected UIDs not found in candidates list');
      return null;
    }

    debugPrint('📤 Preparing to send ${selected.length} candidates to admin');

    // Prepare candidate metadata and ids
    final List<String> candidateIds = [];
    final List<Map<String, dynamic>> candidateMaps = [];

    for (final c in selected) {
      try {
        // Ensure we have latest profile for CV extraction (fetch if missing)
        Map<String, dynamic>? profile = c.profile;
        profile ??= await fetchProfile(c.uid);

        final cvUrl = _extractCvUrlFromProfile(profile) ?? '';

        candidateIds.add(c.uid);
        candidateMaps.add(<String, dynamic>{
          'name': c.name,
          'email': c.email,
          'phone': c.phone,
          'nationality': c.nationality,
          'picture_url': c.pictureUrl,
          'cv_url': cvUrl,
        });
      } catch (e) {
        debugPrint('⚠️ Error preparing candidate ${c.uid}: $e');
      }
    }

    if (candidateIds.isEmpty) {
      debugPrint('⚠️ No candidate data prepared after processing');
      return null;
    }

    try {
      final now = FieldValue.serverTimestamp();

      // -> CREATE A TOP-LEVEL REQUEST DOC (auto ID) (NOT nested under recruiterId)
      final requestsCol = _firestore.collection('recruiter_requests');
      final requestDoc = requestsCol.doc(); // auto id

      final requestData = <String, dynamic>{
        'request_id': requestDoc.id,
        'recruiter_id': recruiterId,
        'recruiter_email': recruiterEmail,
        'created_at': now,
        'notes': (notes ?? '').trim(),
        'total_candidates': candidateIds.length,
        'status': 'pending', // pending / reviewed / accepted / rejected
        // store candidate ids for quick reference and indexing
        'candidate_ids': candidateIds,
        // optional: store a lightweight snapshot of candidate metadata (avoid very large payloads)
        'candidates': candidateMaps,
      };

      // Single write is enough here; use a batch if you plan additional writes atomically
      await requestDoc.set(requestData);

      debugPrint('✅ Request created at recruiter_requests/${requestDoc.id}');

      // Clear selection after successful commit
      clearSelection();

      return requestDoc.id;
    } catch (e) {
      debugPrint('❌ sendSelectedCandidatesToAdmin error: $e');
      return null;
    }
  }
  /// Refresh candidates data
  Future<void> refresh() async {
    debugPrint('🔄 Refreshing candidates...');
    _profileCache.clear();
    await subscribeCandidates();
  }

  /// Safe notify that checks disposal state
  void _safeNotify() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _subscription?.cancel();
    _profileCache.clear();
    debugPrint('🧹 RecruiterProvider disposed');
    super.dispose();
  }
}