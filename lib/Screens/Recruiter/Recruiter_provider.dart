// recruiter_dashbaord_provider.dart
import 'dart:async';
import 'dart:convert';

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
      pictureUrl: data['picture url'] ?? data['pictureUrl'] ?? data['picture'] ?? '',
    );
  }

  factory Candidate.fromMap(Map<String, dynamic> data, String uid) {
    return Candidate(
      uid: uid,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      phone: data['phone number'] ?? data['phone'] ?? '',
      nationality: data['nationality'] ?? '',
      pictureUrl: data['picture url'] ?? data['pictureUrl'] ?? data['picture'] ?? '',
      profile: data,
    );
  }
}

class RecruiterProvider2 extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Candidate> _candidates = [];
  List<Candidate> get candidates => _candidates;

  List<Candidate> _filtered = [];
  List<Candidate> get filtered => _filtered;

  bool loading = false;
  String searchQuery = '';

  // dynamic filter options
  Set<String> nationalityOptions = {};

  // filter selections
  String? selectedNationality;
  String sortOption = 'None'; // 'None', 'Name A→Z', 'Name Z→A'

  // selections
  final Set<String> selectedUids = {};

  StreamSubscription<QuerySnapshot>? _subscription;

  RecruiterProvider2() {
    _init();
  }

  Future<void> _init() async {
    final user = _auth.currentUser;
    if (user == null) return;
    await subscribeCandidates();
  }

  // Compact loader: reads job_seeker/{uid} and extracts user_data map
  Future<void> subscribeCandidates() async {
    loading = true;
    notifyListeners();
    try {
      final snap = await _firestore.collection('job_seeker').get();
      final List<Candidate> list = [];
      for (final doc in snap.docs) {
        final d = doc.data() as Map<String, dynamic>? ?? {};
        if (d.containsKey('user_data') && d['user_data'] is Map<String, dynamic>) {
          list.add(Candidate.fromMap(d['user_data'] as Map<String, dynamic>, doc.id));
          continue;
        }
        if (d.containsKey('email') || d.containsKey('name')) {
          list.add(Candidate.fromMap(d, doc.id));
          continue;
        }
      }
      _candidates = list;
    } catch (e) {
      debugPrint('subscribeCandidates error: $e');
      _candidates = [];
    }
    _populateOptions();
    _applyFilter();
    loading = false;
    notifyListeners();
  }

  void _populateOptions() {
    nationalityOptions = _candidates.map((c) => c.nationality).where((s) => s.isNotEmpty).toSet();
  }

  void setSearch(String q) {
    searchQuery = q.trim();
    _applyFilter();
    notifyListeners();
  }

  void setNationalityFilter(String? nat) {
    selectedNationality = nat;
    _applyFilter();
    notifyListeners();
  }

  void setSortOption(String opt) {
    sortOption = opt;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    // start with full list
    List<Candidate> tmp = List.from(_candidates);

    // search
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      tmp = tmp.where((c) {
        final fields = '${c.name} ${c.email} ${c.phone} ${c.nationality}'.toLowerCase();
        return fields.contains(q);
      }).toList();
    }

    // nationality filter
    if (selectedNationality != null && selectedNationality!.isNotEmpty) {
      tmp = tmp.where((c) => (c.nationality.toLowerCase() == selectedNationality!.toLowerCase())).toList();
    }

    // sorting
    if (sortOption == 'Name A→Z') {
      tmp.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    } else if (sortOption == 'Name Z→A') {
      tmp.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
    }

    _filtered = tmp;
  }

  Future<Map<String, dynamic>?> fetchProfile(String uid) async {
    try {
      final parentSnap = await _firestore.collection('job_seeker').doc(uid).get();
      if (!parentSnap.exists) return null;
      final parentData = parentSnap.data() as Map<String, dynamic>? ?? {};

      if (parentData.containsKey('user_profile') && parentData['user_profile'] is Map<String, dynamic>) {
        final profile = Map<String, dynamic>.from(parentData['user_profile'] as Map);
        final idx = _candidates.indexWhere((c) => c.uid == uid);
        if (idx != -1) _candidates[idx].profile = profile;
        notifyListeners();
        return profile;
      }

      final docSnap = await _firestore.doc('job_seeker/$uid/user_profile').get();
      if (docSnap.exists) {
        final profile = docSnap.data() as Map<String, dynamic>;
        final idx = _candidates.indexWhere((c) => c.uid == uid);
        if (idx != -1) _candidates[idx].profile = profile;
        notifyListeners();
        return profile;
      }

      return null;
    } catch (e) {
      debugPrint('fetchProfile error for $uid: $e');
      return null;
    }
  }

  void toggleSelection(String uid, {bool? value}) {
    if (value == true) selectedUids.add(uid);
    else if (value == false) selectedUids.remove(uid);
    else {
      if (selectedUids.contains(uid)) selectedUids.remove(uid);
      else selectedUids.add(uid);
    }
    notifyListeners();
  }

  void clearSelection() {
    selectedUids.clear();
    notifyListeners();
  }

  String? _extractCvUrlFromProfile(Map<String, dynamic>? profile) {
    if (profile == null) return null;
    final keys = ['cv', 'cv_url', 'resume', 'resume_url', 'cvLink', 'resumeLink', 'cv_link', 'resume_link', 'cvUrl', 'resumeUrl'];
    for (final k in keys) {
      if (profile.containsKey(k) && profile[k] is String && (profile[k] as String).isNotEmpty) {
        return profile[k] as String;
      }
    }
    if (profile['documents'] is Map<String, dynamic>) {
      final docs = profile['documents'] as Map<String, dynamic>;
      for (final k in ['cv', 'resume', 'cv_url', 'resume_url']) {
        if (docs.containsKey(k) && docs[k] is String && (docs[k] as String).isNotEmpty) return docs[k] as String;
      }
    }
    return null;
  }

  Future<String?> sendSelectedCandidatesToAdmin({String? notes}) async {
    if (selectedUids.isEmpty) return null;

    final recruiter = _auth.currentUser;
    final recruiterId = recruiter?.uid ?? 'unknown';
    final recruiterEmail = recruiter?.email ?? '';

    final selected = _candidates.where((c) => selectedUids.contains(c.uid)).toList();
    if (selected.isEmpty) return null;

    final now = FieldValue.serverTimestamp();

    final candidateMaps = selected.map((c) {
      final cv = _extractCvUrlFromProfile(c.profile) ?? '';
      return <String, dynamic>{
        'uid': c.uid,
        'name': c.name,
        'email': c.email,
        'phone': c.phone,
        'nationality': c.nationality,
        'picture_url': c.pictureUrl,
        'cv_url': cv,
      };
    }).toList();

    try {
      final requestsRoot = _firestore.collection('Admin').doc('Recruiter_Requests').collection('requests');
      final requestDoc = requestsRoot.doc();
      final batch = _firestore.batch();

      final requestData = {
        'request_id': requestDoc.id,
        'recruiter_id': recruiterId,
        'recruiter_email': recruiterEmail,
        'created_at': now,
        'notes': notes ?? '',
        'total_candidates': candidateMaps.length,
        'candidates': candidateMaps,
      };
      batch.set(requestDoc, requestData);

      final candidatesCol = requestDoc.collection('candidates');
      for (final cm in candidateMaps) {
        final candDoc = candidatesCol.doc(cm['uid'] as String? ?? _firestore.collection('x').doc().id);
        batch.set(candDoc, {
          ...cm,
          'request_id': requestDoc.id,
          'added_at': now,
        });
      }

      await batch.commit();
      clearSelection();
      return requestDoc.id;
    } catch (e) {
      debugPrint('sendSelectedCandidatesToAdmin error: $e');
      return null;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}