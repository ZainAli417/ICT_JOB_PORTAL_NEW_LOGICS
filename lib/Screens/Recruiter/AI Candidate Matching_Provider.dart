import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../main.dart';
import 'LIst_of_Applicants_provider.dart';

/// Provider for AI-powered applicant matching using Gemini
class AIMatchProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // Replace with your actual Gemini API key
  static const String _geminiApiUrl ='https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-lite:generateContent';

  // State management
  bool _isAnalyzing = false;
  String? _error;
  final Map<String, AIMatchResult> _matchResults = {};
  final Map<String, bool> _isProcessing = {};
  int _totalApplicants = 0;
  int _processedApplicants = 0;

  // Getters
  bool get isAnalyzing => _isAnalyzing;
  String? get error => _error;
  Map<String, AIMatchResult> get matchResults => Map.from(_matchResults);
  double get progress => _totalApplicants > 0
      ? _processedApplicants / _totalApplicants
      : 0.0;
  int get processedCount => _processedApplicants;
  int get totalCount => _totalApplicants;

  /// Get match result for specific applicant
  AIMatchResult? getMatchResult(String applicantId) {
    return _matchResults[applicantId];
  }

  /// Check if applicant is being processed
  bool isProcessingApplicant(String applicantId) {
    return _isProcessing[applicantId] ?? false;
  }

  /// Main method to analyze all applicants for a job
  Future<void> analyzeApplicants({
    required String jobId,
    required List<ApplicantRecord> applicants,
  }) async {
    if (_isAnalyzing) {
      debugPrint('⚠️ Analysis already in progress');
      return;
    }

    _isAnalyzing = true;
    _error = null;
    _matchResults.clear();
    _isProcessing.clear();
    _totalApplicants = applicants.length;
    _processedApplicants = 0;
    notifyListeners();

    try {
      debugPrint('🚀 Starting AI analysis for ${applicants.length} applicants');

      // Fetch job data
      final jobData = await _fetchJobData(jobId);
      if (jobData == null) {
        throw Exception('Job data not found for ID: $jobId');
      }

      debugPrint('✅ Job data fetched: ${jobData['title']}');

      // Process applicants in parallel (with rate limiting)
      await _processApplicantsInBatches(applicants, jobData);

      debugPrint('🎉 Analysis complete! Processed $_processedApplicants applicants');

    } catch (e, stackTrace) {
      _error = e.toString();
      debugPrint('❌ Error during analysis: $e');
      debugPrint('Stack trace: $stackTrace');
    } finally {
      _isAnalyzing = false;
      notifyListeners();
    }
  }

  /// Fetch job data from Firestore
  Future<Map<String, dynamic>?> _fetchJobData(String jobId) async {
    try {
      final doc = await _firestore
          .collection('Posted_jobs_public')
          .doc(jobId)
          .get();

      if (!doc.exists) {
        debugPrint('❌ Job document not found: $jobId');
        return null;
      }

      return doc.data();
    } catch (e) {
      debugPrint('❌ Error fetching job data: $e');
      return null;
    }
  }

  /// Process applicants in batches to avoid rate limiting
  Future<void> _processApplicantsInBatches(
      List<ApplicantRecord> applicants,
      Map<String, dynamic> jobData,
      ) async {
    const batchSize = 5; // Process 5 at a time
    const delayBetweenBatches = Duration(milliseconds: 1000);

    for (var i = 0; i < applicants.length; i += batchSize) {
      final end = (i + batchSize < applicants.length)
          ? i + batchSize
          : applicants.length;

      final batch = applicants.sublist(i, end);

      // Process batch in parallel
      await Future.wait(
        batch.map((applicant) => _analyzeApplicant(applicant, jobData)),
      );

      // Add delay between batches to respect rate limits
      if (end < applicants.length) {
        await Future.delayed(delayBetweenBatches);
      }
    }
  }

  /// Analyze single applicant against job requirements
  Future<void> _analyzeApplicant(
      ApplicantRecord applicant,
      Map<String, dynamic> jobData,
      ) async {
    final applicantId = applicant.userId;

    try {
      _isProcessing[applicantId] = true;
      notifyListeners();

      debugPrint('🔍 Analyzing applicant: ${applicant.name}');

      // Build prompt for Gemini
      final prompt = _buildMatchingPrompt(applicant, jobData);

      // Call Gemini API
      final response = await _callGeminiAPI(prompt);

      // Parse response
      final matchResult = _parseGeminiResponse(response, applicant);

      // Store result
      _matchResults[applicantId] = matchResult;
      _processedApplicants++;

      debugPrint('✅ Analyzed ${applicant.name}: ${matchResult.overallScore}%');

    } catch (e) {
      debugPrint('❌ Error analyzing ${applicant.name}: $e');

      // Store error result
      _matchResults[applicantId] = AIMatchResult(
        applicantId: applicantId,
        applicantName: applicant.name,
        overallScore: 0,
        skillsMatch: 0,
        experienceMatch: 0,
        educationMatch: 0,
        strengths: [],
        weaknesses: ['Analysis failed: $e'],
        recommendation: 'Unable to analyze',
        detailedAnalysis: 'An error occurred during analysis',
        timestamp: DateTime.now(),
      );

    } finally {
      _isProcessing[applicantId] = false;
      notifyListeners();
    }
  }

  /// Build comprehensive prompt for Gemini
  String _buildMatchingPrompt(
      ApplicantRecord applicant,
      Map<String, dynamic> jobData,
      ) {
    // Build work experience details
    String workExperienceDetails = '';
    if (applicant.experiences.isNotEmpty) {
      workExperienceDetails = applicant.experiences.map((exp) {
        return '''
  - Position: ${exp['text'] ?? 'N/A'}
    Duration: ${exp['duration'] ?? 'N/A'}
    Details: ${exp['description'] ?? 'N/A'}''';
      }).join('\n');
    } else {
      workExperienceDetails = 'No work experience provided';
    }

    // Build education details
    String educationDetails = '';
    if (applicant.educations.isNotEmpty) {
      educationDetails = applicant.educations.map((edu) {
        return '''
  - Degree: ${edu['majorSubjects'] ?? 'N/A'}
    Institution: ${edu['institutionName'] ?? 'N/A'}
    Duration: ${edu['duration'] ?? 'N/A'}
    CGPA/Marks: ${edu['marksOrCgpa'] ?? 'N/A'}''';
      }).join('\n');
    } else {
      educationDetails = 'No education details provided';
    }

    return '''
You are an expert HR analyst and recruiter. Compare this candidate's profile against the job requirements and provide an objective numerical match score.

═══════════════════════════════════════════════════════════
                         JOB REQUIREMENTS
═══════════════════════════════════════════════════════════

Job Title: ${jobData['title'] ?? 'N/A'}
Company: ${jobData['company'] ?? 'N/A'}
Department: ${jobData['department'] ?? 'N/A'}
Location: ${jobData['location'] ?? 'N/A'}
Job Type: ${jobData['nature'] ?? 'N/A'}
Work Mode: ${(jobData['workModes'] as List?)?.join(', ') ?? 'N/A'}
Experience Required: ${jobData['experience'] ?? 'N/A'}
Salary Range: ${jobData['salary'] ?? 'N/A'}
Application Deadline: ${jobData['deadline'] ?? 'N/A'}

Job Description:
${jobData['description'] ?? 'N/A'}

Key Responsibilities:
${jobData['responsibilities'] ?? 'N/A'}

Required Qualifications:
${jobData['qualifications'] ?? 'N/A'}

Required Skills:
${(jobData['skills'] as List?)?.join(', ') ?? 'N/A'}

Benefits Offered:
${(jobData['benefits'] as List?)?.join(', ') ?? 'N/A'}

Additional Instructions:
${jobData['instructions'] ?? 'N/A'}

═══════════════════════════════════════════════════════════
                       CANDIDATE PROFILE
═══════════════════════════════════════════════════════════


Professional Summary/Objectives:
${applicant.summary.isNotEmpty ? applicant.summary : applicant.objectives.isNotEmpty ? applicant.objectives : 'No summary provided'}

Total Years of Experience: ${applicant.experienceYears} years

Work Experience:
$workExperienceDetails

Education:
$educationDetails

Skills:
${applicant.skills.isNotEmpty ? applicant.skills.join(', ') : 'No skills listed'}

Certifications:
${applicant.certifications.isNotEmpty ? applicant.certifications.join(', ') : 'No certifications'}

Publications/Research:
${applicant.publications.isNotEmpty ? applicant.publications.join(', ') : 'No publications'}

Awards/Achievements:
${applicant.awards.isNotEmpty ? applicant.awards.join(', ') : 'No awards'}

═══════════════════════════════════════════════════════════
                      ANALYSIS INSTRUCTIONS
═══════════════════════════════════════════════════════════

Compare and contrast the candidate's profile with the job requirements. Evaluate:

1. **Skills Alignment**: Do the candidate's skills match what the job needs?
2. **Experience Relevance**: Does their work experience align with job responsibilities?
3. **Education Fit**: Does their educational background meet requirements?
4. **Location Compatibility**: Is the candidate's location suitable for the job?
5. **Overall Suitability**: Holistically, is this candidate a good fit?

**IMPORTANT**: 
- Provide objective numerical scores (0-100) based purely on your analysis
- Do NOT use any predefined weightings or percentages
- Let the data speak for itself
- Be critical but fair
- Consider both direct matches and transferable skills/experience

Provide your response ONLY as a JSON object with this exact structure:
{
  "overallScore": <number between 0-100>,
  "skillsMatch": <number between 0-100>,
  "experienceMatch": <number between 0-100>,
  "educationMatch": <number between 0-100>,
  "locationMatch": <number between 0-100>,
  "strengths": [<array of 3-5 specific strengths as strings>],
  "weaknesses": [<array of 3-5 specific gaps or areas for improvement as strings>],
  "recommendation": "<one of: Highly Recommended|Recommended|Consider|Not Recommended>",
  "detailedAnalysis": "<detailed 2-3 paragraph analysis explaining your scoring and reasoning>"
}

Return ONLY the JSON object, no markdown formatting, no additional text.
''';
  }

  /// Call Gemini API
  Future<String> _callGeminiAPI(String prompt) async {
    try {
      final response = await http.post(
      //  Uri.parse('$_geminiApiUrl?key=${Env.geminiApiKey}'),
        Uri.parse('$_geminiApiUrl?key=${Env.geminiApiKey}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.4,
            'topK': 32,
            'topP': 1,
            'maxOutputTokens': 2048,
          }
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Gemini API error: ${response.statusCode} - ${response.body}');
      }

      final data = jsonDecode(response.body);
      final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];

      if (text == null) {
        throw Exception('Invalid response from Gemini API');
      }

      return text;

    } catch (e) {
      debugPrint('❌ Gemini API call failed: $e');
      rethrow;
    }
  }

  /// Parse Gemini response into structured data
  AIMatchResult _parseGeminiResponse(String response, ApplicantRecord applicant) {
    try {
      // Extract JSON from response (remove markdown if present)
      String jsonStr = response.trim();
      if (jsonStr.startsWith('```json')) {
        jsonStr = jsonStr.substring(7);
      }
      if (jsonStr.endsWith('```')) {
        jsonStr = jsonStr.substring(0, jsonStr.length - 3);
      }
      jsonStr = jsonStr.trim();

      final data = jsonDecode(jsonStr);

      return AIMatchResult(
        applicantId: applicant.userId,
        applicantName: applicant.name,
        overallScore: (data['overallScore'] as num?)?.toInt() ?? 0,
        skillsMatch: (data['skillsMatch'] as num?)?.toInt() ?? 0,
        experienceMatch: (data['experienceMatch'] as num?)?.toInt() ?? 0,
        educationMatch: (data['educationMatch'] as num?)?.toInt() ?? 0,
        strengths: List<String>.from(data['strengths'] ?? []),
        weaknesses: List<String>.from(data['weaknesses'] ?? []),
        recommendation: data['recommendation'] ?? 'Unknown',
        detailedAnalysis: data['detailedAnalysis'] ?? '',
        timestamp: DateTime.now(),
      );

    } catch (e) {
      debugPrint('❌ Error parsing Gemini response: $e');
      debugPrint('Response was: $response');

      // Return default result on parse error
      return AIMatchResult(
        applicantId: applicant.userId,
        applicantName: applicant.name,
        overallScore: 0,
        skillsMatch: 0,
        experienceMatch: 0,
        educationMatch: 0,
        strengths: [],
        weaknesses: ['Unable to parse AI response'],
        recommendation: 'Unknown',
        detailedAnalysis: 'Analysis parsing failed',
        timestamp: DateTime.now(),
      );
    }
  }

  /// Clear all results
  void clearResults() {
    _matchResults.clear();
    _isProcessing.clear();
    _error = null;
    _processedApplicants = 0;
    _totalApplicants = 0;
    notifyListeners();
  }

  /// Get sorted applicants by match score
  List<MapEntry<String, AIMatchResult>> getSortedResults({
    bool descending = true,
  }) {
    final entries = _matchResults.entries.toList();
    entries.sort((a, b) => descending
        ? b.value.overallScore.compareTo(a.value.overallScore)
        : a.value.overallScore.compareTo(b.value.overallScore));
    return entries;
  }
}

