import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

class CvExtractionResult {
  final String rawText;
  final Map<String, dynamic> personalProfile;
  final List<Map<String, String>> educationalProfile;
  final String professionalSummary;
  final List<Map<String, dynamic>> experiences;
  final List<String> certifications;
  final List<String> publications;
  final List<String> awards;
  final List<String> references;

  CvExtractionResult({
    required this.rawText,
    required this.personalProfile,
    required this.educationalProfile,
    required this.professionalSummary,
    required this.experiences,
    required this.certifications,
    required this.publications,
    required this.awards,
    required this.references,
  });

  factory CvExtractionResult.empty() => CvExtractionResult(
    rawText: '',
    personalProfile: {},
    educationalProfile: [],
    professionalSummary: '',
    experiences: [],
    certifications: [],
    publications: [],
    awards: [],
    references: [],
  );

  factory CvExtractionResult.fromJson(Map<String, dynamic> j) {
    print('🔍 [DEBUG] Creating CvExtractionResult from JSON: ${j.keys}');

    final personal = (j['personalProfile'] as Map?)?.map((k, v) => MapEntry(k.toString(), v)) ?? {};
    final edu = <Map<String, String>>[];

    if (j['educationalProfile'] is List) {
      for (final e in (j['educationalProfile'] as List)) {
        if (e is Map) {
          edu.add({
            'institutionName': (e['institutionName'] ?? '').toString(),
            'duration': (e['duration'] ?? '').toString(),
            'majorSubjects': (e['majorSubjects'] ?? '').toString(),
            'marksOrCgpa': (e['marksOrCgpa'] ?? '').toString(),
          });
        }
      }
    }

    final exps = <Map<String, dynamic>>[];
    if (j['experiences'] is List) {
      for (final e in (j['experiences'] as List)) {
        if (e is Map) exps.add(Map<String, dynamic>.from(e));
      }
    }

    List<String> listFrom(dynamic v) {
      if (v is List) return v.map((e) => e.toString()).toList();
      if (v is String && v.isNotEmpty) return v.split('\n').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
      return [];
    }

    print('🔍 [DEBUG] Personal profile extracted: ${personal.keys}');
    print('🔍 [DEBUG] Education entries: ${edu.length}');
    print('🔍 [DEBUG] Experiences: ${exps.length}');

    return CvExtractionResult(
      rawText: (j['rawText'] ?? j['text'] ?? '').toString(),
      personalProfile: personal,
      educationalProfile: edu,
      professionalSummary: (j['professionalSummary'] ?? '').toString(),
      experiences: exps,
      certifications: listFrom(j['certifications']),
      publications: listFrom(j['publications']),
      awards: listFrom(j['awards']),
      references: listFrom(j['references']),
    );
  }
}

class CvExtractor {
  final String geminiApiKey;
  final String? cloudConvertApiKey; // Get free key from https://cloudconvert.com/
  final Duration timeout;

  CvExtractor({
    required this.geminiApiKey,
    this.cloudConvertApiKey,
    this.timeout = const Duration(seconds: 90),
  });

