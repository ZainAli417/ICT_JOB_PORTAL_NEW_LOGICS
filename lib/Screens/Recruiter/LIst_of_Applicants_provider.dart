// lib/providers/applicants_provider.dart

import 'package:flutter/foundation.dart';
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
  final JobData? jobData; // Add job data to each record

  // Derived properties from profileSnapshot with safe type casting
  String get name {
    try {
      return profileSnapshot['user_Account_Data']?['name']?.toString() ?? 'Unknown';
    } catch (e) {
      debugPrint('Error getting name: $e');
      return 'Unknown';
    }
  }

  String get email {
    try {
      return profileSnapshot['user_Account_Data']?['email']?.toString() ?? '';
    } catch (e) {
      debugPrint('Error getting email: $e');
      return '';
    }
  }

  String get phone {
    try {
      return profileSnapshot['user_Account_Data']?['phone']?.toString() ?? '';
    } catch (e) {
      debugPrint('Error getting phone: $e');
      return '';
    }
  }

  String get location {
    try {
      return profileSnapshot['user_Account_Data']?['location']?.toString() ?? '';
    } catch (e) {
      debugPrint('Error getting location: $e');
      return '';
    }
  }

  String get company {
    try {
      return profileSnapshot['user_Account_Data']?['company']?.toString() ?? '';
    } catch (e) {
      debugPrint('Error getting company: $e');
      return '';
    }
  }

  int get experienceYears {
    try {
      final value = profileSnapshot['user_Account_Data']?['experience_years'];
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      if (value is double) return value.toInt();
      return 0;
    } catch (e) {
      debugPrint('Error getting experience_years: $e');
      return 0;
    }
  }

  List<String> get skills {
    try {
      final skillsData = profileSnapshot['user_Profile_Sections']?['skills'];
      if (skillsData == null) return [];
      if (skillsData is List) {
        return skillsData.map((e) => e.toString()).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error getting skills: $e');
      return [];
    }
  }

  String get education {
    try {
      final educationData = profileSnapshot['user_Profile_Sections']?['education'];
      if (educationData is Map<String, dynamic>) {
        return educationData['degree']?.toString() ?? '';
      } else if (educationData is String) {
        return educationData;
      }
      return '';
    } catch (e) {
      debugPrint('Error getting education degree: $e');
      return '';
    }
  }

  String get university {
    try {
      final educationData = profileSnapshot['user_Profile_Sections']?['education'];
      if (educationData is Map<String, dynamic>) {
        return educationData['university']?.toString() ?? '';
      }
      return '';
    } catch (e) {
      debugPrint('Error getting university: $e');
      return '';
    }
  }

  double get expectedSalary {
    try {
      final value = profileSnapshot['user_Profile_Sections']?['expected_salary'];
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    } catch (e) {
      debugPrint('Error getting expected_salary: $e');
      return 0.0;
    }
  }

  String get availability {
    try {
      return profileSnapshot['user_Profile_Sections']?['availability']?.toString() ?? '';
    } catch (e) {
      debugPrint('Error getting availability: $e');
      return '';
    }
  }

  String get workType {
    try {
      return profileSnapshot['user_Profile_Sections']?['work_type']?.toString() ?? '';
    } catch (e) {
      debugPrint('Error getting work_type: $e');
      return '';
    }
  }

  String get bio {
    try {
      return profileSnapshot['user_Profile_Sections']?['bio']?.toString() ?? '';
    } catch (e) {
      debugPrint('Error getting bio: $e');
      return '';
    }
  }

  String get linkedIn {
    try {
      return profileSnapshot['user_Profile_Sections']?['linkedin']?.toString() ?? '';
    } catch (e) {
      debugPrint('Error getting linkedin: $e');
      return '';
    }
  }

  String get github {
    try {
      return profileSnapshot['user_Profile_Sections']?['github']?.toString() ?? '';
    } catch (e) {
      debugPrint('Error getting github: $e');
      return '';
    }
  }

  List<String> get languages {
    try {
      final languagesData = profileSnapshot['user_Profile_Sections']?['languages'];
      if (languagesData == null) return [];
      if (languagesData is List) {
        return languagesData.map((e) => e.toString()).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error getting languages: $e');
      return [];
    }
  }

  List<String> get certifications {
    try {
      final certificationsData = profileSnapshot['user_Profile_Sections']?['certifications'];
      if (certificationsData == null) return [];
      if (certificationsData is List) {
        return certificationsData.map((e) => e.toString()).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error getting certifications: $e');
      return [];
    }
  }

  ApplicantRecord({
    required this.userId,
    required this.jobId,
    required this.status,
    required this.appliedAt,
    required this.profileSnapshot,
    required this.docId,
    this.jobData,
  });

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
          .collection('Job_Seeker')
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

  // Helper method to clean and convert profile snapshot data
  Map<String, dynamic> _cleanProfileSnapshot(Map<String, dynamic> data) {
    try {
      final cleaned = Map<String, dynamic>.from(data);

      // Handle user_Account_Data section
      if (cleaned['user_Account_Data'] is Map<String, dynamic>) {
        final accountData = Map<String, dynamic>.from(cleaned['user_Account_Data']);

        // Convert experience_years to int if it's a string
        if (accountData['experience_years'] is String) {
          final expStr = accountData['experience_years'] as String;
          accountData['experience_years'] = int.tryParse(expStr) ?? 0;
          debugPrint('🔧 Converted experience_years from "$expStr" to ${accountData['experience_years']}');
        }

        cleaned['user_Account_Data'] = accountData;
      }

      // Handle user_Profile_Sections
      if (cleaned['user_Profile_Sections'] is Map<String, dynamic>) {
        final profileSections = Map<String, dynamic>.from(cleaned['user_Profile_Sections']);

        // Handle education section - ensure all fields are properly typed
        if (profileSections['education'] is Map<String, dynamic>) {
          final education = Map<String, dynamic>.from(profileSections['education']);

          // Ensure degree is string
          if (education['degree'] != null) {
            education['degree'] = education['degree'].toString();
          }

          // Ensure university is string
          if (education['university'] != null) {
            education['university'] = education['university'].toString();
          }

          profileSections['education'] = education;
          debugPrint('🔧 Cleaned education section');
        }

        // Handle expected_salary
        if (profileSections['expected_salary'] is String) {
          final salaryStr = profileSections['expected_salary'] as String;
          profileSections['expected_salary'] = double.tryParse(salaryStr) ?? 0.0;
          debugPrint('🔧 Converted expected_salary from "$salaryStr" to ${profileSections['expected_salary']}');
        }

        // Ensure skills is a list of strings
        if (profileSections['skills'] != null && profileSections['skills'] is! List) {
          profileSections['skills'] = [];
        } else if (profileSections['skills'] is List) {
          profileSections['skills'] = (profileSections['skills'] as List).map((e) => e.toString()).toList();
        }

        // Ensure languages is a list of strings
        if (profileSections['languages'] != null && profileSections['languages'] is! List) {
          profileSections['languages'] = [];
        } else if (profileSections['languages'] is List) {
          profileSections['languages'] = (profileSections['languages'] as List).map((e) => e.toString()).toList();
        }

        // Ensure certifications is a list of strings
        if (profileSections['certifications'] != null && profileSections['certifications'] is! List) {
          profileSections['certifications'] = [];
        } else if (profileSections['certifications'] is List) {
          profileSections['certifications'] = (profileSections['certifications'] as List).map((e) => e.toString()).toList();
        }

        cleaned['user_Profile_Sections'] = profileSections;
      }

      return cleaned;
    } catch (e) {
      debugPrint('❌ Error cleaning profile snapshot: $e');
      return data; // Return original data if cleaning fails
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
          workType: data['work_type']?.toString() ?? '',
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

  @override
  void dispose() {
    super.dispose();
  }
}