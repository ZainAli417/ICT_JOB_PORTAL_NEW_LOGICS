// lib/providers/signup_provider.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'dart:async';
import 'dart:html' as html;


class SignupProvider extends ChangeNotifier {
  // Role selection
  String role = 'job_seeker';

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
  final TextEditingController summaryController = TextEditingController(); // NEW
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
    if (newRole != 'job_seeker' && newRole != 'recruiter') return;
    role = newRole;
    notifyListeners();
  }

  void goToStep(int step) {
    currentStep = step;
    // if entering personal step ensure first field visible
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
    // Called from UI onChanged; reveal next field when current becomes non-empty
    if (value.trim().isNotEmpty && personalVisibleIndex == index) {
      revealNextPersonalField();
    }
  }

  void setDob(DateTime date) {
    dob = date;
    notifyListeners();
  }

  Future<void> pickProfilePicture() async {
    try {
      // --- Web path: use the html file picker helper (data URL + bytes) ---
      if (kIsWeb) {
        final res = await pickImageWebImpl();
        if (res == null) return; // user cancelled or stubbed
        if (res.containsKey('error')) {
          generalError = res['error'] as String?;
          notifyListeners();
          return;
        }
        // assign bytes and dataUrl for preview + upload
        profilePicBytes = res['bytes'] as Uint8List?;
        imageDataUrl = res['dataUrl'] as String?;
        // keep profilePicUrl null until uploaded during submit
        profilePicUrl = null;
        notifyListeners();
        return;
      }

      // --- Mobile/desktop path: use image_picker plugin ---
      final XFile? picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      profilePicBytes = bytes;
      // create a data url for consistent preview approach
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

  // Personal fields indices (updated to include summary)
  // 0: name, 1: contact, 2: nationality, 3: summary, 4: skills, 5: objectives, 6: dob
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
    // (number of personal fields complete + educationComplete) / total
    final personalIndices = [0, 1, 2, 3, 4, 5, 6];
    int personalDone = 0;
    for (final i in personalIndices) {
      if (validatePersonalFieldAtIndex(i)) personalDone++;
    }
    final educationDone = educationSectionIsComplete() ? 1 : 0;
    return (personalDone + educationDone) / (personalIndices.length + 1);
  }

  // ---------- Firebase submit ----------
  Future<bool> submitAllAndCreateAccount() async {
    generalError = null;
    isLoading = true;
    notifyListeners();

    try {
      // Validate account
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

      // Validate personal & education
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

      // Create user
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

      // Upload image if present (putData)
      if (profilePicBytes != null && profilePicBytes!.isNotEmpty) {
        try {
          final storageRef = FirebaseStorage.instance.ref().child('$role/$uid/profilePic.jpg');
          final meta = SettableMetadata(contentType: 'image/jpeg');
          await storageRef.putData(profilePicBytes!, meta);
          profilePicUrl = await storageRef.getDownloadURL();
        } catch (e) {
          profilePicUrl = null;
        }
      }

      // Build normalized data
      final personalProfile = {
        'fullName': nameController.text.trim(),
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

      final educationList = educationalProfile.map((e) => {
        'institutionName': (e['institutionName'] as String).trim(),
        'duration': (e['duration'] as String).trim(),
        'majorSubjects': (e['majorSubjects'] as String).trim(),
        'marksOrCgpa': (e['marksOrCgpa'] as String).trim(),
      }).toList();

      final firestore = FirebaseFirestore.instance;

      // Save role/doc
      final userDocRef = firestore.collection(role).doc(uid);
      await userDocRef.set({
        'user_data': {
          'personalProfile': personalProfile,
          'educationalProfile': educationList,
        }
      }, SetOptions(merge: true));

      // Shadow copy in users collection (auto doc)
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
        // non-fatal
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

  Future<Map<String, dynamic>?> pickImageWebImpl({int maxBytes = 2 * 1024 * 1024}) async {
    try {
      final uploadInput = html.FileUploadInputElement();
      uploadInput.accept = 'image/*';
      uploadInput.multiple = false;

      // Hide and attach to DOM so some browsers behave consistently.
      uploadInput.style.display = 'none';
      html.document.body?.append(uploadInput);

      // Trigger the file picker (user gesture because this runs from a button tap).
      uploadInput.click();

      // Wait for user selection (or cancel)
      await uploadInput.onChange.first;
      final files = uploadInput.files;
      if (files == null || files.isEmpty) {
        uploadInput.remove();
        return null; // user cancelled
      }

      final file = files.first;

      // Size validation
      if (file.size > maxBytes) {
        uploadInput.remove();
        final maxMb = (maxBytes / (1024 * 1024)).toStringAsFixed(1);
        return {'error': 'Selected image exceeds $maxMb MB'};
      }

      // Read as Data URL (for preview)
      final readerDataUrl = html.FileReader();
      readerDataUrl.readAsDataUrl(file);
      await readerDataUrl.onLoad.first;
      final dataUrl = readerDataUrl.result as String?;

      // Read as ArrayBuffer (for bytes)
      final readerBinary = html.FileReader();
      readerBinary.readAsArrayBuffer(file);
      await readerBinary.onLoad.first;
      final resultBuffer = readerBinary.result;

      // Convert result to Uint8List robustly
      Uint8List bytes;
      if (resultBuffer is ByteBuffer) {
        bytes = resultBuffer.asUint8List();
      } else if (resultBuffer is List) {
        // sometimes it's a List<int>
        bytes = Uint8List.fromList(List<int>.from(resultBuffer));
      } else {
        uploadInput.remove();
        return {'error': 'Unable to read file bytes (unsupported result type)'};
      }

      // Clean up the DOM element
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