  /// Convert DOC/DOCX to PDF using CloudConvert API
  /// Free tier: 10 conversions per day
  /// Sign up at: https://cloudconvert.com/
  Future<Uint8List> _convertDocToPdf(Uint8List docBytes, String filename) async {
    if (cloudConvertApiKey == null || cloudConvertApiKey!.isEmpty) {
      throw Exception(
          'CloudConvert API key required for DOC/DOCX conversion.\n'
              'Get your free API key at: https://cloudconvert.com/\n'
              'Free tier: 10 conversions/day'
      );
    }

    print('🔄 [CloudConvert] Starting DOC/DOCX to PDF conversion...');

    // Step 1: Create a job
    final jobUrl = Uri.parse('https://api.cloudconvert.com/v2/jobs');

    final jobPayload = {
      "tasks": {
        "upload-my-file": {
          "operation": "import/upload"
        },
        "convert-my-file": {
          "operation": "convert",
          "input": "upload-my-file",
          "output_format": "pdf",
          "engine": "office",
        },
        "export-my-file": {
          "operation": "export/url",
          "input": "convert-my-file"
        }
      }
    };

    final jobHeaders = {
      'Authorization': 'Bearer $cloudConvertApiKey',
      'Content-Type': 'application/json',
    };

    print('📤 [CloudConvert] Creating conversion job...');
    final jobResp = await http.post(jobUrl, headers: jobHeaders, body: jsonEncode(jobPayload)).timeout(timeout);

    if (jobResp.statusCode != 201) {
      throw Exception('CloudConvert job creation failed: ${jobResp.statusCode} ${jobResp.body}');
    }

    final jobData = jsonDecode(jobResp.body)['data'];
    final uploadTaskId = jobData['tasks'][0]['id'];
    final uploadUrl = jobData['tasks'][0]['result']['form']['url'];
    final uploadParams = jobData['tasks'][0]['result']['form']['parameters'] as Map<String, dynamic>;

    print('📤 [CloudConvert] Uploading file...');

    // Step 2: Upload the file
    final uploadRequest = http.MultipartRequest('POST', Uri.parse(uploadUrl));

    // Add all required parameters from CloudConvert
    uploadParams.forEach((key, value) {
      uploadRequest.fields[key] = value.toString();
    });

    // Add the file
    uploadRequest.files.add(http.MultipartFile.fromBytes(
      'file',
      docBytes,
      filename: filename,
    ));

    final uploadResp = await uploadRequest.send().timeout(timeout);

    if (uploadResp.statusCode != 201 && uploadResp.statusCode != 200) {
      throw Exception('CloudConvert file upload failed: ${uploadResp.statusCode}');
    }

    print('⏳ [CloudConvert] Waiting for conversion to complete...');

    // Step 3: Wait for conversion to complete and get result
    final jobId = jobData['id'];
    String? downloadUrl;

    for (int i = 0; i < 30; i++) {
      await Future.delayed(const Duration(seconds: 2));

      final statusUrl = Uri.parse('https://api.cloudconvert.com/v2/jobs/$jobId');
      final statusResp = await http.get(statusUrl, headers: jobHeaders);

      if (statusResp.statusCode == 200) {
        final statusData = jsonDecode(statusResp.body)['data'];
        final status = statusData['status'];

        print('🔍 [CloudConvert] Job status: $status');

        if (status == 'finished') {
          final exportTask = (statusData['tasks'] as List).firstWhere(
                (task) => task['operation'] == 'export/url',
          );
          downloadUrl = exportTask['result']['files'][0]['url'];
          break;
        } else if (status == 'error') {
          throw Exception('CloudConvert conversion failed: ${statusData['message']}');
        }
      }
    }

    if (downloadUrl == null) {
      throw Exception('CloudConvert conversion timeout');
    }

    print('📥 [CloudConvert] Downloading converted PDF...');

    // Step 4: Download the converted PDF
    final pdfResp = await http.get(Uri.parse(downloadUrl));

    if (pdfResp.statusCode != 200) {
      throw Exception('Failed to download converted PDF: ${pdfResp.statusCode}');
    }

    print('✅ [CloudConvert] Conversion completed successfully!');
    return pdfResp.bodyBytes;
  }

  Future<CvExtractionResult> extractFromFileBytes(Uint8List bytes, {required String filename}) async {
    final ext = filename.toLowerCase();
    final isPdf = ext.endsWith('.pdf');
    final isDoc = ext.endsWith('.doc') || ext.endsWith('.docx');
    final isText = ext.endsWith('.txt');

    print('📁 [DEBUG] Processing file: $filename, PDF: $isPdf, DOC: $isDoc, TEXT: $isText');

    Uint8List processedBytes = bytes;
    String processedFilename = filename;

    // Convert DOC/DOCX to PDF first
    if (isDoc) {
      print('🔄 [DEBUG] Converting DOC/DOCX to PDF...');
      processedBytes = await _convertDocToPdf(bytes, filename);
      processedFilename = filename.replaceAll(RegExp(r'\.(doc|docx)$', caseSensitive: false), '.pdf');
      print('✅ [DEBUG] Conversion complete, processing as PDF...');
    }

    final promptText = '''
Extract information from this CV/resume and return ONLY a JSON object with the following structure:

{
  "rawText": "full extracted text from the document",
  "personalProfile": {
    "name": "full name",
    "email": "email address", 
    "contactNumber": "phone number",
    "nationality": "nationality",
    "skills": ["skill1", "skill2", "skill3"]
  },
  "educationalProfile": [
    {
      "institutionName": "university/school name",
      "duration": "start year - end year",
      "majorSubjects": "field of study",
      "marksOrCgpa": "GPA or marks"
    }
  ],
  "professionalSummary": "brief professional summary",
  "experiences": [
    {
      "text": "job title, company, duration, responsibilities"
    }
  ],
  "certifications": ["cert1", "cert2"],
  "publications": ["pub1", "pub2"], 
  "awards": ["award1", "award2"],
  "references": ["reference1", "reference2"]
}

IMPORTANT: 
- Return ONLY the JSON object, no other text
- Use empty strings or empty arrays for missing fields
- Extract as much information as possible from the document
''';

    final mimeType = (isDoc || processedFilename.endsWith('.pdf')) ? "application/pdf" : "text/plain";
    final b64 = base64Encode(processedBytes);

    final payload = {
      "contents": [
        {
          "parts": [
            {
              "inlineData": {
                "mimeType": mimeType,
                "data": b64
              }
            },
            {
              "text": promptText
            }
          ]
        }
      ],
      "generationConfig": {
        "temperature": 0.4,
        "topK": 32,
        "topP": 1,
        "maxOutputTokens": 8192,
      }
    };

    final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$geminiApiKey'
    );

    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    print('🚀 [DEBUG] Sending request to Gemini API...');

