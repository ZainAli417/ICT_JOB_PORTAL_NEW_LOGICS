
// job_hub.dart - Enhanced Version
import 'package:flutter/material.dart';
import 'package:job_portal/Constant/recruiter_AI.dart';
import 'package:job_portal/Screens/Recruiter/post_a_job_form.dart';
import 'package:job_portal/Screens/Recruiter/Recruiter_Available_jobs.dart';
import 'package:job_portal/Screens/Recruiter/R_Top_Bar.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Job_Seeker/job_seeker_provider.dart';

/// Enhanced JobPostingScreen with modern UI/UX and optimized performance
class JobPostingScreen extends StatefulWidget {
  const JobPostingScreen({super.key});

  @override
  State<JobPostingScreen> createState() => _JobPostingScreenState();
}

class _JobPostingScreenState extends State<JobPostingScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final TextEditingController _messageController = TextEditingController();
  final FocusNode _messageFocusNode = FocusNode();
  bool _isMessageFocused = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupFocusListener();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Start animations
    _fadeController.forward();
    _slideController.forward();
  }

  void _setupFocusListener() {
    _messageFocusNode.addListener(() {
      setState(() {
        _isMessageFocused = _messageFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _messageController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Recruiter_MainLayout(
      activeIndex: 1,
      child: Stack(
          children: [
            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: _buildDashboardContent(context),
              ),
            ),
          ]
      ),
    );
  }
  Widget _buildDashboardContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Column - Main Content
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   _buildHeaderSection(),
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 600, // Set a fixed height or calculate based on screen
                    child: Consumer<JobSeekerProvider>(
                      builder: (context, provider, _) {
                        return StreamBuilder<List<Map<String, dynamic>>>(
                          stream: provider.allJobsStream(),

                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            if (snapshot.hasError) {
                              return Center(
                                child: Text(
                                  'Error loading jobs: ${snapshot.error}',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    color: Colors.red.shade700,
                                  ),
                                ),
                              );
                            }

                            final jobs = snapshot.data ?? [];

                            if (jobs.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.work_outline_rounded,
                                        size: 80, color: Colors.grey.shade400),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No jobs available right now.\nPlease check back later.',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return RepaintBoundary(
                              child: Padding(
                                padding:
                                const EdgeInsets.symmetric(vertical: 20),
                                child: JobListView(jobs: jobs),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 24),

          // Right Column - AI Assistant
          Expanded(
            flex: 1,
            child: GeminiChatWidget(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.1),
            Theme.of(context).primaryColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.work_outline_rounded,
              size: 32,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Job Management Dashboard',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Manage your job postings and applicants',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          /*
          ElevatedButton.icon(
            onPressed: _openPostJobDialog,
            icon: const Icon(Icons.add_circle_outline, size: 20),
            label: Text(
              'Post New Job',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
          ),

           */
        ],
      ),
    );
  }


}


