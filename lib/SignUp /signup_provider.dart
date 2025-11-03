// lib/providers/signup_provider.dart
import 'dart:convert';
import 'dart:typed_data';
import 'dart:html' as html;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../extractor_CV/cv_extractor.dart';

class SignupProvider extends ChangeNotifier {
  // ========== STATE ==========
  String role = 'job_seeker';
  int personalVisibleIndex = 0;
  int currentStep = 0;
  bool showCvUploadSection = false;
  bool isLoading = false;

  // ========== CONTROLLERS ==========
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final nameController = TextEditingController();
  final contactNumberController = TextEditingController();
  final nationalityController = TextEditingController();
  final summaryController = TextEditingController();
  final objectivesController = TextEditingController();
  final skillInputController = TextEditingController();
  final socialInputController = TextEditingController();

  // ========== DATA ==========
  final skills = <String>[];
  final socialLinks = <String>[];
  final educationalProfile = <Map<String, dynamic>>[];
  DateTime? dob;
  Uint8List? profilePicBytes;
  String? imageDataUrl;
  String? profilePicUrl;
  String? secondaryEmail;

  // ========== ERRORS ==========
  String? emailError;
  String? passwordError;
  String? generalError;

  final _picker = ImagePicker();

  // ========== ROLE & NAVIGATION ==========
  void setRole(String newRole) {
    if (!['job_seeker', 'recruiter'].contains(newRole)) return;
    role = newRole;
    if (newRole == 'recruiter') showCvUploadSection = false;
    notifyListeners();
  }

  void revealCvUpload({bool reveal = true}) {
    showCvUploadSection = reveal;
    notifyListeners();
  }

  void goToStep(int step) {
    currentStep = step;
    if (step == 1 && personalVisibleIndex == 0) personalVisibleIndex = 0;
    notifyListeners();
  }

  void revealNextPersonalField() => _updatePersonalIndex(personalVisibleIndex + 1);
  void revealPreviousPersonalField() => _updatePersonalIndex(personalVisibleIndex - 1);

  void _updatePersonalIndex(int index) {
    if (index >= 0) {
      personalVisibleIndex = index;
      notifyListeners();
    }
  }

  void onFieldTypedAutoReveal(int index, String value) {
    if (value.trim().isNotEmpty && personalVisibleIndex == index) {
      revealNextPersonalField();
    }
  }

  void setDob(DateTime date) {
    dob = date;
    notifyListeners();
  }

  // ========== IMAGE HANDLING ==========
  Future<void> pickProfilePicture() async {
    try {
      if (kIsWeb) {
        final res = await _pickImageWeb();
        if (res == null) return;
        if (res.containsKey('error')) {
          generalError = res['error'] as String?;
          notifyListeners();
          return;
        }
        profilePicBytes = res['bytes'] as Uint8List?;
        imageDataUrl = res['dataUrl'] as String?;
      } else {
        final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
        if (picked == null) return;
        profilePicBytes = await picked.readAsBytes();
        imageDataUrl = 'data:${picked.mimeType ?? 'image/jpeg'};base64,${base64Encode(profilePicBytes!)}';
      }
      profilePicUrl = null;
      notifyListeners();
    } catch (e) {
      generalError = 'Failed to pick image: $e';
      notifyListeners();
    }
  }

  void removeProfilePicture() {
    profilePicBytes = null;
    imageDataUrl = null;
    profilePicUrl = null;
    notifyListeners();
  }

  Future<String?> _uploadProfilePic(String uid) async {
    if (profilePicBytes == null || profilePicBytes!.isEmpty) return null;
    try {
      final ref = FirebaseStorage.instance.ref('$role/$uid/profilePic.jpg');
      await ref.putData(profilePicBytes!, SettableMetadata(contentType: 'image/jpeg'));
      return await ref.getDownloadURL();
    } catch (_) {
      return null;
    }
  }

  // ========== SKILLS & SOCIAL LINKS ==========
  void addSkill(String raw) => _addToList(skills, raw);
  void removeSkillAt(int idx) => _removeFromList(skills, idx);
  void addSocialLink(String raw) => _addToList(socialLinks, raw);
  void removeSocialLinkAt(int idx) => _removeFromList(socialLinks, idx);

  void _addToList(List<String> list, String raw) {
    final v = raw.trim();
    if (v.isNotEmpty && !list.contains(v)) {
      list.add(v);
      notifyListeners();
    }
  }

  void _removeFromList(List<String> list, int idx) {
    if (idx >= 0 && idx < list.length) {
      list.removeAt(idx);
      notifyListeners();
    }
  }

