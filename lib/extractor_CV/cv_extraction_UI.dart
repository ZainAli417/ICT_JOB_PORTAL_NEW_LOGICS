import 'dart:convert';
import 'dart:math';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_portal/SignUp%20/signup_provider.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../extractor_CV/cv_extractor.dart';
import '../main.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';

class CvUploadSection extends StatefulWidget {
  final CvExtractor extractor;
  final SignupProvider provider;
  final VoidCallback onSuccess;
  final VoidCallback onManualContinue;

  const CvUploadSection({
    Key? key,
    required this.extractor,
    required this.provider,
    required this.onSuccess,
    required this.onManualContinue,
  }) : super(key: key);

  @override
  State<CvUploadSection> createState() => _CvUploadSectionState();
}

class _CvUploadSectionState extends State<CvUploadSection> {
  Uint8List? _pickedBytes;
  String? _pickedFilename;
  bool _isExtracting = false;
  String? _lastError;
  CvExtractionResult? _result;
  final Map<String, TextEditingController> _fields = {};
  bool _showForm = false;

  Future<void> _pickFile() async {
    setState(() {
      _lastError = null;
      _showForm = false;
    });
    try {
      final res = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf', 'txt', 'doc', 'docx'],
          withData: true
      );
      if (res == null || res.files.isEmpty) return;
      final f = res.files.first;
      if (f.size > 10 * 1024 * 1024) {
        setState(() { _lastError = 'File too large (max 10MB)'; });
        return;
      }
      setState(() {
        _pickedBytes = f.bytes;
        _pickedFilename = f.name;
        _result = null;
        _fields.clear();
        _showForm = false;
      });
    } catch (e) {
      setState(() { _lastError = 'File pick failed: $e'; });
    }
  }

  Future<void> _runExtraction() async {
    if (_pickedBytes == null || _pickedFilename == null) {
      setState(() { _lastError = 'Please pick a file first'; });
      return;
    }

    setState(() {
      _isExtracting = true;
      _lastError = null;
      _result = null;
      _showForm = false;
    });

    try {
      final r = await widget.extractor.extractFromFileBytes(
          _pickedBytes!,
          filename: _pickedFilename!
      );
      setState(() {
        _result = r;
        _populateControllers(r);
        _showForm = true;
      });
    } catch (e) {
      setState(() {
        _lastError = 'Extraction failed: $e';
      });
    } finally {
      setState(() { _isExtracting = false; });
    }
  }

  void _populateControllers(CvExtractionResult r) {
    void ensure(String k, String v) {
      _fields.putIfAbsent(k, () => TextEditingController(text: v));
    }

    final p = r.personalProfile;
    ensure('name', (p['name'] ?? '').toString());
    ensure('email', (p['email'] ?? '').toString());
    ensure('contactNumber', (p['contactNumber'] ?? '').toString());
    ensure('nationality', (p['nationality'] ?? '').toString());
    ensure('summary', (p['summary'] ?? r.professionalSummary ?? '').toString());
    ensure('skills', (p['skills'] is List)
        ? (p['skills'] as List).join(', ')
        : (p['skills'] ?? '').toString());
    ensure('socialLinks', (p['socialLinks'] is List)
        ? (p['socialLinks'] as List).join('\n')
        : (p['socialLinks'] ?? '').toString());

    for (var i = 0; i < r.educationalProfile.length; i++) {
      final e = r.educationalProfile[i];
      ensure('edu_institution_$i', e['institutionName'] ?? '');
      ensure('edu_duration_$i', e['duration'] ?? '');
      ensure('edu_major_$i', e['majorSubjects'] ?? '');
      ensure('edu_marks_$i', e['marksOrCgpa'] ?? '');
    }

    ensure('experiences', r.experiences.map((e) => e['text'] ?? '').join('\n\n'));
    ensure('certifications', r.certifications.join('\n'));
    ensure('publications', r.publications.join('\n'));
    ensure('awards', r.awards.join('\n'));
    ensure('references', r.references.join('\n'));
  }

  Future<void> _acceptAndFill() async {
    if (_result == null) return;

    // Validate that account step is complete
    final p = widget.provider;
    if (p.emailController.text.isEmpty || p.passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete email and password in Account section first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Build final result from edited fields
    final finalPersonal = <String, dynamic>{};
    finalPersonal['name'] = _fields['name']?.text ?? '';
    finalPersonal['email'] = _fields['email']?.text ?? '';
    finalPersonal['contactNumber'] = _fields['contactNumber']?.text ?? '';
    finalPersonal['nationality'] = _fields['nationality']?.text ?? '';
    finalPersonal['summary'] = _fields['summary']?.text ?? '';
    finalPersonal['skills'] = (_fields['skills']?.text ?? '')
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    finalPersonal['socialLinks'] = (_fields['socialLinks']?.text ?? '')
        .split('\n')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final education = <Map<String, String>>[];
    for (var i = 0; i < _result!.educationalProfile.length; i++) {
      education.add({
        'institutionName': _fields['edu_institution_$i']?.text ?? '',
        'duration': _fields['edu_duration_$i']?.text ?? '',
        'majorSubjects': _fields['edu_major_$i']?.text ?? '',
        'marksOrCgpa': _fields['edu_marks_$i']?.text ?? '',
      });
    }

    final experiences = (_fields['experiences']?.text ?? '')
        .split('\n\n')
        .map((s) => {'text': s.trim()})
        .where((m) => (m['text'] ?? '').toString().isNotEmpty)
        .toList();

    final certs = (_fields['certifications']?.text ?? '')
        .split('\n')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final pubs = (_fields['publications']?.text ?? '')
        .split('\n')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final awards = (_fields['awards']?.text ?? '')
        .split('\n')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final refs = (_fields['references']?.text ?? '')
        .split('\n')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final finalResult = CvExtractionResult(
      rawText: _result!.rawText,
      personalProfile: finalPersonal,
      educationalProfile: education,
      professionalSummary: _fields['summary']?.text ?? _result!.professionalSummary,
      experiences: experiences,
      certifications: certs,
      publications: pubs,
      awards: awards,
      references: refs,
    );

    // Use provider to create account with extracted data
    final success = await p.submitExtractedCvAndCreateAccount(finalResult);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Account created successfully with CV data!'),
          backgroundColor: Colors.green,
        ),
      );
      widget.onSuccess();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(p.generalError ?? 'Failed to create account'),
          backgroundColor: Colors.red,
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

  Widget _buildFileSelection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.upload_file, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Upload Your CV',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Supported formats: PDF, DOC, DOCX, TXT • Max 10MB',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.attach_file),
                    label: const Text('Choose File'),
                    onPressed: _pickFile,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Extract Data'),
                    onPressed: _isExtracting ? null : _runExtraction,
                  ),
                ),
              ],
            ),
            if (_pickedFilename != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[100]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green[600], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _pickedFilename!,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          color: Colors.green[800],
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, size: 18, color: Colors.green[600]),
                      onPressed: _resetSection,
                    ),
                  ],
                ),
              ),
            ],
            if (_isExtracting) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Extracting data from CV...',
                    style: GoogleFonts.poppins(
                      color: Colors.blue[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
            if (_lastError != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[100]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[600], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _lastError!,
                        style: GoogleFonts.poppins(
                          color: Colors.red[800],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewCard() {
    if (_result == null) return const SizedBox.shrink();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.preview, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Extracted Preview',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _buildPreviewItem('Name', _result!.personalProfile['name'] ?? '-'),
                _buildPreviewItem('Email', _result!.personalProfile['email'] ?? '-'),
                _buildPreviewItem('Contact', _result!.personalProfile['contactNumber'] ?? '-'),
                _buildPreviewItem('Education', '${_result!.educationalProfile.length} entries'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableForm() {
    if (!_showForm || _result == null || _fields.isEmpty) return const SizedBox.shrink();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.edit_note, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Review & Edit Extracted Data',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildFormSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildFormSection() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Personal Information', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 12),
          _labeledField('Full Name', _fields['name']),
          const SizedBox(height: 12),
          _labeledField('Email', _fields['email']),
          const SizedBox(height: 12),
          _labeledField('Contact Number', _fields['contactNumber']),
          const SizedBox(height: 12),
          _labeledField('Nationality', _fields['nationality']),
          const SizedBox(height: 12),
          _labeledField('Professional Summary', _fields['summary'], maxLines: 3),
          const SizedBox(height: 12),
          _labeledField('Skills (comma separated)', _fields['skills']),

          if (_result!.educationalProfile.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text('Education History', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 12),
            ..._result!.educationalProfile.asMap().entries.map((e) {
              final i = e.key;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Education ${i + 1}', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 8),
                  _labeledField('Institution', _fields['edu_institution_$i']),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _labeledField('Duration', _fields['edu_duration_$i'])),
                      const SizedBox(width: 12),
                      Expanded(child: _labeledField('Major/Field', _fields['edu_major_$i'])),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _labeledField('Marks/CGPA', _fields['edu_marks_$i']),
                  const SizedBox(height: 16),
                ],
              );
            }).toList(),
          ],

          const SizedBox(height: 12),
          _labeledField('Work Experiences', _fields['experiences'], maxLines: 4),
          const SizedBox(height: 12),
          _labeledField('Certifications', _fields['certifications'], maxLines: 3),
          const SizedBox(height: 12),
          _labeledField('Publications', _fields['publications'], maxLines: 3),
          const SizedBox(height: 12),
          _labeledField('Awards', _fields['awards'], maxLines: 3),
          const SizedBox(height: 12),
          _labeledField('References', _fields['references'], maxLines: 3),

          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _resetSection,
                  child: const Text('Start Over'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _acceptAndFill,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Create Account with CV Data'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: widget.onManualContinue,
              child: const Text('Continue Manual Registration Instead'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _labeledField(String label, TextEditingController? controller, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[400]!),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    for (final c in _fields.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildFileSelection(),
        if (_result != null) ...[
          const SizedBox(height: 16),
          _buildPreviewCard(),
        ],
        if (_showForm) ...[
          const SizedBox(height: 16),
          _buildEditableForm(),
        ],
      ],
    );
  }
}