    try {
      final resp = await http.post(url, headers: headers, body: jsonEncode(payload)).timeout(timeout);

      print('📥 [DEBUG] Response status: ${resp.statusCode}');

      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        throw Exception('API request failed: ${resp.statusCode} ${resp.body}');
      }

      final body = jsonDecode(resp.body);
      print('🔍 [DEBUG] Full API response structure: ${body.keys}');

      String responseText = '';

      if (body['candidates'] != null && body['candidates'].isNotEmpty) {
        final candidate = body['candidates'][0];
        if (candidate['content'] != null && candidate['content']['parts'] != null) {
          final parts = candidate['content']['parts'] as List;
          for (final part in parts) {
            if (part['text'] != null) {
              responseText += part['text'];
            }
          }
        }
      }

      print('📝 [DEBUG] Extracted response text length: ${responseText.length}');

      Map<String, dynamic> parsedJson = {};

      if (responseText.isNotEmpty) {
        try {
          String cleanText = responseText.replaceAll('```json', '').replaceAll('```', '').trim();
          parsedJson = jsonDecode(cleanText) as Map<String, dynamic>;
          print('✅ [DEBUG] Successfully parsed JSON response');
        } catch (e) {
          print('❌ [DEBUG] Failed to parse JSON: $e');
          return CvExtractionResult.fromJson({
            'rawText': responseText,
            'text': responseText,
          });
        }
      } else {
        throw Exception('No text content found in API response');
      }

      return CvExtractionResult.fromJson(parsedJson);

    } catch (e) {
      print('❌ [DEBUG] Extraction error: $e');
      rethrow;
    }
  }

  /// Helper method to check if file type is supported
  static bool isSupportedFileType(String filename) {
    final ext = filename.toLowerCase();
    return ext.endsWith('.pdf') ||
        ext.endsWith('.doc') ||
        ext.endsWith('.docx') ||
        ext.endsWith('.txt');
  }

  /// Get user-friendly file type message
  static String getSupportedFormatsMessage() {
    return 'Supported formats: PDF, DOC, DOCX, TXT\n'
        'DOC/DOCX conversion uses CloudConvert (10 free/day)';
  }
}



class CvUploadDialog extends StatefulWidget {
  final CvExtractor extractor;
  final dynamic provider;
  final void Function(CvExtractionResult result)? onComplete;

  const CvUploadDialog({Key? key, required this.extractor, this.provider, this.onComplete}) : super(key: key);

  @override
  State<CvUploadDialog> createState() => _CvUploadDialogState();
}

class _CvUploadDialogState extends State<CvUploadDialog> {
  Uint8List? _pickedBytes;
  String? _pickedFilename;
  bool _isExtracting = false;
  String? _lastError;
  CvExtractionResult? _result;
  final Map<String, TextEditingController> _fields = {};
  Future<void> _pickFile() async {
    setState(() { _lastError = null; });
    try {
      final res = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf', 'txt', 'doc', 'docx'], withData: true);
      if (res == null || res.files.isEmpty) return;
      final f = res.files.first;
      if (f.size > 10 * 1024 * 1024) { setState(() { _lastError = 'File too large'; }); return; }
      setState(() { _pickedBytes = f.bytes; _pickedFilename = f.name; _result = null; _fields.clear(); });
    } catch (e) { setState(() { _lastError = 'File pick failed: $e'; }); }
  }

