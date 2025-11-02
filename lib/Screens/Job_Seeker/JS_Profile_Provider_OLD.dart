import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileProvider extends ChangeNotifier {
  static final _auth = FirebaseAuth.instance;
  static final _firestore = FirebaseFirestore.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController skillController = TextEditingController();
  String _errorMessage = '';

  // Unified data structure for better management
  final Map<String, dynamic> _profile = {
    'personal': {
      'firstName': '',
      'lastName': '',
      'email': '',
      'phone': '',
      'location': '',
      'linkedIn': '',
      'current_job': '',
      'summary': ''
    },
    'education': <Map<String, String>>[],
    'experience': <Map<String, String>>[],
    'skills': <String>[],
    'certifications': <Map<String, String>>[],
  };

  // Temp fields for form inputs
  final Map<String, String> _tempFields = {
    'skill': '',
    'school': '',
    'degree': '',
    'fieldOfStudy': '',
    'eduStart': '',
    'eduEnd': '',
    'company': '',
    'role': '',
    'expStart': '',
    'expEnd': '',
    'expDescription': '',
    'certName': '',
    'certInstitution': '',
    'certYear': ''
  };

  // State management
  bool _isLoading = false;
  final Set<String> _dirtySections = {};

  // Batch operations optimization
  final Map<String, dynamic> _pendingUpdates = {};
  Timer? _debounceTimer;
  static const _debounceDelay = Duration(milliseconds: 500);

  ProfileProvider() {
    loadAllSectionsOnce();
  }

  @override void dispose() {
    skillController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  // Getters
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get firstName => _profile['personal']['firstName'];
  String get lastName => _profile['personal']['lastName'];
  String get email => _profile['personal']['email'];
  String get phone => _profile['personal']['phone'];
  String get location => _profile['personal']['location'];
  String get linkedIn => _profile['personal']['linkedIn'];
  String get current_job => _profile['personal']['current_job'];
  String get summary => _profile['personal']['summary'];
  List<Map<String, String>> get educationList => _profile['education'];
  List<Map<String, String>> get experienceList => _profile['experience'];
  List<String> get skillsList => _profile['skills'];
  List<Map<String, String>> get certificationsList => _profile['certifications'];

  // Updated temp-field getters with fallback
  String get tempSkill => skillController.text.trim();
  String get tempSchool => _tempFields['school']!.isNotEmpty
      ? _tempFields['school']!
      : (educationList.isNotEmpty ? educationList.first['school']! : '');
  String get tempDegree => _tempFields['degree']!.isNotEmpty
      ? _tempFields['degree']!
      : (educationList.isNotEmpty ? educationList.first['degree']! : '');
  String get tempFieldOfStudy => _tempFields['fieldOfStudy']!.isNotEmpty
      ? _tempFields['fieldOfStudy']!
      : (educationList.isNotEmpty ? educationList.first['fieldOfStudy']! : '');
  String get tempEduStart => _tempFields['eduStart']!.isNotEmpty
      ? _tempFields['eduStart']!
      : (educationList.isNotEmpty ? educationList.first['eduStart']! : '');
  String get tempEduEnd => _tempFields['eduEnd']!.isNotEmpty
      ? _tempFields['eduEnd']!
      : (educationList.isNotEmpty ? educationList.first['eduEnd']! : '');
  String get tempCompany => _tempFields['company']!.isNotEmpty
      ? _tempFields['company']!
      : (experienceList.isNotEmpty ? experienceList.first['company']! : '');
  String get tempRole => _tempFields['role']!.isNotEmpty
      ? _tempFields['role']!
      : (experienceList.isNotEmpty ? experienceList.first['role']! : '');
  String get tempExpStart => _tempFields['expStart']!.isNotEmpty
      ? _tempFields['expStart']!
      : (experienceList.isNotEmpty ? experienceList.first['expStart']! : '');
  String get tempExpEnd => _tempFields['expEnd']!.isNotEmpty
      ? _tempFields['expEnd']!
      : (experienceList.isNotEmpty ? experienceList.first['expEnd']! : '');
  String get tempExpDescription => _tempFields['expDescription']!.isNotEmpty
      ? _tempFields['expDescription']!
      : (experienceList.isNotEmpty ? experienceList.first['expDescription']! : '');
  String get tempCertName => _tempFields['certName']!.isNotEmpty
      ? _tempFields['certName']!
      : (certificationsList.isNotEmpty ? certificationsList.first['certName']! : '');
  String get tempCertInstitution => _tempFields['certInstitution']!.isNotEmpty
      ? _tempFields['certInstitution']!
      : (certificationsList.isNotEmpty ? certificationsList.first['certInstitution']! : '');
  String get tempCertYear => _tempFields['certYear']!.isNotEmpty
      ? _tempFields['certYear']!
      : (certificationsList.isNotEmpty ? certificationsList.first['certYear']! : '');

  DocumentReference<Map<String, dynamic>> get _docRef => _firestore
      .collection('Job_Seeker')
      .doc(_auth.currentUser!.uid)
      .collection('user_profile')
      .doc('sections');

  Future<void> forceReload() async {
    _errorMessage = '';
    await loadAllSectionsOnce();
  }

  Future<void> loadAllSectionsOnce() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      late DocumentSnapshot<Map<String, dynamic>> snapshot;
      try {
        snapshot = await _docRef.get(const GetOptions(source: Source.cache));
      } catch (_) {
        snapshot = await _docRef.get(const GetOptions(source: Source.server));
      }

      if (snapshot.exists && snapshot.data() != null) {
        _parseProfileData(snapshot.data()!);
      } else {
        await _createDefaultProfile();
      }
    } catch (e) {
      _errorMessage = 'Failed to load profile: \$e';
      if (e.toString().contains('not found') ||
          e.toString().contains('does not exist')) {
        try {
          await _createDefaultProfile();
        } catch (_) {}
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _createDefaultProfile() async {
    final defaultData = {
      'personal': {
        'firstName': '',
        'lastName': '',
        'email': _auth.currentUser?.email ?? '',
        'phone': '',
        'location': '',
        'linkedIn': '',
        'current_job': '',
        'summary': '',
      },
      'education': [],
      'experience': [],
      'certifications': [],
      'skills': [],
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    await _docRef.set(defaultData, SetOptions(merge: true));
    _parseProfileData(defaultData);
  }

  void _parseProfileData(Map<String, dynamic> data) {
    if (data['personal'] is Map) {
      _profile['personal'] = Map<String, String>.from(
          (data['personal'] as Map).map((k, v) => MapEntry(k.toString(), v?.toString() ?? '')));
    }
    for (final key in ['education', 'experience', 'certifications']) {
      if (data[key] is List) {
        _profile[key] = (data[key] as List)
            .whereType<Map>()
            .map((item) => item
            .map((k, v) => MapEntry(k.toString(), v?.toString() ?? '')))
            .toList();
      }
    }
    if (data['skills'] is List) {
      _profile['skills'] = (data['skills'] as List).whereType<String>().toList();
    }
  }

  void _markDirty(String section) {
    _dirtySections.add(section);
    notifyListeners();
  }

  void _scheduleBatchUpdate(String section, Map<String, dynamic> data) {
    _pendingUpdates[section] = data;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDelay, _executeBatchUpdate);
  }

  Future<void> _executeBatchUpdate() async {
    if (_pendingUpdates.isEmpty) return;
    try {
      await _docRef.set(_pendingUpdates, SetOptions(merge: true));
      _pendingUpdates.clear();
    } catch (_) {}
  }

  Color getButtonColorForSection(String section) =>
      _dirtySections.contains(section) ? Colors.red : const Color(0xFF003366);

  Future<void> _flashButtonGreen(String section) async {
    _dirtySections.remove(section);
    notifyListeners();
    await Future.delayed(const Duration(seconds: 1));
    notifyListeners();
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  // Personal updates
  void _updatePersonalField(String field, String value) {
    final trimmed = value.trim();
    if (_profile['personal'][field] != trimmed) {
      _profile['personal'][field] = trimmed;
      _markDirty('personal');
      _scheduleBatchUpdate('personal', _profile['personal']);
    }
  }
  void updateFirstName(String val) => _updatePersonalField('firstName', val);
  void updateLastName(String val) => _updatePersonalField('lastName', val);
  void updateEmail(String val) => _updatePersonalField('email', val);
  void updatePhone(String val) => _updatePersonalField('phone', val);
  void updateLocation(String val) => _updatePersonalField('location', val);
  void updateLinkedIn(String val) => _updatePersonalField('linkedIn', val);
  void updatecurrent_job(String val) => _updatePersonalField('current_job', val);
  void updateSummary(String val) => _updatePersonalField('summary', val);

  // Temp updates
  void updateTempField(String field, String value) => _tempFields[field] = value;
  void updateTempSchool(String val) => updateTempField('school', val);
  void updateTempDegree(String val) => updateTempField('degree', val);
  void updateTempFieldOfStudy(String val) => updateTempField('fieldOfStudy', val);
  void updateTempEduStart(String val) => updateTempField('eduStart', val);
  void updateTempEduEnd(String val) => updateTempField('eduEnd', val);
  void updateTempCompany(String val) => updateTempField('company', val);
  void updateTempRole(String val) => updateTempField('role', val);
  void updateTempExpStart(String val) => updateTempField('expStart', val);
  void updateTempExpEnd(String val) => updateTempField('expEnd', val);
  void updateTempExpDescription(String val) => updateTempField('expDescription', val);
  void updateTempCertName(String val) => updateTempField('certName', val);
  void updateTempCertInstitution(String val) => updateTempField('certInstitution', val);
  void updateTempCertYear(String val) => updateTempField('certYear', val);

  // Legacy marks
  void markPersonalDirty() => _markDirty('personal');
  void markEducationDirty() => _markDirty('education');
  void markExperienceDirty() => _markDirty('experience');
  void markSkillsDirty() => _markDirty('skills');
  void markCertificationsDirty() => _markDirty('certifications');

  // Save helpers
  Future<void> _saveSection(BuildContext context, String section) async {
    try {
      await _docRef.set({section: _profile[section]}, SetOptions(merge: true));
      notifyListeners();
    } catch (e) {
      _showSnackBar(context, 'Error saving \$section section', Colors.red);
    }
  }

  Future<void> savePersonalSection(BuildContext context) async {
    await _saveSection(context, 'personal');
    await _flashButtonGreen('personal');
    _showSnackBar(context, 'Personal section saved', Colors.green);
  }

  Future<void> addEducationEntry(BuildContext context) async {
    final fields = ['school', 'degree', 'eduStart', 'eduEnd'];
    if (fields.any((f) => _tempFields[f]!.trim().isEmpty)) return;
    final newEntry = {
      'school': _tempFields['school']!.trim(),
      'degree': _tempFields['degree']!.trim(),
      'fieldOfStudy': _tempFields['fieldOfStudy']!.trim(),
      'eduStart': _tempFields['eduStart']!.trim(),
      'eduEnd': _tempFields['eduEnd']!.trim(),
    };
    _profile['education'].add(newEntry);
    for (var f in ['school','degree','fieldOfStudy','eduStart','eduEnd']) {
      _tempFields[f] = '';
    }
    _markDirty('education');
    await saveEducationSection(context);
  }

  Future<void> addExperienceEntry(BuildContext context) async {
    final fields = ['company', 'role', 'expStart', 'expDescription'];
    if (fields.any((f) => _tempFields[f]!.trim().isEmpty)) return;
    final newEntry = {
      'company': _tempFields['company']!.trim(),
      'role': _tempFields['role']!.trim(),
      'expStart': _tempFields['expStart']!.trim(),
      'expEnd': _tempFields['expEnd']!.trim(),
      'expDescription': _tempFields['expDescription']!.trim(),
    };
    _profile['experience'].add(newEntry);
    for (var f in ['company','role','expStart','expEnd','expDescription']) {
      _tempFields[f] = ''; }
    _markDirty('experience');
    await saveExperienceSection(context);
  }

  Future<void> addSkillEntry(BuildContext context) async {
    final skill = skillController.text.trim();
    if (skill.isEmpty) { _showSnackBar(context, 'Skill cannot be empty', Colors.red); return; }
    if (_profile['skills'].contains(skill)) { _showSnackBar(context, 'Skill already added', Colors.orange); return; }
    _profile['skills'].add(skill);
    skillController.clear();
    _markDirty('skills');
    notifyListeners();
    await saveSkillsSection(context);
  }

  Future<void> addCertificationEntry(BuildContext context) async {
    final fields = ['certName', 'certInstitution'];
    if (fields.any((f) => _tempFields[f]!.trim().isEmpty)) return;
    final newEntry = {
      'certName': _tempFields['certName']!.trim(),
      'certInstitution': _tempFields['certInstitution']!.trim(),
      'certYear': _tempFields['certYear']!.trim(),
    };
    _profile['certifications'].add(newEntry);
    for (var f in ['certName','certInstitution','certYear']) { _tempFields[f] = ''; }
    _markDirty('certifications');
    await saveCertificationsSection(context);
  }

  Future<void> saveEducationSection(BuildContext context) async {
    await _saveSection(context, 'education');
    await _flashButtonGreen('education');
    _showSnackBar(context, 'Education section finalized', Colors.green);
  }

  Future<void> saveExperienceSection(BuildContext context) async {
    await _saveSection(context, 'experience');
    await _flashButtonGreen('experience');
    _showSnackBar(context, 'Experience section finalized', Colors.green);
  }

  Future<void> saveSkillsSection(BuildContext context) async {
    if (_profile['skills'].isEmpty) { _showSnackBar(context, 'At least one skill is required', Colors.red); return; }
    await _saveSection(context, 'skills');
    await _flashButtonGreen('skills');
    _showSnackBar(context, 'Skills section finalized', Colors.green);
  }

  Future<void> saveCertificationsSection(BuildContext context) async {
    await _saveSection(context, 'certifications');
    await _flashButtonGreen('certifications');
    _showSnackBar(context, 'Certifications section finalized', Colors.green);
  }
}
