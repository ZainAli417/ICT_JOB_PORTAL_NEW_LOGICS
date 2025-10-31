// lib/providers/signup_provider.dart
import 'dart:convert';
import 'dart:typed_data';
import 'dart:async';
import 'dart:html' as html; // for web image picker
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../extractor_CV/cv_extractor.dart'; // ensure path matches your project

class SignupProvider extends ChangeNotifier {
  // Role selection
  String role = 'job_seeker';
  bool showCvUploadSection = false;

  void revealCvUpload({bool reveal = true}) {
    showCvUploadSection = reveal;
    notifyListeners();
  }
  // Step trackers
  int personalVisibleIndex = 0; // controls reveal stepwise
  int currentStep = 0; // 0: account, 1: personal, 2: education, 3: review

  // Account controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  // Personal controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController contactNumberController = TextEditingController();
  final TextEditingController nationalityController = TextEditingController();
  final TextEditingController summaryController = TextEditingController(); // short professional summary
  final TextEditingController objectivesController = TextEditingController();

  // Skills & social inputs
  final TextEditingController skillInputController = TextEditingController();
  final List<String> skills = [];
  final TextEditingController socialInputController = TextEditingController();
  final List<String> socialLinks = [];

  // DOB
  DateTime? dob;

  // Image (web + mobile)
  Uint8List? profilePicBytes; // used for preview & upload
  String? imageDataUrl; // data:<mime>;base64,<payload> for MemoryImage hint style
  String? profilePicUrl; // final URL in Firebase Storage (nullable)

  // Secondary extracted email (from CV)
  String? secondaryEmail;

  // Education
  final List<Map<String, dynamic>> educationalProfile = [];

  // Validation state
  String? emailError;
  String? passwordError;
  String? generalError;

  bool isLoading = false;

  // Image picker
  final ImagePicker _picker = ImagePicker();

  SignupProvider();

  // ---------- State helpers ----------
  void setRole(String newRole) {
    if (role == 'recruiter') showCvUploadSection = false;

    if (newRole != 'job_seeker' && newRole != 'recruiter') return;
    role = newRole;

    notifyListeners();
  }

  // REGISTER RECRUITER
  Future<bool> registerRecruiter() async {
    try {
      generalError = null;
      notifyListeners();

      // 1) create auth user
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      final uid = cred.user?.uid;
      if (uid == null) {
        generalError = 'Failed to obtain user id after signup.';
        notifyListeners();
        return false;
      }

      // 2) build canonical user_data map
      final user_data = {
        'uid': uid,
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'role': role, // uses provider.role (should be 'recruiter' here)
        'createdAt': FieldValue.serverTimestamp(),
      };

      final firestore = FirebaseFirestore.instance;

      // 3) write canonical doc under: /{role}/{uid}/user_data
      // We'll put the structured map inside a `user_data` field to match your described layout.
      await firestore.collection(role).doc(uid).set({
        'user_data': user_data,
      }, SetOptions(merge: true));

      // 4) shadow copy under 'users' (auto-id) - unchanged
      await firestore.collection('users').add({
        'name': user_data['name'],
        'email': user_data['email'],
        'uid': uid,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });

      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      generalError = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      generalError = e.toString();
      notifyListeners();
      return false;
    }
  }

  void goToStep(int step) {
    currentStep = step;
    if (step == 1 && personalVisibleIndex == 0) personalVisibleIndex = 0;
    notifyListeners();
  }

  void revealNextPersonalField() {
    personalVisibleIndex = personalVisibleIndex + 1;
    notifyListeners();
  }