  Future<void> _runExtraction() async {
    if (_pickedBytes == null || _pickedFilename == null) { setState(() { _lastError = 'Please pick a file'; }); return; }
    setState(() { _isExtracting = true; _lastError = null; _result = null; });
    try {
      final r = await widget.extractor.extractFromFileBytes(_pickedBytes!, filename: _pickedFilename!);
      _result = r;
      _populateControllers(r);
    } catch (e) { _lastError = 'Extraction failed: $e'; }
    setState(() { _isExtracting = false; });
  }

  void _populateControllers(CvExtractionResult r) {
    void ensure(String k, String v) { _fields.putIfAbsent(k, () => TextEditingController(text: v)); }
    final p = r.personalProfile;
    ensure('name', (p['name'] ?? '').toString());
    ensure('email', (p['email'] ?? '').toString());
    ensure('contactNumber', (p['contactNumber'] ?? '').toString());
    ensure('nationality', (p['nationality'] ?? '').toString());
    ensure('summary', (p['summary'] ?? r.professionalSummary ?? '').toString());
    ensure('skills', (p['skills'] is List) ? (p['skills'] as List).join(', ') : (p['skills'] ?? '').toString());
    ensure('socialLinks', (p['socialLinks'] is List) ? (p['socialLinks'] as List).join('\n') : (p['socialLinks'] ?? '').toString());
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
    setState(() {});
  }

  void _acceptAndFill() {
    if (_result == null) return;
    final finalPersonal = <String, dynamic>{};
    finalPersonal['name'] = _fields['name']?.text ?? '';
    finalPersonal['email'] = _fields['email']?.text ?? '';
    finalPersonal['contactNumber'] = _fields['contactNumber']?.text ?? '';
    finalPersonal['nationality'] = _fields['nationality']?.text ?? '';
    finalPersonal['summary'] = _fields['summary']?.text ?? '';
    finalPersonal['skills'] = (_fields['skills']?.text ?? '').split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    final education = <Map<String, String>>[];
    for (var i = 0; i < _result!.educationalProfile.length; i++) {
      education.add({
        'institutionName': _fields['edu_institution_$i']?.text ?? '',
        'duration': _fields['edu_duration_$i']?.text ?? '',
        'majorSubjects': _fields['edu_major_$i']?.text ?? '',
        'marksOrCgpa': _fields['edu_marks_$i']?.text ?? '',
      });
    }
    final experiences = (_fields['experiences']?.text ?? '').split('\n\n').map((s) => {'text': s.trim()}).where((m) => (m['text'] ?? '').toString().isNotEmpty).toList();
    final certs = (_fields['certifications']?.text ?? '').split('\n').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    final pubs = (_fields['publications']?.text ?? '').split('\n').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    final awards = (_fields['awards']?.text ?? '').split('\n').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    final refs = (_fields['references']?.text ?? '').split('\n').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
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
    try {
      final prov = widget.provider;
      if (prov != null) {
        if (finalPersonal['name'] != null && prov.nameController != null) prov.nameController.text = finalPersonal['name'];
        if (finalPersonal['email'] != null && prov.emailController != null) prov.emailController.text = finalPersonal['email'];
        if (finalPersonal['contactNumber'] != null && prov.contactNumberController != null) prov.contactNumberController.text = finalPersonal['contactNumber'];
        if (finalPersonal['nationality'] != null && prov.nationalityController != null) prov.nationalityController.text = finalPersonal['nationality'];
        if (finalPersonal['summary'] != null && prov.summaryController != null) prov.summaryController.text = finalPersonal['summary'];
        if (finalPersonal['skills'] is List && prov.skills != null) {
          prov.skills.clear();
          prov.skills.addAll((finalPersonal['skills'] as List).map((e) => e.toString()));
        }
        prov.educationalProfile.clear();
        for (final ed in education) {
          prov.addEducation(
            institutionName: ed['institutionName'] ?? '',
            duration: ed['duration'] ?? '',
            majorSubjects: ed['majorSubjects'] ?? '',
            marksOrCgpa: ed['marksOrCgpa'] ?? '',
          );
        }
      }
    } catch (_) {}
    if (widget.onComplete != null) widget.onComplete!(finalResult);
    if (Navigator.canPop(context)) Navigator.of(context).pop();
  }

