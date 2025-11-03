// lib/providers/applicants_provider.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ApplicantRecord {
  final String userId;
  final String jobId;
  final String status;
  final DateTime appliedAt;
  final Map<String, dynamic> profileSnapshot;
  final String docId;
  final JobData? jobData;

  ApplicantRecord({
    required this.userId,
    required this.jobId,
    required this.status,
    required this.appliedAt,
    required this.profileSnapshot,
    required this.docId,
    this.jobData,
  });

  // Helper to read canonical account data and profile section maps
  Map<String, dynamic> get _acct {
    final m = profileSnapshot['user_account_data'] ??
        profileSnapshot['user_Account_Data'] ??
        profileSnapshot['user_data'] ??
        <String, dynamic>{};
    return (m is Map) ? Map<String, dynamic>.from(m) : <String, dynamic>{};
  }

  Map<String, dynamic> get _prof {
    final p = profileSnapshot['user_profile_section'] ??
        profileSnapshot['user_Profile_Sections'] ??
        profileSnapshot['user_profile'] ??
        <String, dynamic>{};
    return (p is Map) ? Map<String, dynamic>.from(p) : <String, dynamic>{};
  }

  String get name {
    try {
      return _acct['name']?.toString() ??
          _acct['displayName']?.toString() ??
          'Unknown';
    } catch (e) {
      debugPrint('Error getting name: $e');
      return 'Unknown';
    }
  }

  String get email {
    try {
      return _acct['email']?.toString() ?? '';
    } catch (e) {
      debugPrint('Error getting email: $e');
      return '';
    }
  }

  String get phone {
    try {
      return _acct['phone']?.toString() ?? '';
    } catch (e) {
      debugPrint('Error getting phone: $e');
      return '';
    }
  }

  String get location {
    try {
      return _acct['location']?.toString() ?? '';
    } catch (e) {
      debugPrint('Error getting location: $e');
      return '';
    }
  }

  String get company {
    try {
      return _acct['company']?.toString() ?? '';
    } catch (e) {
      debugPrint('Error getting company: $e');
      return '';
    }
  }

  String get nationality {
    try {
      return _acct['nationality']?.toString() ?? '';
    } catch (e) {
      debugPrint('Error getting nationality: $e');
      return '';
    }
  }

  String get pictureUrl {
    try {
      return _acct['picture_url']?.toString() ??
          _prof['picture_url']?.toString() ??
          '';
    } catch (e) {
      debugPrint('Error getting picture_url: $e');
      return '';
    }
  }

  String get cvUrl {
    try {
      return _prof['cv_url']?.toString() ?? '';
    } catch (e) {
      debugPrint('Error getting cv_url: $e');
      return '';
    }
  }

  int get experienceYears {
    try {
      final value = _acct['experiences'] ?? _acct['experienceYears'];
      if (value == null) {
        // fallback: derive from experiences list length (approximate)
        final exps = experiences;
        return exps.isNotEmpty ? exps.length : 0;
      }
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      if (value is double) return value.toInt();
      return 0;
    } catch (e) {
      debugPrint('Error getting experience_years: $e');
      return 0;
    }
  }

  // profile section getters
  List<String> get skills {
    try {
      final s = _prof['skills'];
      if (s == null) return [];
      if (s is List) return s.map((e) => e.toString()).toList();
      return [];
    } catch (e) {
      debugPrint('Error getting skills: $e');
      return [];
    }
  }

  String get education {
    try {
      final edu = _prof['educations'];
      if (edu is Map) return edu['degree']?.toString() ?? '';
      if (edu is String) return edu;
      return '';
    } catch (e) {
      debugPrint('Error getting education: $e');
      return '';
    }
  }

  String get university {
    try {
      final edu = _prof['educations'];
      if (edu is Map) return edu['university']?.toString() ?? '';
      return '';
    } catch (e) {
      debugPrint('Error getting university: $e');
      return '';
    }
  }

  double get expectedSalary {
    try {
      final v = _prof['salary'] ?? _prof['Salary'];
      if (v == null) return 0.0;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is String) return double.tryParse(v.replaceAll(',', '')) ?? 0.0;
      return 0.0;
    } catch (e) {
      debugPrint('Error getting salary: $e');
      return 0.0;
    }
  }

  String get availability {
    try {
      return _prof['availability']?.toString() ?? '';
    } catch (e) {
      debugPrint('Error getting availability: $e');
      return '';
    }
  }

  String get workType {
    try {
      return _prof['workModes']?.toString() ?? '';
    } catch (e) {
      debugPrint('Error getting work_type: $e');
      return '';
    }
  }

  String get bio {
    try {
      return _prof['bio']?.toString() ?? '';
    } catch (e) {
      debugPrint('Error getting bio: $e');
      return '';
    }
  }

  String get linkedIn {
    try {
      return _prof['linkedin']?.toString() ?? _prof['linkedIn']?.toString() ?? '';
    } catch (e) {
      debugPrint('Error getting linkedin: $e');
      return '';
    }
  }

  String get github {
    try {
      return _prof['github']?.toString() ?? '';
    } catch (e) {
      debugPrint('Error getting github: $e');
      return '';
    }
  }

  List<String> get languages {
    try {
      final l = _prof['languages'];
      if (l == null) return [];
      if (l is List) return l.map((e) => e.toString()).toList();
      return [];
    } catch (e) {
      debugPrint('Error getting languages: $e');
      return [];
    }
  }

  List<String> get certifications {
    try {
      final c = _prof['certifications'];
      if (c == null) return [];
      if (c is List) return c.map((e) => e.toString()).toList();
      return [];
    } catch (e) {
      debugPrint('Error getting certifications: $e');
      return [];
    }
  }

  // New getters for additional profile fields you listed
  String get dob {
    try {
      return _prof['dob']?.toString() ?? _acct['dob']?.toString() ?? '';
    } catch (e) {
      debugPrint('Error getting dob: $e');
      return '';
    }
  }

  String get fatherName {
    try {
      return _prof['father_name']?.toString() ?? '';
    } catch (e) {
      debugPrint('Error getting father_name: $e');
      return '';
    }
  }

  List<Map<String, dynamic>> get experiences {
    try {
      final ex = _prof['experiences'];
      if (ex == null) return [];
      if (ex is List) {
        return ex.map((e) => (e is Map) ? Map<String, dynamic>.from(e) : <String, dynamic>{}).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error getting experiences: $e');
      return [];
    }
  }

  List<Map<String, dynamic>> get references {
    try {
      final r = _prof['references'];
      if (r == null) return [];
      if (r is List) {
        return r.map((e) => (e is Map) ? Map<String, dynamic>.from(e) : <String, dynamic>{}).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error getting references: $e');
      return [];
    }
  }

  ApplicantRecord copyWith({
    String? userId,
    String? jobId,
    String? status,
    DateTime? appliedAt,
    Map<String, dynamic>? profileSnapshot,
    String? docId,
    JobData? jobData,
  }) {
    return ApplicantRecord(
      userId: userId ?? this.userId,
      jobId: jobId ?? this.jobId,
      status: status ?? this.status,
      appliedAt: appliedAt ?? this.appliedAt,
      profileSnapshot: profileSnapshot ?? this.profileSnapshot,
      docId: docId ?? this.docId,
      jobData: jobData ?? this.jobData,
    );
  }
}

class JobData {
  final String jobId;
  final String title;
  final String company;
  final String location;
  final String jobType;
  final String workType;
  final double? salary;
  final dynamic experience; // Changed from String? to dynamic to handle both String and int
  final List<String> requiredSkills;

  JobData({
    required this.jobId,
    required this.title,
    required this.company,
    required this.location,
    required this.jobType,
    required this.workType,
    this.salary,
    this.experience,
    required this.requiredSkills,
  });
}

class ApplicantsProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool isLoading = true;
  String? error;
  List<ApplicantRecord> _allApplicants = [];
  List<ApplicantRecord> _filteredApplicants = [];

  // Filter options
  String searchQuery = '';
  String statusFilter = 'All';
  String experienceFilter = 'All';
  String locationFilter = 'All';
  String educationFilter = 'All';
  String availabilityFilter = 'All';
  String workTypeFilter = 'All';
  String jobFilter = 'All'; // Filter by job title
  List<String> skillsFilter = [];
  List<String> languagesFilter = [];
  double minExpectedSalary = 0;
  double maxExpectedSalary = 1000000;
  DateTimeRange? appliedDateRange;
  String sortBy = 'applied_desc';

  // Available filter options (populated from data)
  Set<String> availableExperiences = {};
  Set<String> availableLocations = {};
  Set<String> availableEducations = {};
  Set<String> availableAvailabilities = {};
  Set<String> availableWorkTypes = {};
  Set<String> availableSkills = {};
  Set<String> availableLanguages = {};
  Set<String> availableJobs = {}; // Available job titles

  ApplicantsProvider() {
    _load();
  }

  List<ApplicantRecord> get applicants => _filteredApplicants;
  List<ApplicantRecord> get allApplicants => _allApplicants;

  // Statistics
  int get totalApplicants => _allApplicants.length;
  int get filteredCount => _filteredApplicants.length;
  int get pendingCount => _allApplicants.where((a) => a.status == 'pending').length;
  int get acceptedCount => _allApplicants.where((a) => a.status == 'accepted').length;
  int get rejectedCount => _allApplicants.where((a) => a.status == 'rejected').length;

  Future<void> _load() async {
    try {
      debugPrint('🔄 ApplicantsProvider: Starting to load data...');

      // Get current user
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('No user logged in');
      }
      debugPrint('✅ Current HR user: ${currentUser.uid}');

      // Load all job seekers' applications
      await _loadAllJobSeekersApplications();

      // Populate filter options
      _populateFilterOptions();
      debugPrint('✅ Filter options populated');

      // Apply initial filters
      _applyFilters();
      debugPrint('✅ Initial filters applied');
      debugPrint('📊 Total applications found: ${_allApplicants.length}');

    } catch (e) {
      error = e.toString();
      debugPrint('❌ ApplicantsProvider load error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadAllJobSeekersApplications() async {
    try {
      debugPrint('🔍 Getting all job seeker UIDs...');

      // First, get all job seeker UIDs from job_seeker-uids collection
      final jobSeekerUidsQuery = await _firestore
          .collection('job_seeker')
          .get();

      debugPrint('📋 Found ${jobSeekerUidsQuery.docs.length} job seeker documents');

      List<String> jobSeekerUids = [];
      for (final doc in jobSeekerUidsQuery.docs) {
        // Assuming the document ID is the UID or there's a 'uid' field
        final uid = doc.id; // or doc.data()['uid'] if stored as field
        jobSeekerUids.add(uid);
        debugPrint('👤 Job seeker UID: $uid');
      }

      if (jobSeekerUids.isEmpty) {
        debugPrint('⚠️ No job seekers found');
        _allApplicants = [];
        return;
      }

      List<ApplicantRecord> allApplications = [];

      // For each job seeker, get their applications
      for (final jobSeekerUid in jobSeekerUids) {
        debugPrint('🔍 Checking applications for job seeker: $jobSeekerUid');

        try {
          final applicationsQuery = await _firestore
              .collection('applications')
              .doc(jobSeekerUid)
              .collection('applied_jobs')
              .orderBy('appliedAt', descending: true)
              .get();

          debugPrint('📄 Found ${applicationsQuery.docs.length} applications for $jobSeekerUid');

          // Process each application
          for (final appDoc in applicationsQuery.docs) {
            final appData = appDoc.data();
            final jobId = appData['jobId'] as String;

            debugPrint('💼 Processing application: Job ID: $jobId, Doc ID: ${appDoc.id}');

            // Fetch job details from Posted_jobs_public
            JobData? jobData = await _fetchJobData(jobId);

            if (jobData == null) {
              debugPrint('⚠️ Job data not found for jobId: $jobId');
              continue;
            }

            debugPrint('✅ Job data found: ${jobData.title} at ${jobData.company}');

            // Safely handle profileSnapshot with type conversion
            Map<String, dynamic> profileSnapshot = Map<String, dynamic>.from(appData['profileSnapshot'] ?? {});

            // Clean and convert any problematic fields
            profileSnapshot = _cleanProfileSnapshot(profileSnapshot);

            final applicantRecord = ApplicantRecord(
              userId: jobSeekerUid,
              jobId: jobId,
              status: appData['status'] as String? ?? 'pending',
              appliedAt: (appData['appliedAt'] as Timestamp).toDate(),
              profileSnapshot: profileSnapshot,
              docId: appDoc.id,
              jobData: jobData,
            );

            allApplications.add(applicantRecord);
            debugPrint('✅ Added application record for ${applicantRecord.name} -> ${jobData.title}');
          }
        } catch (e) {
          debugPrint('❌ Error loading applications for $jobSeekerUid: $e');
          continue; // Continue with next job seeker
        }
      }

      _allApplicants = allApplications;
      debugPrint('🎉 Total applications loaded: ${_allApplicants.length}');

      // Debug: Print sample data
      if (_allApplicants.isNotEmpty) {
        final sample = _allApplicants.first;
        debugPrint('📋 Sample application:');
        debugPrint('   - Applicant: ${sample.name}');
        debugPrint('   - Job: ${sample.jobData?.title}');
        debugPrint('   - Company: ${sample.jobData?.company}');
        debugPrint('   - Status: ${sample.status}');
        debugPrint('   - Applied: ${sample.appliedAt}');
        debugPrint('   - Education: ${sample.education}');
      }

    } catch (e) {
      debugPrint('❌ Error in _loadAllJobSeekersApplications: $e');
      throw Exception('Failed to load job seekers applications: $e');
    }
  }


  Map<String, dynamic> _cleanProfileSnapshot(Map<String, dynamic> data) {
    try {
      // Make a modifiable copy
      final raw = Map<String, dynamic>.from(data);

      // Normalize account data to 'user_account_data'
      Map<String, dynamic> accountData = {};
      if (raw.containsKey('user_account_data') && raw['user_account_data'] is Map) {
        accountData = Map<String, dynamic>.from(raw['user_account_data'] as Map);
      } else if (raw.containsKey('user_Account_Data') && raw['user_Account_Data'] is Map) {
        accountData = Map<String, dynamic>.from(raw['user_Account_Data'] as Map);
      } else if (raw.containsKey('user_data') && raw['user_data'] is Map) {
        accountData = Map<String, dynamic>.from(raw['user_data'] as Map);
      } else {
        // Pull flattened fields into accountData if present
        final possible = ['email', 'name', 'nationality', 'phone', 'picture_url', 'location', 'company', 'uid', 'experience_years'];
        for (final k in possible) {
          if (raw.containsKey(k)) accountData[k] = raw[k];
        }
      }

      // Normalize profile section to 'user_profile_section'
      Map<String, dynamic> profileSections = {};
      if (raw.containsKey('user_profile_section') && raw['user_profile_section'] is Map) {
        profileSections = Map<String, dynamic>.from(raw['user_profile_section'] as Map);
      } else if (raw.containsKey('user_Profile_Sections') && raw['user_Profile_Sections'] is Map) {
        profileSections = Map<String, dynamic>.from(raw['user_Profile_Sections'] as Map);
      } else if (raw.containsKey('user_profile') && raw['user_profile'] is Map) {
        profileSections = Map<String, dynamic>.from(raw['user_profile'] as Map);
      } else {
        // fallback keys you listed
        final fallback = [
          'certifications','cv_url','dob','education','experiences','father_name','picture_url',
          'references','skills','salary','availability','workModes','languages','linkedin','github','bio'
        ];
        for (final k in fallback) {
          if (raw.containsKey(k)) profileSections[k] = raw[k];
        }
      }

      // Defensive conversions
      if (accountData['experience_years'] is String) {
        accountData['experience_years'] = int.tryParse(accountData['experience_years']) ?? 0;
      } else if (accountData['experience_years'] is double) {
        accountData['experience_years'] = (accountData['experience_years'] as double).toInt();
      }

      // Education map normalization
      if (profileSections['education'] is Map) {
        final edu = Map<String, dynamic>.from(profileSections['education'] as Map);
        if (edu['degree'] != null) edu['degree'] = edu['degree'].toString();
        if (edu['university'] != null) edu['university'] = edu['university'].toString();
        profileSections['education'] = edu;
      }

      // expected_salary normalization
      if (profileSections['salary'] is String) {
        profileSections['salary'] =
            double.tryParse((profileSections['salary'] as String).replaceAll(',', '')) ?? 0.0;
      } else if (profileSections['salary'] is int) {
        profileSections['salary'] = (profileSections['salary'] as int).toDouble();
      }

      // Ensure lists are proper lists of strings for simple fields
      for (final listKey in ['skills', 'languages', 'certifications', 'references']) {
        final v = profileSections[listKey];
        if (v == null) {
          profileSections[listKey] = <dynamic>[];
        } else if (v is List) {
          profileSections[listKey] = v.map((e) => e).toList();
        } else {
          profileSections[listKey] = <dynamic>[];
        }
      }

      // Ensure experiences is a list of maps
      if (profileSections['experiences'] is! List) {
        profileSections['experiences'] = <Map<String, dynamic>>[];
      } else {
        profileSections['experiences'] = (profileSections['experiences'] as List).map((e) {
          return (e is Map) ? Map<String, dynamic>.from(e) : <String, dynamic>{};
        }).toList();
      }

      // Compose canonical snapshot with exact keys you specified
      final normalized = <String, dynamic>{
        'user_account_data': accountData,
        'user_profile_section': profileSections,
      };

      return normalized;
    } catch (e, st) {
      debugPrint('❌ Error cleaning profile snapshot: $e\n$st');
      return data;
    }
  }

  Future<JobData?> _fetchJobData(String jobId) async {
    try {
      debugPrint('🔍 Fetching job data for jobId: $jobId');

      final jobDoc = await _firestore
          .collection('Posted_jobs_public')
          .doc(jobId)
          .get();

      if (jobDoc.exists) {
        final data = jobDoc.data()!;
        debugPrint('✅ Job data found for $jobId: ${data['title']}');

        // Handle salary parsing safely
        double? salary;
        final salaryData = data['salary'];
        if (salaryData != null) {
          if (salaryData is num) {
            salary = salaryData.toDouble();
          } else if (salaryData is String) {
            // Try to extract first number from string like "45,000-55,000"
            final RegExp numberRegex = RegExp(r'[\d,]+');
            final match = numberRegex.firstMatch(salaryData);
            if (match != null) {
              final numberStr = match.group(0)?.replaceAll(',', '');
              salary = double.tryParse(numberStr ?? '0') ?? 0.0;
            }
            debugPrint('📊 Parsed salary from "$salaryData" to $salary');
          }
        }

        // Safely handle experience field (keep as dynamic to handle both string and int)
        dynamic experience = data['experience'];

        // Safely handle required_skills
        List<String> requiredSkills = [];
        if (data['required_skills'] is List) {
          requiredSkills = (data['required_skills'] as List).map((e) => e.toString()).toList();
        }

        return JobData(
          jobId: jobId,
          title: data['title']?.toString() ?? '',
          company: data['company']?.toString() ?? '',
          location: data['location']?.toString() ?? '',
          jobType: data['job_type']?.toString() ?? '',
          workType: data['workModes']?.toString() ?? '',
          salary: salary,
          experience: experience,
          requiredSkills: requiredSkills,
        );
      } else {
        debugPrint('❌ Job document not found for jobId: $jobId');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Error loading job data for $jobId: $e');
      return null;
    }
  }

  void _populateFilterOptions() {
    availableExperiences.clear();
    availableLocations.clear();
    availableEducations.clear();
    availableAvailabilities.clear();
    availableWorkTypes.clear();
    availableSkills.clear();
    availableLanguages.clear();
    availableJobs.clear();

    for (final applicant in _allApplicants) {
      try {
        // Experience levels
        final expYears = applicant.experienceYears;
        if (expYears == 0) {
          availableExperiences.add('Entry Level');
        } else if (expYears <= 2) {
          availableExperiences.add('1-2 years');
        } else if (expYears <= 5) {
          availableExperiences.add('3-5 years');
        } else if (expYears <= 10) {
          availableExperiences.add('6-10 years');
        } else {
          availableExperiences.add('10+ years');
        }

        // Locations
        if (applicant.location.isNotEmpty) {
          availableLocations.add(applicant.location);
        }

        // Education
        if (applicant.education.isNotEmpty) {
          availableEducations.add(applicant.education);
        }

        // Availability
        if (applicant.availability.isNotEmpty) {
          availableAvailabilities.add(applicant.availability);
        }

        // Work Type
        if (applicant.workType.isNotEmpty) {
          availableWorkTypes.add(applicant.workType);
        }

        // Skills
        availableSkills.addAll(applicant.skills);

        // Languages
        availableLanguages.addAll(applicant.languages);

        // Job titles
        if (applicant.jobData?.title.isNotEmpty == true) {
          availableJobs.add(applicant.jobData!.title);
        }
      } catch (e) {
        debugPrint('❌ Error populating filter options for applicant ${applicant.userId}: $e');
        continue;
      }
    }
  }

  void _applyFilters() {
    _filteredApplicants = _allApplicants.where((applicant) {
      try {
        // Search query filter
        if (searchQuery.isNotEmpty) {
          final query = searchQuery.toLowerCase();
          final searchableText = '${applicant.name} ${applicant.email} ${applicant.company} ${applicant.skills.join(' ')} ${applicant.jobData?.title ?? ''}'.toLowerCase();
          if (!searchableText.contains(query)) return false;
        }

        // Status filter
        if (statusFilter != 'All' && applicant.status != statusFilter) {
          return false;
        }

        // Job filter
        if (jobFilter != 'All' && applicant.jobData?.title != jobFilter) {
          return false;
        }

        // Experience filter
        if (experienceFilter != 'All') {
          final expYears = applicant.experienceYears;
          String expLevel;
          if (expYears == 0) {
            expLevel = 'Entry Level';
          } else if (expYears <= 2) {
            expLevel = '1-2 years';
          } else if (expYears <= 5) {
            expLevel = '3-5 years';
          } else if (expYears <= 10) {
            expLevel = '6-10 years';
          } else {
            expLevel = '10+ years';
          }
          if (expLevel != experienceFilter) return false;
        }

        // Location filter
        if (locationFilter != 'All' && applicant.location != locationFilter) {
          return false;
        }

        // Education filter
        if (educationFilter != 'All' && applicant.education != educationFilter) {
          return false;
        }

        // Availability filter
        if (availabilityFilter != 'All' && applicant.availability != availabilityFilter) {
          return false;
        }

        // Work type filter
        if (workTypeFilter != 'All' && applicant.workType != workTypeFilter) {
          return false;
        }

        // Skills filter
        if (skillsFilter.isNotEmpty) {
          final hasAllSkills = skillsFilter.every((skill) => applicant.skills.contains(skill));
          if (!hasAllSkills) return false;
        }

        // Languages filter
        if (languagesFilter.isNotEmpty) {
          final hasAllLanguages = languagesFilter.every((lang) => applicant.languages.contains(lang));
          if (!hasAllLanguages) return false;
        }

        // Salary range filter
        if (applicant.expectedSalary < minExpectedSalary || applicant.expectedSalary > maxExpectedSalary) {
          return false;
        }

        // Applied date range filter
        if (appliedDateRange != null) {
          final appliedDate = applicant.appliedAt;
          if (appliedDate.isBefore(appliedDateRange!.start) ||
              appliedDate.isAfter(appliedDateRange!.end.add(const Duration(days: 1)))) {
            return false;
          }
        }

        return true;
      } catch (e) {
        debugPrint('❌ Error applying filters for applicant ${applicant.userId}: $e');
        return false; // Exclude applicants that cause errors
      }
    }).toList();

    // Apply sorting
    _applySorting();
  }

  void _applySorting() {
    try {
      switch (sortBy) {
        case 'applied_desc':
          _filteredApplicants.sort((a, b) => b.appliedAt.compareTo(a.appliedAt));
          break;
        case 'applied_asc':
          _filteredApplicants.sort((a, b) => a.appliedAt.compareTo(b.appliedAt));
          break;
        case 'name_asc':
          _filteredApplicants.sort((a, b) => a.name.compareTo(b.name));
          break;
        case 'name_desc':
          _filteredApplicants.sort((a, b) => b.name.compareTo(a.name));
          break;
        case 'experience_desc':
          _filteredApplicants.sort((a, b) => b.experienceYears.compareTo(a.experienceYears));
          break;
        case 'experience_asc':
          _filteredApplicants.sort((a, b) => a.experienceYears.compareTo(b.experienceYears));
          break;
        case 'salary_desc':
          _filteredApplicants.sort((a, b) => b.expectedSalary.compareTo(a.expectedSalary));
          break;
        case 'salary_asc':
          _filteredApplicants.sort((a, b) => a.expectedSalary.compareTo(b.expectedSalary));
          break;
        case 'status':
          _filteredApplicants.sort((a, b) => a.status.compareTo(b.status));
          break;
        case 'job_title':
          _filteredApplicants.sort((a, b) => (a.jobData?.title ?? '').compareTo(b.jobData?.title ?? ''));
          break;
      }
    } catch (e) {
      debugPrint('❌ Error applying sorting: $e');
    }
  }

  // Public methods for updating filters
  void updateSearchQuery(String query) {
    searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void updateStatusFilter(String status) {
    statusFilter = status;
    _applyFilters();
    notifyListeners();
  }

  void updateJobFilter(String job) {
    jobFilter = job;
    _applyFilters();
    notifyListeners();
  }

  void updateExperienceFilter(String experience) {
    experienceFilter = experience;
    _applyFilters();
    notifyListeners();
  }

  void updateLocationFilter(String location) {
    locationFilter = location;
    _applyFilters();
    notifyListeners();
  }

  void updateEducationFilter(String education) {
    educationFilter = education;
    _applyFilters();
    notifyListeners();
  }

  void updateAvailabilityFilter(String availability) {
    availabilityFilter = availability;
    _applyFilters();
    notifyListeners();
  }

  void updateWorkTypeFilter(String workType) {
    workTypeFilter = workType;
    _applyFilters();
    notifyListeners();
  }

  void updateSkillsFilter(List<String> skills) {
    skillsFilter = skills;
    _applyFilters();
    notifyListeners();
  }

  void updateLanguagesFilter(List<String> languages) {
    languagesFilter = languages;
    _applyFilters();
    notifyListeners();
  }

  void updateSalaryRange(double min, double max) {
    minExpectedSalary = min;
    maxExpectedSalary = max;
    _applyFilters();
    notifyListeners();
  }

  void updateAppliedDateRange(DateTimeRange? range) {
    appliedDateRange = range;
    _applyFilters();
    notifyListeners();
  }
  void updateSorting(String sorting) {
    sortBy = sorting;
    _applySorting();
    notifyListeners();
  }

  void clearAllFilters() {
    searchQuery = '';
    statusFilter = 'All';
    jobFilter = 'All';
    experienceFilter = 'All';
    locationFilter = 'All';
    educationFilter = 'All';
    availabilityFilter = 'All';
    workTypeFilter = 'All';
    skillsFilter.clear();
    languagesFilter.clear();
    minExpectedSalary = 0;
    maxExpectedSalary = 1000000;
    appliedDateRange = null;
    sortBy = 'applied_desc';
    _applyFilters();
    notifyListeners();
  }

  bool get hasActiveFilters {
    return searchQuery.isNotEmpty ||
        statusFilter != 'All' ||
        jobFilter != 'All' ||
        experienceFilter != 'All' ||
        locationFilter != 'All' ||
        educationFilter != 'All' ||
        availabilityFilter != 'All' ||
        workTypeFilter != 'All' ||
        skillsFilter.isNotEmpty ||
        languagesFilter.isNotEmpty ||
        minExpectedSalary > 0 ||
        maxExpectedSalary < 1000000 ||
        appliedDateRange != null;
  }

  // Update application status
  Future<void> updateApplicationStatus(String applicantUserId, String docId, String newStatus) async {
    try {
      // Update in Firestore using the applicant's user ID
      await _firestore
          .collection('applications')
          .doc(applicantUserId)
          .collection('applied_jobs')
          .doc(docId)
          .update({'status': newStatus});

      // Update locally
      final index = _allApplicants.indexWhere((a) => a.docId == docId && a.userId == applicantUserId);
      if (index != -1) {
        _allApplicants[index] = _allApplicants[index].copyWith(status: newStatus);
        _applyFilters();
        notifyListeners();
      }
    } catch (e) {
      error = 'Failed to update status: $e';
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    debugPrint('🔄 Refreshing applicants data...');
    isLoading = true;
    error = null;
    notifyListeners();
    await _load();
  }

}