  // ========== EDUCATION ==========
  void addEducation({
    required String institutionName,
    required String duration,
    required String majorSubjects,
    required String marksOrCgpa,
  }) {
    educationalProfile.add({
      'institutionName': institutionName.trim(),
      'duration': duration.trim(),
      'majorSubjects': majorSubjects.trim(),
      'marksOrCgpa': marksOrCgpa.trim(),
    });
    notifyListeners();
  }

  void updateEducation(int index, Map<String, dynamic> newEntry) {
    if (index >= 0 && index < educationalProfile.length) {
      educationalProfile[index] = newEntry;
      notifyListeners();
    }
  }

  void removeEducation(int index) {
    if (index >= 0 && index < educationalProfile.length) {
      educationalProfile.removeAt(index);
      notifyListeners();
    }
  }

  // ========== VALIDATION ==========
  bool validateEmail() {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      emailError = 'Email is required';
    } else if (!RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(email)) {
      emailError = 'Enter a valid email';
    } else {
      emailError = null;
    }
    notifyListeners();
    return emailError == null;
  }

  bool validatePasswords() {
    final p = passwordController.text;
    final cp = confirmPasswordController.text;

    if (p.isEmpty || cp.isEmpty) {
      passwordError = 'Password and confirm password are required';
    } else if (p.length < 8) {
      passwordError = 'Password must be at least 8 characters';
    } else if (p != cp) {
      passwordError = 'Passwords do not match';
    } else {
      passwordError = null;
    }
    notifyListeners();
    return passwordError == null;
  }

  bool validatePersonalFieldAtIndex(int index) {
    switch (index) {
      case 0: return nameController.text.trim().isNotEmpty;
      case 1: return _isValidPhone(contactNumberController.text.trim());
      case 2: return nationalityController.text.trim().isNotEmpty;
      case 3: return summaryController.text.trim().isNotEmpty;
      case 4: return skills.isNotEmpty;
      case 5: return objectivesController.text.trim().isNotEmpty;
      case 6: return dob != null;
      default: return false;
    }
  }

  bool _isValidPhone(String s) => s.isNotEmpty && RegExp(r'^[\d\+\-\s]{5,20}$').hasMatch(s);

  bool personalSectionIsComplete() {
    return [0, 1, 2, 3, 4, 5, 6].every((i) => validatePersonalFieldAtIndex(i));
  }

  bool educationSectionIsComplete() {
    if (educationalProfile.isEmpty) return false;
    return educationalProfile.every((e) =>
    _isNotEmpty(e['institutionName']) &&
        _isNotEmpty(e['duration']) &&
        _isNotEmpty(e['majorSubjects']) &&
        _isNotEmpty(e['marksOrCgpa'])
    );
  }

  bool _isNotEmpty(dynamic value) => (value as String?)?.trim().isNotEmpty ?? false;

  double computeProgress() {
    final personalDone = [0, 1, 2, 3, 4, 5, 6].where((i) => validatePersonalFieldAtIndex(i)).length;
    final educationDone = educationSectionIsComplete() ? 1 : 0;
    return (personalDone + educationDone) / 8;
  }

  // ========== FIREBASE OPERATIONS ==========
  Future<bool> registerRecruiter() async {
    return _executeWithLoading(() async {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      final uid = cred.user?.uid;
      if (uid == null) throw Exception('Failed to obtain user id');

      await _saveUserData(uid, _buildRecruiterData(uid));
      return true;
    });
  }

  Future<bool> submitAllAndCreateAccount() async {
    if (!_validateBeforeSubmit()) return false;

    return _executeWithLoading(() async {
      final uc = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      final uid = uc.user?.uid;
      if (uid == null) throw Exception('Unable to obtain user id');

      profilePicUrl = await _uploadProfilePic(uid);
      await _saveUserData(uid, _buildManualUserData(uid));
      return true;
    });
  }

  Future<bool> submitExtractedCvAndCreateAccount(
      CvExtractionResult result, {
        String? overrideEmail,
        String? overridePassword,
      }) async {
    return _executeWithLoading(() async {
      _populateFromCvResult(result);

      final authEmail = _determineAuthEmail(overrideEmail);
      final authPass = _determineAuthPassword(overridePassword);

      if (authEmail.isEmpty || authPass.isEmpty) {
        throw Exception('Email and password required to create account');
      }

      _updateControllersWithOverrides(overrideEmail, overridePassword);

      final uc = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: authEmail,
        password: authPass,
      );

      final uid = uc.user?.uid;
      if (uid == null) throw Exception('Unable to obtain user id');

      await _handleCvProfilePic(result.personalProfile);
      profilePicUrl = await _uploadProfilePic(uid);

      await _saveUserData(uid, _buildCvUserData(uid, result, authEmail));
      return true;
    });
  }

  // ========== PRIVATE HELPERS ==========
  Future<bool> _executeWithLoading(Future<bool> Function() operation) async {
    generalError = null;
    isLoading = true;
    notifyListeners();

    try {
      return await operation();
    } on FirebaseAuthException catch (e) {
      generalError = e.message ?? 'Authentication failed';
      return false;
    } catch (e) {
      generalError = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  bool _validateBeforeSubmit() {
    if (!validateEmail()) {
      generalError = emailError;
      notifyListeners();
      return false;
    }
    if (!validatePasswords()) {
      generalError = passwordError;
      notifyListeners();
      return false;
    }
    if (!personalSectionIsComplete()) {
      generalError = 'Please complete all required personal fields.';
      notifyListeners();
      return false;
    }
    if (!educationSectionIsComplete()) {
      generalError = 'Please add at least one education entry and fill all its fields.';
      notifyListeners();
      return false;
    }
    return true;
  }

  Future<void> _saveUserData(String uid, Map<String, dynamic> userData) async {
    final firestore = FirebaseFirestore.instance;

    // Save to role-based collection: {role}/{uid}/user_data
    await firestore.collection(role).doc(uid).set(
      {'user_data': userData},
      SetOptions(merge: true),
    );

    // Shadow copy to users collection
    try {
      await firestore.collection('users').add(_buildShadowData(uid, userData));
    } catch (_) {
      // Non-fatal: shadow copy is optional
    }
  }

  Map<String, dynamic> _buildRecruiterData(String uid) => {
    'uid': uid,
    'name': nameController.text.trim(),
    'email': emailController.text.trim(),
    'role': role,
    'createdAt': FieldValue.serverTimestamp(),
  };

  Map<String, dynamic> _buildManualUserData(String uid) => {
    'personalProfile': {
      'fullName': nameController.text.trim(),
      'email': emailController.text.trim(),
      'contactNumber': contactNumberController.text.trim(),
      'nationality': nationalityController.text.trim(),
      'summary': summaryController.text.trim(),
      'profilePicUrl': profilePicUrl,
      'skills': skills,
      'objectives': objectivesController.text.trim(),
      'socialLinks': socialLinks,
      'dob': dob != null ? DateFormat('yyyy-MM-dd').format(dob!) : null,
      'createdAt': FieldValue.serverTimestamp(),
    },
    'educationalProfile': educationalProfile,
  };

  Map<String, dynamic> _buildCvUserData(String uid, CvExtractionResult result, String authEmail) => {
    'personalProfile': {
      'name': nameController.text.trim(),
      'email': authEmail,
      'secondary_email': secondaryEmail ?? '',
      'contactNumber': contactNumberController.text.trim(),
      'nationality': nationalityController.text.trim(),
      'profilePicUrl': profilePicUrl,
      'skills': skills,
      'objectives': objectivesController.text.trim(),
      'socialLinks': socialLinks,
      'summary': summaryController.text.trim(),
      'dob': dob != null ? DateFormat('yyyy-MM-dd').format(dob!) : null,
    },
    'educationalProfile': educationalProfile,
    'professionalProfile': {'summary': result.professionalSummary ?? ''},
    'professionalExperience': result.experiences,
    'certifications': result.certifications,
    'publications': result.publications,
    'awards': result.awards,
    'references': result.references,
    'createdAt': FieldValue.serverTimestamp(),
  };

  Map<String, dynamic> _buildShadowData(String uid, Map<String, dynamic> userData) {
    final personalProfile = userData['personalProfile'] as Map<String, dynamic>?;
    return {
      'fullName': personalProfile?['name'] ?? personalProfile?['fullName'] ?? nameController.text.trim(),
      'email': personalProfile?['email'] ?? emailController.text.trim(),
      'secondary_email': personalProfile?['secondary_email'] ?? secondaryEmail ?? '',
      'uid': uid,
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  void _populateFromCvResult(CvExtractionResult result) {
    final personal = result.personalProfile;

    nameController.text = _getStringValue(personal['name'], nameController.text);
    contactNumberController.text = _getStringValue(personal['contactNumber'], contactNumberController.text);
    nationalityController.text = _getStringValue(personal['nationality'], nationalityController.text);
    summaryController.text = _getStringValue(personal['summary'] ?? result.professionalSummary, summaryController.text);
    secondaryEmail = _getStringValue(personal['email'], '');

    _populateListFromDynamic(socialLinks, personal['socialLinks']);
    _populateListFromDynamic(skills, personal['skills']);

    educationalProfile.clear();
    educationalProfile.addAll(result.educationalProfile.map((edu) => {
      'institutionName': _getStringValue(edu['institutionName'], ''),
      'duration': _getStringValue(edu['duration'], ''),
      'majorSubjects': _getStringValue(edu['majorSubjects'], ''),
      'marksOrCgpa': _getStringValue(edu['marksOrCgpa'], ''),
    }));

    notifyListeners();
  }

  String _getStringValue(dynamic value, String fallback) =>
      (value?.toString().trim().isNotEmpty ?? false) ? value.toString() : fallback;

  void _populateListFromDynamic(List<String> target, dynamic source) {
    target.clear();
    if (source is List) {
      target.addAll(source.map((e) => e.toString()));
    } else if (source is String && source.isNotEmpty) {
      target.addAll(
          source.split(RegExp(r'[,;\n]')).map((s) => s.trim()).where((s) => s.isNotEmpty)
      );
    }
  }

  String _determineAuthEmail(String? override) {
    if (override?.trim().isNotEmpty ?? false) return override!.trim();
    if (emailController.text.trim().isNotEmpty) return emailController.text.trim();
    return secondaryEmail ?? '';
  }

  String _determineAuthPassword(String? override) {
    return (override?.isNotEmpty ?? false) ? override! : passwordController.text;
  }

  void _updateControllersWithOverrides(String? email, String? password) {
    if (email?.trim().isNotEmpty ?? false) emailController.text = email!.trim();
    if (password?.isNotEmpty ?? false) {
      passwordController.text = password!;
      confirmPasswordController.text = password;
    }
  }

  Future<void> _handleCvProfilePic(Map<String, dynamic> personal) async {
    if (profilePicBytes != null || personal['profilePic'] == null) return;

    try {
      final picVal = personal['profilePic'];
      if (picVal is String) {
        if (picVal.startsWith('data:')) {
          final parts = picVal.split(',');
          if (parts.length == 2) {
            profilePicBytes = base64Decode(parts[1]);
            imageDataUrl = picVal;
          }
        } else {
          try {
            profilePicBytes = base64Decode(picVal);
            imageDataUrl = 'data:image/jpeg;base64,$picVal';
          } catch (_) {}
        }
      }
    } catch (_) {}
  }

  Future<Map<String, dynamic>?> _pickImageWeb({int maxBytes = 2 * 1024 * 1024}) async {
    try {
      final uploadInput = html.FileUploadInputElement()
        ..accept = 'image/*'
        ..multiple = false
        ..style.display = 'none';

      html.document.body?.append(uploadInput);
      uploadInput.click();
      await uploadInput.onChange.first;

      final files = uploadInput.files;
      if (files == null || files.isEmpty) {
        uploadInput.remove();
        return null;
      }

      final file = files.first;
      if (file.size > maxBytes) {
        uploadInput.remove();
        return {'error': 'Selected image exceeds ${(maxBytes / (1024 * 1024)).toStringAsFixed(1)} MB'};
      }

      final readerDataUrl = html.FileReader()..readAsDataUrl(file);
      await readerDataUrl.onLoad.first;
      final dataUrl = readerDataUrl.result as String?;

      final readerBinary = html.FileReader()..readAsArrayBuffer(file);
      await readerBinary.onLoad.first;
      final resultBuffer = readerBinary.result;

      Uint8List bytes;
      if (resultBuffer is ByteBuffer) {
        bytes = resultBuffer.asUint8List();
      } else if (resultBuffer is List) {
        bytes = Uint8List.fromList(List<int>.from(resultBuffer));
      } else {
        uploadInput.remove();
        return {'error': 'Unable to read file bytes'};
      }

      uploadInput.remove();
      return {
        'dataUrl': dataUrl,
        'bytes': bytes,
        'fileName': file.name,
        'size': file.size,
      };
    } catch (e) {
      return {'error': 'Image pick failed: $e'};
    }
  }

  // ========== CLEANUP ==========
  void clearAll() {
    for (var c in [emailController, passwordController, confirmPasswordController, nameController,
      contactNumberController, nationalityController, summaryController, objectivesController,
      skillInputController, socialInputController]) {
      c.clear();
    }

    skills.clear();
    socialLinks.clear();
    educationalProfile.clear();

    profilePicBytes = null;
    imageDataUrl = null;
    profilePicUrl = null;
    dob = null;
    secondaryEmail = null;
    personalVisibleIndex = 0;
    currentStep = 0;
    emailError = null;
    passwordError = null;
    generalError = null;
    isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    for (var c in [emailController, passwordController, confirmPasswordController, nameController,
      contactNumberController, nationalityController, summaryController, objectivesController,
      skillInputController, socialInputController]) {
      c.dispose();
    }
    super.dispose();
  }
}