  Widget _previewArea() {
    if (_pickedFilename == null) return const Text('No file selected.');
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Selected: $_pickedFilename', style: const TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      if (_result == null) Text('No extraction run yet. Click Extract.', style: const TextStyle(color: Colors.black54)) else Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Name: ${_result!.personalProfile['name'] ?? '-'}'),
        Text('Email: ${_result!.personalProfile['email'] ?? '-'}'),
        Text('Contact: ${_result!.personalProfile['contactNumber'] ?? '-'}'),
        Text('Skills: ${(_result!.personalProfile['skills'] ?? []).join(', ')}'),
        const SizedBox(height: 8),
        Text('Education entries: ${_result!.educationalProfile.length}'),
      ])
    ]);
  }

  Widget _editableForm() {
    if (_result == null || _fields.isEmpty) return const SizedBox.shrink();
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const SizedBox(height: 12),
      Text('Personal (editable)', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      _labeled('Full Name', _fields['name']),
      const SizedBox(height: 8),
      _labeled('Email', _fields['email']),
      const SizedBox(height: 8),
      _labeled('Contact', _fields['contactNumber']),
      const SizedBox(height: 8),
      _labeled('Nationality', _fields['nationality']),
      const SizedBox(height: 8),
      _labeled('Summary', _fields['summary'], maxLines: 3),
      const SizedBox(height: 8),
      _labeled('Skills (comma separated)', _fields['skills']),
      const SizedBox(height: 12),
      if (_result!.educationalProfile.isNotEmpty) Text('Education (editable)', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      ..._result!.educationalProfile.asMap().entries.map((e) {
        final i = e.key;
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Entry ${i + 1}', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          _labeled('Institution', _fields['edu_institution_$i']),
          const SizedBox(height: 6),
          Row(children: [Expanded(child: _labeled('Duration', _fields['edu_duration_$i'])), const SizedBox(width: 8), Expanded(child: _labeled('Major', _fields['edu_major_$i']))]),
          const SizedBox(height: 6),
          _labeled('Marks/CGPA', _fields['edu_marks_$i']),
          const SizedBox(height: 10),
        ]);
      }).toList(),
      const SizedBox(height: 8),
      _labeled('Experiences', _fields['experiences'], maxLines: 6),
      const SizedBox(height: 8),
      _labeled('Certifications', _fields['certifications'], maxLines: 4),
      const SizedBox(height: 8),
      _labeled('Publications', _fields['publications'], maxLines: 4),
      const SizedBox(height: 8),
      _labeled('Awards', _fields['awards'], maxLines: 3),
      const SizedBox(height: 8),
      _labeled('References', _fields['references'], maxLines: 3),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: OutlinedButton(onPressed: () { if (Navigator.canPop(context)) Navigator.of(context).pop(); }, child: const Text('Cancel'))),
        const SizedBox(width: 12),
        Expanded(child: ElevatedButton(onPressed: _acceptAndFill, child: const Text('Accept & Fill'))),
      ])
    ]);
  }

  Widget _labeled(String label, TextEditingController? c, {int maxLines = 1}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      const SizedBox(height: 6),
      TextField(controller: c, maxLines: maxLines, decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)))),
    ]);
  }

  @override
  void dispose() {
    for (final c in _fields.values) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: SingleChildScrollView(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Upload CV & Auto-fill', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).maybePop()),
              ]),
              const SizedBox(height: 6),
              Text('Upload a PDF or Txt CV. Press Extract to parse via LLM.', style: GoogleFonts.poppins(color: Colors.black54)),
              const SizedBox(height: 12),
              Row(children: [
                ElevatedButton.icon(icon: const Icon(Icons.attach_file), label: const Text('Choose file'), onPressed: _pickFile),
                const SizedBox(width: 12),
                if (_pickedFilename != null) Expanded(child: Text(_pickedFilename!, style: const TextStyle(fontWeight: FontWeight.w600))),
                const SizedBox(width: 12),
                ElevatedButton.icon(icon: const Icon(Icons.play_arrow), label: const Text('Extract'), onPressed: _isExtracting ? null : _runExtraction),
                const SizedBox(width: 8),
                if (_isExtracting) const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
              ]),
              const SizedBox(height: 12),
              if (_lastError != null) Text(_lastError!, style: const TextStyle(color: Colors.redAccent)),
              const SizedBox(height: 8),
              _previewArea(),
              const SizedBox(height: 12),
              if (_result != null) _editableForm(),
              const SizedBox(height: 8),
            ]),
          ),
        ),
      ),
    );
  }
}
