// profile_provider.dart
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileProvider_NEW extends ChangeNotifier {
  // Firestore collection/document
  final String role = 'job_seeker';
  String uid = '';

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool isLoading = true;
  String errorMessage = '';

  // Debug
  Map<String, dynamic>? lastFetchedRaw;
  String lastDebug = '';

  // PERSONAL (public fields used by UI)
  String name = '';
  String email = '';
  String secondaryEmail = '';
  String contactNumber = '';
  String nationality = '';
  String profilePicUrl = '';
  List<String> skillsList = []; // internal storage
  String objectives = '';
  List<String> socialLinks = [];
  String personalSummary = '';
  String dob = '';

  // EDUCATION temps + list
  String tempSchool = '';
  String tempDegree = '';
  String tempFieldOfStudy = '';
  String tempEduStart = '';
  String tempEduEnd = '';
  List<Map<String, dynamic>> educationalProfile = [];

  // PROFESSIONAL PROFILE
  String professionalProfileSummary = '';

  // PROFESSIONAL EXPERIENCE temps + list
  String tempCompany = '';
  String tempRole = '';
  String tempExpStart = '';
  String tempExpEnd = '';
  String tempExpDescription = '';
  List<Map<String, dynamic>> professionalExperience = [];
  String tempCertName = '';
  String tempCertInstitution = '';
  String tempCertYear = '';

  // CERTIFICATIONS / PUBLICATIONS / AWARDS / REFERENCES
  List<String> certifications = [];
  List<String> publications = [];
  List<String> awards = [];
  List<String> references = [];

  // DOCUMENTS: list of {name, url, contentType, uploadedAt}
  List<Map<String, dynamic>> documents = [];

  // controllers used by UI
  final TextEditingController skillController = TextEditingController();

  // Dirty flags
  bool personalDirty = false;
  bool educationDirty = false;
  bool professionalProfileDirty = false;
  bool experienceDirty = false;
  bool certificationsDirty = false;
  bool publicationsDirty = false;
  bool awardsDirty = false;
  bool referencesDirty = false;
  bool documentsDirty = false;

  ProfileProvider_NEW() {
    _init();
  }

  // ---------------- init / load ----------------
  Future<void> _init() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      isLoading = false;
      errorMessage = 'Not authenticated';
      notifyListeners();
      return;
    }
    uid = user.uid;
    await loadAll(); // primary loader
  }

  /// Public alias used in some UI files
  Future<void> loadAllSectionsOnce() => loadAll();

  /// Primary loader used by UI: prefers user_data map, maps 8 sections + documents
  Future<void> loadAll() async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      if (uid.isEmpty) {
        lastDebug = '[loadAll] uid empty';
        isLoading = false;
        notifyListeners();
        return;
      }

      final docRef = FirebaseFirestore.instance.collection(role).doc(uid);
      print('[ProfileProvider_NEW] fetching ${docRef.path}');
      final snap = await docRef.get();

      if (!snap.exists) {
        lastDebug = '[loadAll] doc not exists - clearing';
        _clearLocal();
        isLoading = false;
        notifyListeners();
        return;
      }

      lastFetchedRaw = Map<String, dynamic>.from(snap.data() as Map);
      print('[ProfileProvider_NEW] top-level keys: ${lastFetchedRaw!.keys.toList()}');

      // prefer user_data
      Map<String, dynamic> data = Map<String, dynamic>.from(lastFetchedRaw!);
      String branch = 'top-level';
      if (data.containsKey('user_data') && data['user_data'] is Map) {
        data = Map<String, dynamic>.from(data['user_data'] as Map);
        branch = 'user_data';
      } else if (data.containsKey('userData') && data['userData'] is Map) {
        data = Map<String, dynamic>.from(data['userData'] as Map);
        branch = 'userData';
      }

      lastDebug = '[loadAll] using branch: $branch; keys: ${data.keys.toList()}';
      print(lastDebug);

      // personal
      final personal = Map<String, dynamic>.from(data['personalProfile'] ?? data['personal_profile'] ?? {});
      name = (personal['name'] ?? personal['fullName'] ?? '')?.toString() ?? '';
      email = (personal['email'] ?? '')?.toString() ?? '';
      secondaryEmail = (personal['secondary_email'] ?? personal['secondaryEmail'] ?? '')?.toString() ?? '';
      contactNumber = (personal['contactNumber'] ?? personal['contact_number'] ?? '')?.toString() ?? '';
      nationality = (personal['nationality'] ?? '')?.toString() ?? '';
      profilePicUrl = (personal['profilePicUrl'] ?? personal['pic_url'] ?? '')?.toString() ?? '';
      objectives = (personal['objectives'] ?? '')?.toString() ?? '';
      personalSummary = (personal['summary'] ?? '')?.toString() ?? '';
      dob = (personal['dob'] ?? '')?.toString() ?? '';
      socialLinks = _toStringList(personal['socialLinks'] ?? personal['social_links'] ?? []);

      // skills
      final skillsRaw = personal['skills'] ?? personal['skillset'] ?? [];
      skillsList = _toStringList(skillsRaw);

      // rest sections
      educationalProfile = _mapListOfMap(data['educationalProfile'] ?? data['educational_profile'] ?? []);
      professionalProfileSummary = (data['professionalProfile']?['summary'] ?? data['professional_profile']?['summary'] ?? '')?.toString() ?? '';
      professionalExperience = _mapListOfMap(data['professionalExperience'] ?? data['professional_experience'] ?? []);
      certifications = _mapListStrings(data['certifications'] ?? []);
      publications = _mapListStrings(data['publications'] ?? []);
      awards = _mapListStrings(data['awards'] ?? []);
      references = _mapListStrings(data['references'] ?? []);
      documents = _mapListOfMap(data['documents'] ?? []);

      // reset temps & flags
      _clearTemps();
      personalDirty = educationDirty = professionalProfileDirty = experienceDirty = certificationsDirty = publicationsDirty = awardsDirty = referencesDirty = documentsDirty = false;

      isLoading = false;
      notifyListeners();
    } catch (e, st) {
      errorMessage = e.toString();
      lastDebug = '[loadAll] ERROR: $e\n$st';
      print(lastDebug);
      isLoading = false;
      notifyListeners();
    }
  }

  /// Force reload alias used by UI
  Future<void> forceReload() async {
    await loadAll();
  }

  // ---------------- mapping helpers ----------------
  List<Map<String, dynamic>> _mapListOfMap(dynamic v) {
    if (v is List) {
      try {
        return List<Map<String, dynamic>>.from(v.map((e) => Map<String, dynamic>.from(e as Map)));
      } catch (_) {
        return [];
      }
    }
    return [];
  }

  List<String> _mapListStrings(dynamic v) {
    if (v is List) return v.map((e) => e.toString()).toList();
    return [];
  }

  List<String> _toStringList(dynamic v) {
    if (v == null) return [];
    if (v is List) return v.map((e) => e.toString()).toList();
    if (v is String) return v.split(RegExp(r'[,;\n]')).map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    return [];
  }

  // ---------------- getters expected by UI ----------------

  /// UI expects `prov.skills` in many places — expose it.
  List<String> get skills => skillsList;

  /// UI expects `professionalSummary` getter name in some places
  String get professionalSummary => professionalProfileSummary;

  set professionalSummary(String v) {
    professionalProfileSummary = v;
    professionalProfileDirty = true;
    notifyListeners();
  }

  String get debugInfo {
    return 'uid:$uid isLoading:$isLoading error:$errorMessage\nlastDebug:$lastDebug\nname:$name email:$email skills:${skillsList.length} edu:${educationalProfile.length}';
  }

  // ---------------- Update helpers (UI-friendly names) ----------------
  void updateName(String v) { name = v; personalDirty = true; notifyListeners(); }
  void updateEmail(String v) { email = v; personalDirty = true; notifyListeners(); }
  void updateSecondaryEmail(String v) { secondaryEmail = v; personalDirty = true; notifyListeners(); }
  void updateContactNumber(String v) { contactNumber = v; personalDirty = true; notifyListeners(); }
  void updateNationality(String v) { nationality = v; personalDirty = true; notifyListeners(); }
  void updateObjectives(String v) { objectives = v; personalDirty = true; notifyListeners(); }
  void updatePersonalSummary(String v) { personalSummary = v; personalDirty = true; notifyListeners(); }
  void updateDob(String v) { dob = v; personalDirty = true; notifyListeners(); }

  void updateTempSchool(String v) { tempSchool = v; notifyListeners(); }
  void updateTempDegree(String v) { tempDegree = v; notifyListeners(); }
  void updateTempFieldOfStudy(String v) { tempFieldOfStudy = v; notifyListeners(); }
  void updateTempEduStart(String v) { tempEduStart = v; notifyListeners(); }
  void updateTempEduEnd(String v) { tempEduEnd = v; notifyListeners(); }

  void updateTempCompany(String v) { tempCompany = v; notifyListeners(); }
  void updateTempRole(String v) { tempRole = v; notifyListeners(); }
  void updateTempExpStart(String v) { tempExpStart = v; notifyListeners(); }
  void updateTempExpEnd(String v) { tempExpEnd = v; notifyListeners(); }
  void updateTempExpDescription(String v) { tempExpDescription = v; notifyListeners(); }

  void updateTempCertName(String v) { tempCertName = v; notifyListeners(); }
  void updateTempCertInstitution(String v) { tempCertInstitution = v; notifyListeners(); }
  void updateTempCertYear(String v) { tempCertYear = v; notifyListeners(); }

  // ---------------- Dirty markers ----------------
  void markPersonalDirty() { personalDirty = true; notifyListeners(); }
  void markEducationDirty() { educationDirty = true; notifyListeners(); }
  void markExperienceDirty() { experienceDirty = true; notifyListeners(); }
  void markCertificationsDirty() { certificationsDirty = true; notifyListeners(); }
  void markPublicationsDirty() { publicationsDirty = true; notifyListeners(); }
  void markAwardsDirty() { awardsDirty = true; notifyListeners(); }
  void markReferencesDirty() { referencesDirty = true; notifyListeners(); }

  Color getButtonColorForSection(String section) {
    switch (section) {
      case 'personal': return personalDirty ? Colors.red : Colors.green;
      case 'education': return educationDirty ? Colors.red : Colors.green;
      case 'experience': return experienceDirty ? Colors.red : Colors.green;
      case 'certifications': return certificationsDirty ? Colors.red : Colors.green;
      case 'publications': return publicationsDirty ? Colors.red : Colors.green;
      case 'awards': return awardsDirty ? Colors.red : Colors.green;
      case 'references': return referencesDirty ? Colors.red : Colors.green;
      default: return Colors.blue;
    }
  }

  // ---------------- Add / Remove helpers used by UI ----------------
  // Education
  void addEducation(Map<String, dynamic> entry) { educationalProfile.add(entry); educationDirty = true; notifyListeners(); }
  void addEducationEntry(BuildContext ctx) {
    if (tempSchool.trim().isEmpty && tempDegree.trim().isEmpty) {
      ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Please enter institution or degree')));
      return;
    }
    educationalProfile.add({
      'institutionName': tempSchool.trim(),
      'duration': tempEduStart.trim() + (tempEduEnd.trim().isNotEmpty ? ' - ${tempEduEnd.trim()}' : ''),
      'majorSubjects': tempFieldOfStudy.trim(),
      'marksOrCgpa': tempDegree.trim(),
      'eduStart': tempEduStart.trim(),
      'eduEnd': tempEduEnd.trim(),
    });
    _clearTempEdu();
    educationDirty = true;
    notifyListeners();
  }
  void updateEducationAt(int idx, Map<String, dynamic> entry) { if (idx>=0 && idx<educationalProfile.length) { educationalProfile[idx] = entry; educationDirty = true; notifyListeners(); } }
  void removeEducationAt(int idx) { if (idx>=0 && idx<educationalProfile.length) { educationalProfile.removeAt(idx); educationDirty = true; notifyListeners(); } }

  // Experience
  void addExperience(Map<String, dynamic> entry) { professionalExperience.add(entry); experienceDirty = true; notifyListeners(); }
  void addExperienceEntry(BuildContext ctx) {
    if (tempCompany.trim().isEmpty && tempExpDescription.trim().isEmpty) {
      ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Enter experience before adding')));
      return;
    }
    professionalExperience.add({
      'company': tempCompany.trim(),
      'role': tempRole.trim(),
      'expStart': tempExpStart.trim(),
      'expEnd': tempExpEnd.trim(),
      'text': tempExpDescription.trim(),
    });
    _clearTempExp();
    experienceDirty = true;
    notifyListeners();
  }
  void updateExperienceAt(int idx, Map<String, dynamic> entry) { if (idx>=0 && idx<professionalExperience.length) { professionalExperience[idx] = entry; experienceDirty = true; notifyListeners(); } }
  void removeExperienceAt(int idx) { if (idx>=0 && idx<professionalExperience.length) { professionalExperience.removeAt(idx); experienceDirty = true; notifyListeners(); } }

  // Certifications (UI calls addCertification/removeCertificationAt and addCertificationEntry)
  void addCertification(String v) { if (v.trim().isEmpty) return; certifications.add(v.trim()); certificationsDirty = true; notifyListeners(); }
  void addCertificationEntry(BuildContext ctx) {
    if (tempCertName.trim().isEmpty) { ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Enter certification name'))); return; }
    certifications.add(tempCertName.trim());
    _clearTempCert();
    certificationsDirty = true;
    notifyListeners();
  }
  void removeCertificationAt(int idx) { if (idx>=0 && idx<certifications.length) { certifications.removeAt(idx); certificationsDirty = true; notifyListeners(); } }

  // Publications
  void addPublication(String v) { if (v.trim().isEmpty) return; publications.add(v.trim()); publicationsDirty = true; notifyListeners(); }
  void removePublicationAt(int idx) { if (idx>=0 && idx<publications.length) { publications.removeAt(idx); publicationsDirty = true; notifyListeners(); } }

  // Awards
  void addAward(String v) { if (v.trim().isEmpty) return; awards.add(v.trim()); awardsDirty = true; notifyListeners(); }
  void removeAwardAt(int idx) { if (idx>=0 && idx<awards.length) { awards.removeAt(idx); awardsDirty = true; notifyListeners(); } }

  // References
  void addReference(String v) { if (v.trim().isEmpty) return; references.add(v.trim()); referencesDirty = true; notifyListeners(); }
  void removeReferenceAt(int idx) { if (idx>=0 && idx<references.length) { references.removeAt(idx); referencesDirty = true; notifyListeners(); } }

  // Skills helpers (UI uses both addSkill and addSkillEntry variants)
  void addSkill(String s) {
    final v = s.trim();
    if (v.isEmpty) return;
    if (!skillsList.contains(v)) {
      skillsList.add(v);
      skillController.clear();
      personalDirty = true;
      notifyListeners();
    }
  }
  void addSkillEntry(BuildContext ctx) {
    final val = skillController.text.trim();
    if (val.isEmpty) return;
    if (!skillsList.contains(val)) {
      skillsList.add(val);
      skillController.clear();
      personalDirty = true;
      notifyListeners();
    } else {
      ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Skill already exists')));
    }
  }
  void removeSkillAt(int idx) { if (idx>=0 && idx<skillsList.length) { skillsList.removeAt(idx); personalDirty = true; notifyListeners(); } }
  void removeSkill(String skill) { final removed = skillsList.remove(skill); if (removed) { personalDirty = true; notifyListeners(); } }
  void updateSkillAt(int idx, String v) { if (idx>=0 && idx<skillsList.length) { skillsList[idx] = v.trim(); personalDirty = true; notifyListeners(); } }

  // Documents
  void addDocumentEntry(Map<String, dynamic> entry) { documents.add(entry); documentsDirty = true; notifyListeners(); }
  void removeDocumentAt(int idx) { if (idx>=0 && idx<documents.length) { documents.removeAt(idx); documentsDirty = true; notifyListeners(); } }

  // ---------------- Save methods (section-aware) ----------------
  Future<void> savePersonal() async => savePersonalSectionSilent();
  Future<void> savePersonalSection(BuildContext ctx) async {
    isLoading = true; notifyListeners();
    try {
      await savePersonalSectionSilent();
      personalDirty = false;
      ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Personal saved')));
    } catch (e) {
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Save failed: $e')));
    } finally { isLoading = false; notifyListeners(); }
  }

  Future<void> saveEducation() async => _writeSection({'educationalProfile': educationalProfile});
  Future<void> saveEducationSection(BuildContext ctx) async {
    isLoading = true; notifyListeners();
    try {
      await saveEducation();
      educationDirty = false;
      ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Education saved')));
    } catch (e) {
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Save failed: $e')));
    } finally { isLoading = false; notifyListeners(); }
  }

  Future<void> saveProfessionalProfile() async => _writeSection({'professionalProfile': {'summary': professionalProfileSummary}});
  Future<void> saveProfessionalProfileSection(BuildContext ctx) async {
    isLoading = true; notifyListeners();
    try {
      await saveProfessionalProfile();
      professionalProfileDirty = false;
      ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Professional profile saved')));
    } catch (e) {
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Save failed: $e')));
    } finally { isLoading = false; notifyListeners(); }
  }

  Future<void> saveExperience() async => _writeSection({'professionalExperience': professionalExperience});
  Future<void> saveExperienceSection(BuildContext ctx) async {
    isLoading = true; notifyListeners();
    try {
      await saveExperience();
      experienceDirty = false;
      ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Experience saved')));
    } catch (e) {
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Save failed: $e')));
    } finally { isLoading = false; notifyListeners(); }
  }

  Future<void> saveCertifications() async => _writeSection({'certifications': certifications});
  Future<void> saveCertificationsSection(BuildContext ctx) async {
    isLoading = true; notifyListeners();
    try {
      await saveCertifications();
      certificationsDirty = false;
      ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Certifications saved')));
    } catch (e) {
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Save failed: $e')));
    } finally { isLoading = false; notifyListeners(); }
  }

  Future<void> savePublications() async => _writeSection({'publications': publications});
  Future<void> savePublicationsSection(BuildContext ctx) async {
    isLoading = true; notifyListeners();
    try {
      await savePublications();
      publicationsDirty = false;
      ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Publications saved')));
    } catch (e) {
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Save failed: $e')));
    } finally { isLoading = false; notifyListeners(); }
  }

  Future<void> saveAwards() async => _writeSection({'awards': awards});
  Future<void> saveAwardsSection(BuildContext ctx) async {
    isLoading = true; notifyListeners();
    try {
      await saveAwards();
      awardsDirty = false;
      ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Awards saved')));
    } catch (e) {
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Save failed: $e')));
    } finally { isLoading = false; notifyListeners(); }
  }

  Future<void> saveReferences() async => _writeSection({'references': references});
  Future<void> saveReferencesSection(BuildContext ctx) async {
    isLoading = true; notifyListeners();
    try {
      await saveReferences();
      referencesDirty = false;
      ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('References saved')));
    } catch (e) {
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Save failed: $e')));
    } finally { isLoading = false; notifyListeners(); }
  }

  Future<void> saveDocumentsSection(BuildContext ctx) async {
    isLoading = true; notifyListeners();
    try {
      await saveDocumentsList();
      documentsDirty = false;
      ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Documents saved')));
    } catch (e) {
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Save failed: $e')));
    } finally { isLoading = false; notifyListeners(); }
  }

  Future<void> savePersonalSectionSilent() async {
    final payload = {
      'personalProfile': {
        'name': name.trim(),
        'email': email.trim(),
        'secondary_email': secondaryEmail.trim(),
        'contactNumber': contactNumber.trim(),
        'nationality': nationality.trim(),
        'profilePicUrl': profilePicUrl.trim(),
        'skills': skillsList,
        'objectives': objectives.trim(),
        'socialLinks': socialLinks,
        'summary': personalSummary.trim(),
        'dob': dob.trim(),
      }
    };
    await _sectionAwareWrite(payload);
    personalDirty = false;
    notifyListeners();
  }

  // Generic write that checks for user_data presence
  Future<void> _writeSection(Map<String, dynamic> payload) async {
    final docRef = FirebaseFirestore.instance.collection(role).doc(uid);
    final snap = await docRef.get();
    if (snap.exists) {
      final raw = snap.data() ?? {};
      if ((raw.containsKey('user_data') || raw.containsKey('userData'))) {
        await docRef.set({'user_data': payload}, SetOptions(merge: true));
        return;
      }
    }
    await docRef.set(payload, SetOptions(merge: true));
  }


  // lower-level writer used by savePersonalSectionSilent
  Future<void> _sectionAwareWrite(Map<String, dynamic> payload) async {
    final docRef = FirebaseFirestore.instance.collection(role).doc(uid);
    final snap = await docRef.get();
    if (snap.exists) {
      final raw = snap.data() ?? {};
      if ((raw.containsKey('user_data') || raw.containsKey('userData'))) {
        await docRef.set({'user_data': payload}, SetOptions(merge: true));
        return;
      }
    }
    // fallback
    await docRef.set(payload, SetOptions(merge: true));
  }

  // ---------------- Storage helpers ----------------
  Future<void> uploadProfilePicture(Uint8List bytes, String filename, {String? mimeType}) async {
    if (uid.isEmpty) return;
    isLoading = true; notifyListeners();
    try {
      final ref = FirebaseStorage.instance.ref().child('users/$uid/profile/$filename');
      final metadata = SettableMetadata(contentType: mimeType ?? 'image/jpeg');
      final task = await ref.putData(bytes, metadata);
      final url = await task.ref.getDownloadURL();
      profilePicUrl = url;
      await savePersonalSectionSilent();
      print('[uploadProfilePicture] -> $url');
    } catch (e, st) {
      errorMessage = e.toString();
      print('[uploadProfilePicture] ERROR: $e\n$st');
    } finally {
      isLoading = false; notifyListeners();
    }
  }

  List<Map<String, dynamic>> _sanitizeDocumentsForSave(List<Map<String, dynamic>> src) {
    return src.map((doc) {
      final copied = Map<String, dynamic>.from(doc);
      final uploadedAt = copied['uploadedAt'];
      // Acceptable concrete types: Timestamp, DateTime, int (msSinceEpoch), String ISO
      if (uploadedAt is Timestamp) {
        // ok
      } else if (uploadedAt is DateTime) {
        copied['uploadedAt'] = Timestamp.fromDate(uploadedAt);
      } else if (uploadedAt is int) {
        // assume millis
        copied['uploadedAt'] = Timestamp.fromMillisecondsSinceEpoch(uploadedAt);
      } else if (uploadedAt is String) {
        // try parse ISO; fallback to now
        try {
          final dt = DateTime.parse(uploadedAt);
          copied['uploadedAt'] = Timestamp.fromDate(dt);
        } catch (_) {
          copied['uploadedAt'] = Timestamp.now();
        }
      } else {
        // uploadedAt is null or an unsupported sentinel (like FieldValue.serverTimestamp)
        copied['uploadedAt'] = Timestamp.now();
      }
      return copied;
    }).toList();
  }

  /// Save documents list (sanitized)
  Future<void> saveDocumentsList() async {
    isLoading = true;
    notifyListeners();
    try {
      // sanitize before writing
      final sanitized = _sanitizeDocumentsForSave(documents);
      await _writeSection({'documents': sanitized});
      documentsDirty = false;
      notifyListeners();
    } catch (e, st) {
      errorMessage = e.toString();
      print('[saveDocumentsList] ERROR: $e\n$st');
      notifyListeners();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Upload a document to Firebase Storage and add to documents[] using a concrete Timestamp
  Future<Map<String, dynamic>?> uploadDocument(Uint8List bytes, String filename, {String? mimeType}) async {
    if (uid.isEmpty) return null;
    isLoading = true;
    notifyListeners();
    try {
      final ts = DateTime.now().millisecondsSinceEpoch;
      final storageRef = FirebaseStorage.instance.ref().child('users/$uid/documents/${ts}_$filename');
      final metadata = SettableMetadata(contentType: mimeType ?? 'application/octet-stream');
      final uploadTask = await storageRef.putData(bytes, metadata);
      final url = await uploadTask.ref.getDownloadURL();

      // Use Timestamp.now() — a concrete Timestamp object (allowed inside arrays)
      final entry = <String, dynamic>{
        'name': filename,
        'url': url,
        'contentType': metadata.contentType ?? '',
        'uploadedAt': Timestamp.now(),
      };

      // add locally and persist sanitized list
      documents.add(entry);
      await saveDocumentsList(); // this will sanitize & write
      print('[uploadDocument] -> $url');
      return entry;
    } catch (e, st) {
      errorMessage = e.toString();
      print('[uploadDocument] ERROR: $e\n$st');
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
  // ---------------- Clear helpers ----------------
  void _clearTemps() {
    _clearTempEdu();
    _clearTempExp();
    _clearTempCert();
  }

  void _clearTempEdu() {
    tempSchool = '';
    tempDegree = '';
    tempFieldOfStudy = '';
    tempEduStart = '';
    tempEduEnd = '';
  }

  void _clearTempExp() {
    tempCompany = '';
    tempRole = '';
    tempExpStart = '';
    tempExpEnd = '';
    tempExpDescription = '';
  }

  void _clearTempCert() {
    tempCertName = '';
    tempCertInstitution = '';
    tempCertYear = '';
  }

  void _clearLocal() {
    name = '';
    email = '';
    secondaryEmail = '';
    contactNumber = '';
    nationality = '';
    profilePicUrl = '';
    skillsList = [];
    objectives = '';
    socialLinks = [];
    personalSummary = '';
    dob = '';

    educationalProfile = [];
    professionalProfileSummary = '';
    professionalExperience = [];
    certifications = [];
    publications = [];
    awards = [];
    references = [];
    documents = [];

    personalDirty = educationDirty = professionalProfileDirty = experienceDirty = certificationsDirty = publicationsDirty = awardsDirty = referencesDirty = documentsDirty = false;
  }

  // Convenience getter
  String get fullName {
    final parts = [name.trim()];
    return parts.where((s) => s.isNotEmpty).join(' ');
  }

  @override
  void dispose() {
    skillController.dispose();
    super.dispose();
  }
}