/* import 'package:flutter/material.dart';
import 'package:job_portal/Screens/Recruiter/R_Top_Bar.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Constant/recruiter_AI.dart';
import '../Job_Seeker/job_seeker_provider.dart';
import 'post_a_job_form.dart';
import 'Recruiter_Available_jobs.dart';
import 'Recruiter_provider_old.dart';

class JobPostingScreen extends StatefulWidget {
  const JobPostingScreen({super.key});

  @override
  JobPostingScreenState createState() => JobPostingScreenState();
}

class JobPostingScreenState extends State<JobPostingScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final TextEditingController _searchController = TextEditingController();

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _searchController.addListener(() {
      Provider.of<JobPostingProvider>(context, listen: false)
          .searchJobs(_searchController.text);
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _openPostJobDialog() {
    showDialog(
      context: context,
      builder: (_) => const PostJobDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<JobPostingProvider>(
      create: (_) => JobPostingProvider(),
      child: Recruiter_MainLayout(
        activeIndex: 1,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildHeaderSection(),
                  const SizedBox(height: 16),
                  Expanded(child:
                  SizedBox(
                    height: 600, // Set a fixed height or calculate based on screen
                    child: Consumer<job_seeker_provider>(
                      builder: (context, provider, _) {
                        return StreamBuilder<List<Map<String, dynamic>>>(
                          stream: provider.publicJobsStream(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            if (snapshot.hasError) {
                              return Center(
                                child: Text(
                                  'Error loading jobs: ${snapshot.error}',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    color: Colors.red.shade700,
                                  ),
                                ),
                              );
                            }

                            final jobs = snapshot.data ?? [];

                            if (jobs.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.work_outline_rounded,
                                        size: 80, color: Colors.grey.shade400),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No jobs available right now.\nPlease check back later.',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return RepaintBoundary(
                              child: Padding(
                                padding:
                                const EdgeInsets.symmetric(vertical: 20),
                                child: JobsListView(jobs: jobs),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),

                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.1),
            Theme.of(context).primaryColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.work_outline_rounded,
              size: 32,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Job Management Dashboard',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Manage your Air Force job postings and applicants',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: _openPostJobDialog,
            icon: const Icon(Icons.add_circle_outline, size: 20),
            label: Text(
              'Post New Job',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade100,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search jobs by title, unit, department...',
                hintStyle: GoogleFonts.inter(
                  color: Colors.grey.shade500,
                  fontSize: 16,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey.shade500,
                  size: 24,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon:
                  Icon(Icons.clear, color: Colors.grey.shade500),
                  onPressed: () {
                    _searchController.clear();
                    Provider.of<JobPostingProvider>(context,
                        listen: false)
                        .searchJobs('');
                  },
                )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              style: GoogleFonts.inter(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Row(
      children: [
        Expanded(flex: 5, child: _buildMainContent()),
        const SizedBox(width: 16),
        Expanded(flex: 2, child: GeminiChatWidget()),
      ],
    );
  }



/*
  Widget _buildFilterSidebar() {
    return Consumer<JobPostingProvider>(
      builder: (context, prov, _) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 8)],
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Salary Range', style: _headingStyle),
              RangeSlider(
                values: prov.salaryRange,
                min: 0,
                max: 500000,
                divisions: 100,
                labels: RangeLabels(
                  '${prov.salaryRange.start.round()}',
                  '${prov.salaryRange.end.round()}',
                ),
                onChanged: prov.setSalaryRange,
              ),
              const SizedBox(height: 16),

              Text('Experience (Years)', style: _headingStyle),
              RangeSlider(
                values: prov.experienceRange,
                min: 0,
                max: 30,
                divisions: 30,
                labels: RangeLabels(
                  '${prov.experienceRange.start.round()}',
                  '${prov.experienceRange.end.round()}',
                ),
                onChanged: prov.setExperienceRange,
              ),
              const SizedBox(height: 16),

              Text('Salary Type', style: _headingStyle),
              DropdownButtonFormField<String>(
                value: prov.selectedSalaryType,
                items: prov.salaryTypeOptions
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: prov.setSalaryType,
              ),
              const SizedBox(height: 16),

              Text('Work Mode', style: _headingStyle),
              DropdownButtonFormField<String>(
                value: prov.selectedWorkMode,
                items: prov.workModeOptions
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: prov.setWorkMode,
              ),
              const SizedBox(height: 16),

              Text('Department', style: _headingStyle),
              DropdownButtonFormField<String>(
                value: prov.selectedDepartment,
                items: prov.departmentOptions
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: prov.setDepartment,
              ),
              const SizedBox(height: 16),

              Text('Rank Requirement', style: _headingStyle),
              DropdownButtonFormField<String>(
                value: prov.selectedRank,
                items: prov.rankRequirements
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: prov.setRankRequirement,
              ),
              const SizedBox(height: 16),

              Text('Security Clearance', style: _headingStyle),
              DropdownButtonFormField<String>(
                value: prov.selectedClearance,
                items: prov.securityClearanceOptions
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: prov.setSecurityClearance,
              ),
              const SizedBox(height: 16),

              Text('Location', style: _headingStyle),
              DropdownButtonFormField<String>(
                value: prov.selectedLocation,
                items: prov.locationOptions
                    .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                    .toList(),
                onChanged: prov.setLocation,
              ),
              const SizedBox(height: 16),

              Text('Skills', style: _headingStyle),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: prov.skillOptions.map((skill) {
                  final selected = prov.selectedSkills.contains(skill);
                  return FilterChip(
                    label: Text(skill),
                    selected: selected,
                    onSelected: (_) => prov.toggleSkill(skill),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              Text('Benefits', style: _headingStyle),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: prov.benefitOptions.map((b) {
                  final selected = prov.selectedBenefits.contains(b);
                  return FilterChip(
                    label: Text(b),
                    selected: selected,
                    onSelected: (_) => prov.toggleBenefit(b),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              ListTile(
                title: Text(
                  prov.postedAfter == null
                      ? 'Any posting date'
                      : 'After ${prov.postedAfter!.month}/${prov.postedAfter!.day}/${prov.postedAfter!.year}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: prov.postedAfter ?? DateTime.now(),
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) prov.setPostedAfter(picked);
                },
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 16),

              SwitchListTile(
                title: const Text('Remote Only'),
                value: prov.remoteOnly,
                onChanged: prov.setRemoteOnly,
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
              SwitchListTile(
                title: const Text('Urgent Hiring'),
                value: prov.urgentOnly,
                onChanged: prov.setUrgentOnly,
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ),
    );
  }
*/
  /*
  Widget _buildFilterSidebar() {

    return Consumer<JobPostingProvider>(
      builder: (context, prov, _) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(color: Colors.grey.shade100, blurRadius: 8)
          ],
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Salary Range', style: _headingStyle),
              RangeSlider(
                values: prov.salaryRange,
                min: 0,
                max: 500000,
                divisions: 100,
                labels: RangeLabels(
                  '${prov.salaryRange.start.round()}',
                  '${prov.salaryRange.end.round()}',
                ),
                onChanged: prov.setSalaryRange,
              ),
              const SizedBox(height: 16),

              Text('Experience (Years)', style: _headingStyle),
              RangeSlider(
                values: prov.experienceRange,
                min: 0,
                max: 20,
                divisions: 20,
                labels: RangeLabels(
                  '${prov.experienceRange.start.round()}',
                  '${prov.experienceRange.end.round()}',
                ),
                onChanged: prov.setExperienceRange,
              ),
              const SizedBox(height: 16),

              Text('Job Type', style: _headingStyle),
              for (var t in prov.jobTypeOptions)
                RadioListTile<String>(
                  title: Text(t),
                  value: t,
                  groupValue: prov.selectedJobType,
                  onChanged: prov.setJobType,
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              const SizedBox(height: 16),

              Text('Work Mode', style: _headingStyle),
              DropdownButtonFormField<String>(
                value: prov.selectedWorkMode,
                items: prov.workModeOptions
                    .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                    .toList(),
                onChanged: prov.setWorkMode,
              ),
              const SizedBox(height: 16),

              Text('Education', style: _headingStyle),
              DropdownButtonFormField<String>(
                value: prov.selectedEducation,
                items: prov.educationOptions
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: prov.setEducation,
              ),
              const SizedBox(height: 16),

              Text('Location', style: _headingStyle),
              DropdownButtonFormField<String>(
                value: prov.selectedLocation,
                items: prov.locationOptions
                    .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                    .toList(),
                onChanged: prov.setLocation,
              ),
              const SizedBox(height: 16),

              Text('Skills', style: _headingStyle),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: prov.skillOptions.map((skill) {
                  final selected = prov.selectedSkills.contains(skill);
                  return FilterChip(
                    label: Text(skill),
                    selected: selected,
                    onSelected: (_) => prov.toggleSkill(skill),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              Text('Industries', style: _headingStyle),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: prov.industryOptions.map((ind) {
                  final selected = prov.selectedIndustries.contains(ind);
                  return FilterChip(
                    label: Text(ind),
                    selected: selected,
                    onSelected: (_) => prov.toggleIndustry(ind),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              Text('Benefits', style: _headingStyle),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: prov.benefitOptions.map((b) {
                  final selected = prov.selectedBenefits.contains(b);
                  return FilterChip(
                    label: Text(b),
                    selected: selected,
                    onSelected: (_) => prov.toggleBenefit(b),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              ListTile(
                title: Text(
                  prov.postedAfter == null
                      ? 'Any posting date'
                      : 'After ${prov.postedAfter!.month}/${prov.postedAfter!.day}/${prov.postedAfter!.year}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: prov.postedAfter ?? DateTime.now(),
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) prov.setPostedAfter(picked);
                },
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 16),

              SwitchListTile(
                title: const Text('Remote Only'),
                value: prov.remoteOnly,
                onChanged: prov.setRemoteOnly,
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
              SwitchListTile(
                title: const Text('Urgent Hiring'),
                value: prov.urgentOnly,
                onChanged: prov.setUrgentOnly,
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 16),

              SwitchListTile(
                title: const Text('Health Insurance'),
                value: prov.hasHealthInsurance,
                onChanged: prov.setHealthInsurance,
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
              SwitchListTile(
                title: const Text('Retirement Plan'),
                value: prov.hasRetirementPlan,
                onChanged: prov.setRetirementPlan,
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
              SwitchListTile(
                title: const Text('Flexible Hours'),
                value: prov.hasFlexibleHours,
                onChanged: prov.setFlexibleHours,
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ),
    );
  }

   */

  Widget _buildMainContent() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.grey.shade100, blurRadius: 8)
        ],
      ),
      child: Consumer<JobPostingProvider>(
        builder: (context, prov, _) {
          final results = prov.filteredJobList;
          if (results.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off,
                      size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No jobs found',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try adjusting your search or filters',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      '${results.length} jobs found',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: JobsListView(
                    jobs: results,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}


 */