/// Data class for AI match results
class AIMatchResult {
  final String applicantId;
  final String applicantName;
  final int overallScore;
  final int skillsMatch;
  final int experienceMatch;
  final int educationMatch;
  final List<String> strengths;
  final List<String> weaknesses;
  final String recommendation;
  final String detailedAnalysis;
  final DateTime timestamp;

  AIMatchResult({
    required this.applicantId,
    required this.applicantName,
    required this.overallScore,
    required this.skillsMatch,
    required this.experienceMatch,
    required this.educationMatch,
    required this.strengths,
    required this.weaknesses,
    required this.recommendation,
    required this.detailedAnalysis,
    required this.timestamp,
  });

  /// Get color based on score
  Color getScoreColor() {
    if (overallScore >= 80) return const Color(0xFF10B981); // Green
    if (overallScore >= 60) return const Color(0xFF3B82F6); // Blue
    if (overallScore >= 40) return const Color(0xFFF59E0B); // Orange
    return const Color(0xFFEF4444); // Red
  }

  /// Get recommendation badge color
  Color getRecommendationColor() {
    switch (recommendation.toLowerCase()) {
      case 'highly recommended':
        return const Color(0xFF10B981);
      case 'recommended':
        return const Color(0xFF3B82F6);
      case 'consider':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFFEF4444);
    }
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'applicantId': applicantId,
      'applicantName': applicantName,
      'overallScore': overallScore,
      'skillsMatch': skillsMatch,
      'experienceMatch': experienceMatch,
      'educationMatch': educationMatch,
      'strengths': strengths,
      'weaknesses': weaknesses,
      'recommendation': recommendation,
      'detailedAnalysis': detailedAnalysis,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Create from JSON
  factory AIMatchResult.fromJson(Map<String, dynamic> json) {
    return AIMatchResult(
      applicantId: json['applicantId'] ?? '',
      applicantName: json['applicantName'] ?? '',
      overallScore: json['overallScore'] ?? 0,
      skillsMatch: json['skillsMatch'] ?? 0,
      experienceMatch: json['experienceMatch'] ?? 0,
      educationMatch: json['educationMatch'] ?? 0,
      strengths: List<String>.from(json['strengths'] ?? []),
      weaknesses: List<String>.from(json['weaknesses'] ?? []),
      recommendation: json['recommendation'] ?? '',
      detailedAnalysis: json['detailedAnalysis'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }
}

// Note: Make sure to import ApplicantRecord from your applicants provider file