  void revealPreviousPersonalField() {
    if (personalVisibleIndex > 0) {
      personalVisibleIndex = personalVisibleIndex - 1;
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

  // ---------- Image pick (web + mobile) ----------
  Future<void> pickProfilePicture() async {
    try {
      if (kIsWeb) {
        final res = await pickImageWebImpl();
        if (res == null) return;
        if (res.containsKey('error')) {
          generalError = res['error'] as String?;
          notifyListeners();
          return;
        }
        profilePicBytes = res['bytes'] as Uint8List?;
        imageDataUrl = res['dataUrl'] as String?;
        profilePicUrl = null;
        notifyListeners();
        return;
      }

      final XFile? picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      profilePicBytes = bytes;
      final mime = picked.mimeType ?? 'image/jpeg';
      imageDataUrl = 'data:$mime;base64,${base64Encode(bytes)}';
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

  // ---------- Skills & Social chips ----------
  void addSkill(String raw) {
    final v = raw.trim();
    if (v.isEmpty) return;
    if (!skills.contains(v)) {
      skills.add(v);
      notifyListeners();
    }
  }

  void removeSkillAt(int idx) {
    if (idx < 0 || idx >= skills.length) return;
    skills.removeAt(idx);
    notifyListeners();
  }

  void addSocialLink(String raw) {
    final v = raw.trim();
    if (v.isEmpty) return;
    if (!socialLinks.contains(v)) {
      socialLinks.add(v);
      notifyListeners();
    }
  }

  void removeSocialLinkAt(int idx) {
    if (idx < 0 || idx >= socialLinks.length) return;
    socialLinks.removeAt(idx);
    notifyListeners();
  }

  // ---------- Education ----------
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
    if (index < 0 || index >= educationalProfile.length) return;
    educationalProfile[index] = newEntry;
    notifyListeners();
  }

  void removeEducation(int index) {
    if (index < 0 || index >= educationalProfile.length) return;
    educationalProfile.removeAt(index);
    notifyListeners();
  }

  // ---------- Validations ----------
  bool validateEmail() {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      emailError = 'Email is required';
      notifyListeners();
      return false;
    }
    final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
    if (!emailRegex.hasMatch(email)) {
      emailError = 'Enter a valid email';
      notifyListeners();
      return false;
    }
    emailError = null;
    notifyListeners();
    return true;
  }

  bool validatePasswords() {
    final p = passwordController.text;
    final cp = confirmPasswordController.text;
    if (p.isEmpty || cp.isEmpty) {
      passwordError = 'Password and confirm password are required';
      notifyListeners();
      return false;
    }
    if (p.length < 8) {
      passwordError = 'Password must be at least 8 characters';
      notifyListeners();
      return false;
    }
    if (p != cp) {
      passwordError = 'Passwords do not match';
      notifyListeners();
      return false;
    }
    passwordError = null;
    notifyListeners();
    return true;
  }

  bool validatePersonalFieldAtIndex(int index) {
    switch (index) {
      case 0:
        return nameController.text.trim().isNotEmpty;
      case 1:
        final s = contactNumberController.text.trim();
        final phoneRegex = RegExp(r'^[\d\+\-\s]{5,20}$');
        return s.isNotEmpty && phoneRegex.hasMatch(s);
      case 2:
        return nationalityController.text.trim().isNotEmpty;
      case 3:
        return summaryController.text.trim().isNotEmpty;
      case 4:
        return skills.isNotEmpty;
      case 5:
        return objectivesController.text.trim().isNotEmpty;
      case 6:
        return dob != null;
      default:
        return false;
    }
  }

  bool personalSectionIsComplete() {
    final required = [0, 1, 2, 3, 4, 5, 6];
    for (final i in required) {
      if (!validatePersonalFieldAtIndex(i)) return false;
    }
    return true;
  }

  bool educationSectionIsComplete() {
    if (educationalProfile.isEmpty) return false;
    for (final e in educationalProfile) {
      if ((e['institutionName'] as String?)?.isEmpty ?? true) return false;
      if ((e['duration'] as String?)?.isEmpty ?? true) return false;
      if ((e['majorSubjects'] as String?)?.isEmpty ?? true) return false;
      if ((e['marksOrCgpa'] as String?)?.isEmpty ?? true) return false;
    }
    return true;
  }

  double computeProgress() {
    final personalIndices = [0, 1, 2, 3, 4, 5, 6];
    int personalDone = 0;
    for (final i in personalIndices) {
      if (validatePersonalFieldAtIndex(i)) personalDone++;
    }
    final educationDone = educationSectionIsComplete() ? 1 : 0;
    return (personalDone + educationDone) / (personalIndices.length + 1);
  }

  // ---------- Firebase submit for manual signup (existing) ----------
  Future<bool> submitAllAndCreateAccount() async {
    generalError = null;
    isLoading = true;
    notifyListeners();

    try {
      if (!validateEmail()) {
        generalError = emailError;
        isLoading = false;
        notifyListeners();
        return false;
      }
      if (!validatePasswords()) {
        generalError = passwordError;
        isLoading = false;
        notifyListeners();
        return false;
      }
      if (!personalSectionIsComplete()) {
        generalError = 'Please complete all required personal fields.';
        isLoading = false;
        notifyListeners();
        return false;
      }
      if (!educationSectionIsComplete()) {
        generalError = 'Please add at least one education entry and fill all its fields.';
        isLoading = false;
        notifyListeners();
        return false;
      }

      final auth = FirebaseAuth.instance;
      UserCredential uc;
      try {
        uc = await auth.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text,
        );
      } on FirebaseAuthException catch (e) {
        generalError = e.message ?? 'Authentication failed';
        isLoading = false;
        notifyListeners();
        return false;
      }

      final uid = uc.user?.uid;
      if (uid == null) {
        generalError = 'Unable to obtain user id after signup.';
        isLoading = false;
        notifyListeners();
        return false;
      }

      // Upload image if present
      if (profilePicBytes != null && profilePicBytes!.isNotEmpty) {
        try {
          final url = await _uploadProfilePicBytes(uid, profilePicBytes!);
          profilePicUrl = url;
        } catch (_) {
          profilePicUrl = null;
        }
      }

      final personalProfile = {
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
      };

      final educationList = educationalProfile
          .map((e) => {
        'institutionName': (e['institutionName'] as String).trim(),
        'duration': (e['duration'] as String).trim(),
        'majorSubjects': (e['majorSubjects'] as String).trim(),
        'marksOrCgpa': (e['marksOrCgpa'] as String).trim(),
      })
          .toList();

      final firestore = FirebaseFirestore.instance;
      final userDocRef = firestore.collection(role).doc(uid);
      await userDocRef.set({
        'user_data': {
          'personalProfile': personalProfile,
          'educationalProfile': educationList,
        }
      }, SetOptions(merge: true));

      // shadow copy
      try {
        final shadowData = {
          'fullName': nameController.text.trim(),
          'email': emailController.text.trim(),
          'uid': uid,
          'role': role,
          'createdAt': FieldValue.serverTimestamp(),
        };
        await firestore.collection('users').add(shadowData);
      } catch (e) {
        generalError = 'Warning: shadow copy failed.';
      }

      isLoading = false;
      notifyListeners();
      return true;
    } catch (e, st) {
      generalError = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ---------- NEW: submit extracted CV, create user and save the full 8 sections ----------
// inside SignupProvider

  Future<bool> submitExtractedCvAndCreateAccount(
      CvExtractionResult result, {
        String? overrideEmail,
        String? overridePassword,
      })
  async {
    generalError = null;
    isLoading = true;
    notifyListeners();

    try {
      // 1) Populate provider fields (so UI updates immediately)
      final personal = result.personalProfile;
      nameController.text = (personal['name'] ?? nameController.text).toString();
      contactNumberController.text = (personal['contactNumber'] ?? contactNumberController.text).toString();
      nationalityController.text = (personal['nationality'] ?? nationalityController.text).toString();
      summaryController.text = (personal['summary'] ?? result.professionalSummary ?? summaryController.text).toString();

      // social links
      socialLinks.clear();
      if (personal['socialLinks'] is List) {
        socialLinks.addAll((personal['socialLinks'] as List).map((e) => e.toString()));
      } else if (personal['socialLinks'] is String && (personal['socialLinks'] as String).isNotEmpty) {
        socialLinks.addAll((personal['socialLinks'] as String)
            .split(RegExp(r'[\n,;]'))
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty));
      }

      // skills
      skills.clear();
      if (personal['skills'] is List) {
        skills.addAll((personal['skills'] as List).map((e) => e.toString()));
      } else if (personal['skills'] is String && (personal['skills'] as String).isNotEmpty) {
        skills.addAll((personal['skills'] as String)
            .split(RegExp(r'[,;\n]'))
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty));
      }

      // set secondary email (extracted email from CV)
      secondaryEmail = (personal['email'] ?? '').toString();

      // education
      educationalProfile.clear();
      for (final edu in result.educationalProfile) {
        educationalProfile.add({
          'institutionName': (edu['institutionName'] ?? '').toString(),
          'duration': (edu['duration'] ?? '').toString(),
          'majorSubjects': (edu['majorSubjects'] ?? '').toString(),
          'marksOrCgpa': (edu['marksOrCgpa'] ?? '').toString(),
        });
      }

      notifyListeners();

      // 2) Determine auth credentials (override -> controller -> extracted secondary)
      final String authEmail = (overrideEmail != null && overrideEmail.trim().isNotEmpty)
          ? overrideEmail.trim()
          : (emailController.text.trim().isNotEmpty ? emailController.text.trim() : (secondaryEmail ?? ''));

      final String authPass = (overridePassword != null && overridePassword.isNotEmpty)
          ? overridePassword
          : passwordController.text;

      // If overrides were provided, reflect them into controllers so UI shows them
      if (overrideEmail != null && overrideEmail.trim().isNotEmpty) {
        emailController.text = overrideEmail.trim();
      }
      if (overridePassword != null && overridePassword.isNotEmpty) {
        passwordController.text = overridePassword;
        confirmPasswordController.text = overridePassword;
      }

      if (authEmail.isEmpty || authPass.isEmpty) {
        generalError = 'Email and password required to create account. Provide them in the account step or fill before proceeding.';
        isLoading = false;
        notifyListeners();
        return false;
      }

      // 3) Create Firebase Auth user
      UserCredential uc;
      try {
        uc = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: authEmail, password: authPass);
      } on FirebaseAuthException catch (e) {
        generalError = e.message ?? 'Authentication failed';
        isLoading = false;
        notifyListeners();
        return false;
      }

      final uid = uc.user?.uid;
      if (uid == null) {
        generalError = 'Unable to obtain user id after signup.';
        isLoading = false;
        notifyListeners();
        return false;
      }

      // 4) Handle profile picture: prefer provider.profilePicBytes (user-picked), else try to read from extracted data
      if (profilePicBytes == null && personal['profilePic'] != null) {
        try {
          final dynamic picVal = personal['profilePic'];
          if (picVal is String && picVal.startsWith('data:')) {
            final parts = picVal.split(',');
            if (parts.length == 2) {
              final b64 = parts[1];
              profilePicBytes = base64Decode(b64);
              imageDataUrl = picVal;
            }
          } else if (picVal is String) {
            try {
              profilePicBytes = base64Decode(picVal);
              imageDataUrl = 'data:image/jpeg;base64,$picVal';
            } catch (_) {}
          }
        } catch (_) {}
      }

      // upload profile pic to Firebase Storage if present
      if (profilePicBytes != null && profilePicBytes!.isNotEmpty) {
        try {
          final storageRef = FirebaseStorage.instance.ref().child('$role/$uid/profilePic.jpg');
          final meta = SettableMetadata(contentType: 'image/jpeg');
          await storageRef.putData(profilePicBytes!, meta);
          profilePicUrl = await storageRef.getDownloadURL();
        } catch (e) {
          // non-fatal: leave profilePicUrl null
          profilePicUrl = null;
        }
      }

      // 5) Build full document structure and persist to Firestore
      final Map<String, dynamic> user_data = {
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
        'professionalProfile': {
          'summary': result.professionalSummary ?? '',
        },
        'professionalExperience': result.experiences,
        'certifications': result.certifications,
        'publications': result.publications,
        'awards': result.awards,
        'references': result.references,
        'createdAt': FieldValue.serverTimestamp(),
      };

      final firestore = FirebaseFirestore.instance;
      final userDocRef = firestore.collection(role).doc(uid);
      await userDocRef.set({'user_data': user_data, 'secondary_email': secondaryEmail ?? ''}, SetOptions(merge: true));

      // 6) Shadow copy in 'users' collection
      try {
        final shadowData = {
          'fullName': nameController.text.trim(),
          'email': authEmail,
          'secondary_email': secondaryEmail ?? '',
          'uid': uid,
          'role': role,
          'createdAt': FieldValue.serverTimestamp(),
        };
        await firestore.collection('users').add(shadowData);
      } catch (_) {}

      isLoading = false;
      notifyListeners();
      return true;
    } catch (e, st) {
      generalError = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Helper: upload profile picture bytes to Firebase Storage and return download URL
  Future<String?> _uploadProfilePicBytes(String uid, Uint8List bytes) async {
    final ext = '.jpg';
    final storageRef = FirebaseStorage.instance.ref().child('$role/$uid/profilePic$ext');
    final meta = SettableMetadata(contentType: 'image/jpeg');
    final uploadTask = await storageRef.putData(bytes, meta);
    final url = await storageRef.getDownloadURL();
    return url;
  }

  // ---------- Clear all (call after successful signup or on screen entry) ----------
  void clearAll() {
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    nameController.clear();
    contactNumberController.clear();
    nationalityController.clear();
    summaryController.clear();
    objectivesController.clear();
    skillInputController.clear();
    socialInputController.clear();
    skills.clear();
    socialLinks.clear();
    educationalProfile.clear();
    profilePicBytes = null;
    imageDataUrl = null;
    profilePicUrl = null;
    dob = null;
    personalVisibleIndex = 0;
    currentStep = 0;
    emailError = null;
    passwordError = null;
    generalError = null;
    isLoading = false;
    secondaryEmail = null;
    notifyListeners();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameController.dispose();
    contactNumberController.dispose();
    nationalityController.dispose();
    summaryController.dispose();
    objectivesController.dispose();
    skillInputController.dispose();
    socialInputController.dispose();
    super.dispose();
  }

  // Web image picker helper (kept from your original implementation)
  Future<Map<String, dynamic>?> pickImageWebImpl({int maxBytes = 2 * 1024 * 1024}) async {
    try {
      final uploadInput = html.FileUploadInputElement();
      uploadInput.accept = 'image/*';
      uploadInput.multiple = false;
      uploadInput.style.display = 'none';
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
        final maxMb = (maxBytes / (1024 * 1024)).toStringAsFixed(1);
        return {'error': 'Selected image exceeds $maxMb MB'};
      }
      final readerDataUrl = html.FileReader();
      readerDataUrl.readAsDataUrl(file);
      await readerDataUrl.onLoad.first;
      final dataUrl = readerDataUrl.result as String?;
      final readerBinary = html.FileReader();
      readerBinary.readAsArrayBuffer(file);
      await readerBinary.onLoad.first;
      final resultBuffer = readerBinary.result;
      Uint8List bytes;
      if (resultBuffer is ByteBuffer) {
        bytes = resultBuffer.asUint8List();
      } else if (resultBuffer is List) {
        bytes = Uint8List.fromList(List<int>.from(resultBuffer));
      } else {
        uploadInput.remove();
        return {'error': 'Unable to read file bytes (unsupported result type)'};
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
}
