import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:job_portal/SignUp%20/signup_provider.dart';
import 'package:job_portal/extractor_CV/cv_extractor.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

class CvUploadSection extends StatefulWidget {
  final CvExtractor extractor;
  final SignupProvider provider;
  final VoidCallback onSuccess;
  final VoidCallback onManualContinue;

  const CvUploadSection({
    super.key,
    required this.extractor,
    required this.provider,
    required this.onSuccess,
    required this.onManualContinue,
  });

  @override
  State<CvUploadSection> createState() => _CvUploadSectionState();
}

class _CvUploadSectionState extends State<CvUploadSection>
    with TickerProviderStateMixin {
  Uint8List? _pickedBytes;
  String? _pickedFilename;
  bool _isExtracting = false;
  String? _lastError;
  CvExtractionResult? _result;
  final Map<String, TextEditingController> _fields = {};
  bool _showForm = false;
  final bool _isDragging = false;

  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    for (final c in _fields.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickFile() async {
    setState(() {
      _lastError = null;
      _showForm = false;
      _result = null;
      _fields.clear();
    });

    try {
      final res = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
        withData: true,
      );

      if (res == null || res.files.isEmpty) return;
      final file = res.files.first;

      if (file.size > 10 * 1024 * 1024) {
        setState(() => _lastError = 'File too large (max 10MB)');
        return;
      }

      setState(() {
        _pickedBytes = file.bytes;
        _pickedFilename = file.name;
      });

      _fadeController.forward(from: 0);
    } catch (e) {
      setState(() => _lastError = 'Failed to pick file: $e');
    }
  }

  Future<void> _runExtraction() async {
    if (_pickedBytes == null) {
      setState(() => _lastError = 'Please select a CV file first');
      return;
    }

    setState(() {
      _isExtracting = true;
      _lastError = null;
    });

    try {
      final result = await widget.extractor.extractFromFileBytes(
        _pickedBytes!,
        filename: _pickedFilename!,
      );

      setState(() {
        _result = result;
        _populateControllers(result);
        _showForm = true;
      });

      _fadeController.forward(from: 0);
    } catch (e) {
      setState(() => _lastError = 'Extraction failed: $e');
    } finally {
      setState(() => _isExtracting = false);
    }
  }

  void _populateControllers(CvExtractionResult r) {
    void ensure(String key, String value) {
      _fields.putIfAbsent(key, () => TextEditingController(text: value));
    }

    final p = r.personalProfile;
    ensure('name', p['name']?.toString() ?? '');
    ensure('email', p['email']?.toString() ?? '');
    ensure('contactNumber', p['contactNumber']?.toString() ?? '');
    ensure('nationality', p['nationality']?.toString() ?? '');
    ensure('summary', p['summary']?.toString() ?? r.professionalSummary ?? '');
    ensure('skills', (p['skills'] is List)
        ? (p['skills'] as List).join(', ')
        : (p['skills'] ?? '').toString());
    ensure('socialLinks', (p['socialLinks'] is List)
        ? (p['socialLinks'] as List).join('\n')
        : (p['socialLinks'] ?? '').toString());

    for (var i = 0; i < r.educationalProfile.length; i++) {
      final edu = r.educationalProfile[i];
      ensure('edu_institution_$i', edu['institutionName'] ?? '');
      ensure('edu_duration_$i', edu['duration'] ?? '');
      ensure('edu_major_$i', edu['majorSubjects'] ?? '');
      ensure('edu_marks_$i', edu['marksOrCgpa'] ?? '');
    }

    ensure('experiences', r.experiences.map((e) => e['text'] ?? '').join('\n\n'));
    ensure('certifications', r.certifications.join('\n'));
    ensure('publications', r.publications.join('\n'));
    ensure('awards', r.awards.join('\n'));
    ensure('references', r.references.join('\n'));
  }

  Future<void> _acceptAndFill() async {
    // Validation
    if (widget.provider.emailController.text.isEmpty ||
        widget.provider.passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete email & password first'),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }

    // Build final result from edited fields
    final personal = <String, dynamic>{
      'name': _fields['name']?.text.trim() ?? '',
      'email': _fields['email']?.text.trim() ?? '',
      'contactNumber': _fields['contactNumber']?.text.trim() ?? '',
      'nationality': _fields['nationality']?.text.trim() ?? '',
      'summary': _fields['summary']?.text.trim() ?? '',
      'skills': (_fields['skills']?.text ?? '')
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      'socialLinks': (_fields['socialLinks']?.text ?? '')
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
    };

    final education = <Map<String, String>>[];
    for (var i = 0; i < (_result?.educationalProfile.length ?? 0); i++) {
      education.add({
        'institutionName': _fields['edu_institution_$i']?.text ?? '',
        'duration': _fields['edu_duration_$i']?.text ?? '',
        'majorSubjects': _fields['edu_major_$i']?.text ?? '',
        'marksOrCgpa': _fields['edu_marks_$i']?.text ?? '',
      });
    }

    final experiences = (_fields['experiences']?.text ?? '')
        .split('\n\n')
        .map((e) => {'text': e.trim()})
        .where((m) => m['text'].toString().isNotEmpty)
        .toList();

    final finalResult = CvExtractionResult(
      rawText: _result!.rawText,
      personalProfile: personal,
      educationalProfile: education,
      professionalSummary: _fields['summary']?.text ?? _result!.professionalSummary,
      experiences: experiences,
      certifications: (_fields['certifications']?.text ?? '')
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      publications: (_fields['publications']?.text ?? '')
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      awards: (_fields['awards']?.text ?? '')
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      references: (_fields['references']?.text ?? '')
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
    );

    final success = await widget.provider.submitExtractedCvAndCreateAccount(finalResult);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Text('Account created successfully!', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      widget.onSuccess();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.provider.generalError ?? 'Failed to create account'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _resetSection() {
    setState(() {
      _pickedBytes = null;
      _pickedFilename = null;
      _result = null;
      _showForm = false;
      _lastError = null;
      _fields.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Upload Card with Drag & Drop
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: _isDragging
                  ? [colorScheme.primary.withOpacity(0.15), colorScheme.primary.withOpacity(0.05)]
                  : [Colors.white, Colors.grey.shade50],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: _pickFile,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Icon(
                      _pickedFilename == null ? Icons.cloud_upload_outlined : Icons.description,
                      size: 64,
                      color: _pickedFilename == null
                          ? colorScheme.primary.withOpacity(0.7)
                          : Colors.green.shade600,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _pickedFilename == null
                          ? 'Upload Your CV to Auto-Fill Profile'
                          : 'Selected: $_pickedFilename',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: _pickedFilename == null ? Colors.black87 : Colors.green.shade700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'PDF, DOC, DOCX, TXT • Max 10MB',
                      style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 20),
                    if (_pickedFilename == null)
                      ElevatedButton.icon(
                        onPressed: _pickFile,
                        icon: const Icon(Icons.folder_open),
                        label: Text('Browse Files', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                      )
                    else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton.icon(
                            onPressed: _resetSection,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Change File'),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            onPressed: _isExtracting ? null : _runExtraction,
                            icon: _isExtracting
                                ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                                : const Icon(Icons.auto_fix_high),
                            label: Text(_isExtracting ? 'Extracting...' : 'Extract Data'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple.shade600,
                              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            ),
                          ),
                        ],
                      ),
                    if (_lastError != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red.shade700),
                            const SizedBox(width: 12),
                            Expanded(child: Text(_lastError!, style: TextStyle(color: Colors.red.shade800))),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),

        // Extracted Preview
        if (_result != null) ...[
          const SizedBox(height: 24),
          FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.analytics_outlined, color: colorScheme.primary, size: 28),
                          const SizedBox(width: 12),
                          Text('Extracted Data Preview', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _chip('Name', _result!.personalProfile['name'] ?? '—'),
                          _chip('Email', _result!.personalProfile['email'] ?? '—'),
                          _chip('Phone', _result!.personalProfile['contactNumber'] ?? '—'),
                          _chip('Education', '${_result!.educationalProfile.length} entries'),
                          _chip('Experience', '${_result!.experiences.length} roles'),
                          _chip('Skills', '${( _result!.personalProfile['skills'] as List?)?.length ?? 0} skills'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],

        // Editable Form
        if (_showForm && _result != null)
          FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.edit_note, color: colorScheme.primary, size: 28),
                            const SizedBox(width: 12),
                            Text('Review & Edit Details', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700)),
                          ],
                        ),
                        const Divider(height: 32),
                        _buildModernForm(),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _resetSection,
                                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                                child: const Text('Start Over'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _acceptAndFill,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green.shade600,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: Text('Create Account', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: TextButton(
                            onPressed: widget.onManualContinue,
                            child: Text('Or continue with manual entry', style: GoogleFonts.poppins(color: Colors.grey.shade600)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _chip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.deepPurple.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 11, color: Colors.deepPurple.shade700)),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.deepPurple.shade900)),
        ],
      ),
    );
  }

  Widget _buildModernForm() {
    return Column(
      children: [
        _sectionTitle('Personal Information'),
        const SizedBox(height: 12),
        _modernField('Full Name', _fields['name']),
        _modernField('Email Address', _fields['email']),
        _modernField('Contact Number', _fields['contactNumber']),
        _modernField('Nationality', _fields['nationality']),
        _modernField('Professional Summary', _fields['summary'], maxLines: 4),
        _modernField('Skills (comma separated)', _fields['skills']),

        if (_result!.educationalProfile.isNotEmpty) ...[
          _sectionTitle('Education'),
          ..._result!.educationalProfile.asMap().entries.map((entry) {
            int i = entry.key;
            return Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Degree ${i + 1}', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 12),
                      _modernField('Institution', _fields['edu_institution_$i']),
                      Row(
                        children: [
                          Expanded(child: _modernField('Duration', _fields['edu_duration_$i'])),
                          const SizedBox(width: 12),
                          Expanded(child: _modernField('Major/Field', _fields['edu_major_$i'])),
                        ],
                      ),
                      _modernField('Grades/CGPA', _fields['edu_marks_$i']),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],

        _sectionTitle('Experience & Achievements'),
        _modernField('Work Experience (one per paragraph)', _fields['experiences'], maxLines: 6),
        _modernField('Certifications', _fields['certifications'], maxLines: 4),
        _modernField('Publications', _fields['publications'], maxLines: 4),
        _modernField('Awards & Honors', _fields['awards'], maxLines: 4),
        _modernField('References', _fields['references'], maxLines: 4),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _modernField(String label, TextEditingController? controller, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(color: Colors.grey.shade700),
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        ),
      ),
    );
  }
}