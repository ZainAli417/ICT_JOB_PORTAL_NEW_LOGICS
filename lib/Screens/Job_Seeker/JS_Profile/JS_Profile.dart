// js_profile_screen.dart
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../Recruiter/LIst_of_Applicants.dart';
import '../JS_Top_Bar.dart';
import 'JS_Profile_Provider.dart';
import 'JS_Profile_Sidebar.dart';

class ProfileScreen_NEW extends StatefulWidget {
  const ProfileScreen_NEW({super.key});

  @override
  State<ProfileScreen_NEW> createState() => _JSProfileScreenState();
}

class _JSProfileScreenState extends State<ProfileScreen_NEW> with TickerProviderStateMixin {
  int _currentStep = 0;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  final ScrollController _stepScrollController = ScrollController();

  // Controllers for form fields
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _secondaryEmailCtrl = TextEditingController();
  final TextEditingController _contactCtrl = TextEditingController();
  final TextEditingController _nationalityCtrl = TextEditingController();
  final TextEditingController _objectivesCtrl = TextEditingController();
  final TextEditingController _personalSummaryCtrl = TextEditingController();
  final TextEditingController _dobCtrl = TextEditingController();
  final TextEditingController _institutionCtrl = TextEditingController();
  final TextEditingController _durationCtrl = TextEditingController();
  final TextEditingController _majorCtrl = TextEditingController();
  final TextEditingController _marksCtrl = TextEditingController();
  final TextEditingController _experienceTextCtrl = TextEditingController();
  final TextEditingController _singleLineCtrl = TextEditingController();
  final TextEditingController _profSummaryCtrl = TextEditingController();

  bool _didLoad = false;

  final List<String> _stepTitles = [
    'Personal Info',
    'Education',
    'Professional Profile',
    'Experience',
    'Certifications',
    'Publications',
    'Awards',
    'References',
    'Documents'
  ];

  final List<IconData> _stepIcons = [
    FontAwesomeIcons.user,
    FontAwesomeIcons.graduationCap,
    FontAwesomeIcons.briefcase,
    FontAwesomeIcons.clock,
    FontAwesomeIcons.certificate,
    FontAwesomeIcons.fileAlt,
    FontAwesomeIcons.award,
    FontAwesomeIcons.users,
    FontAwesomeIcons.folder,
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation =
        CurvedAnimation(parent: _animController, curve: Curves.easeInOut);
    _animController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoad) return;
    _didLoad = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = Provider.of<ProfileProvider_NEW>(context, listen: false);
      prov.loadAllSectionsOnce().then((_) {
        _nameCtrl.text = prov.name;
        _emailCtrl.text = prov.email;
        _secondaryEmailCtrl.text = prov.secondaryEmail;
        _contactCtrl.text = prov.contactNumber;
        _nationalityCtrl.text = prov.nationality;
        _objectivesCtrl.text = prov.objectives;
        _personalSummaryCtrl.text = prov.personalSummary;
        _dobCtrl.text = prov.dob;
        _profSummaryCtrl.text = prov.professionalProfileSummary;
        setState(() {});
      });
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _stepScrollController.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _secondaryEmailCtrl.dispose();
    _contactCtrl.dispose();
    _nationalityCtrl.dispose();
    _objectivesCtrl.dispose();
    _personalSummaryCtrl.dispose();
    _dobCtrl.dispose();
    _institutionCtrl.dispose();
    _durationCtrl.dispose();
    _majorCtrl.dispose();
    _marksCtrl.dispose();
    _experienceTextCtrl.dispose();
    _singleLineCtrl.dispose();
    _profSummaryCtrl.dispose();
    super.dispose();
  }

  void _scrollToCurrentStep() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_stepScrollController.hasClients) {
        final screenWidth = MediaQuery
            .of(context)
            .size
            .width;
        final itemWidth = 180.0;
        final targetOffset = (_currentStep * itemWidth) - (screenWidth / 4);
        _stepScrollController.animateTo(
          targetOffset.clamp(
              0.0, _stepScrollController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const double topBarHeight = 120.0;

    return ScrollConfiguration(
      behavior: SmoothScrollBehavior(),
      child: SizedBox.expand(
        child: Stack(
          children: [
            // Main content area sits below the top bar.
            Positioned.fill(
              top: topBarHeight,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: _buildContent(context), // unchanged: contains ChangeNotifierProvider + Scaffold
              ),
            ),

            // Top navigation bar overlay (MainLayout used as the bar)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: topBarHeight,
              child: MainLayout(
                activeIndex: 1,
                child: const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Consumer<ProfileProvider_NEW>(
        builder: (context, prov, _) {
          if (prov.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return Row(
            children: [
              // Main content area
              Expanded(
                flex: 7,
                child: Column(
                  children: [
                    _buildTopBar(),
                    Expanded(child: _buildMainContent(prov)),
                  ],
                ),
              ),
              // Sidebar
              Container(
                width: 380,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(-2, 0),
                    ),
                  ],
                ),
                child: JSProfileSidebar(provider: prov),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,

      ),
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        children: [
          FaIcon(FontAwesomeIcons.userCircle, color: const Color(0xFF6366F1),
              size: 32),
          const SizedBox(width: 12),
          Text(
            'Complete Your Profile',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6366F1),
            ),
          ),
          const Spacer(),
          _buildProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Step ${_currentStep + 1} of ${_stepTitles.length}',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6063F9),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 120,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: (_currentStep + 1) / _stepTitles.length,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF6366F1)],
                  ),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(ProfileProvider_NEW prov) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          _buildStepIndicators(),
          const SizedBox(height: 25),
          // Instead of FadeTransition, use AnimatedSwitcher for smoother transitions
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.05, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: Container(
                key: ValueKey<int>(_currentStep), // ← Important!
                child: _buildCurrentStepContent(prov),
              ),
            ),
          ),
          const SizedBox(height: 10),
          _buildNavigationButtons(prov),
        ],
      ),
    );
  }

  Widget _buildStepIndicators() {
    return SizedBox(
      height: 65,
      child: ListView.builder(
        controller: _stepScrollController,
        scrollDirection: Axis.horizontal,
        itemCount: _stepTitles.length,
        itemBuilder: (context, index) {
          final isActive = index == _currentStep;
          final isCompleted = index < _currentStep;
          return Row(
            children: [
              InkWell(
                onTap: () {
                  setState(() => _currentStep = index);
                  _animController.reset();
                  _animController.forward();
                  _scrollToCurrentStep();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFF6366F1)
                        : isCompleted
                        ? const Color(0xFF10B981)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isActive || isCompleted
                          ? Colors.transparent
                          : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FaIcon(
                        isCompleted
                            ? FontAwesomeIcons.checkCircle
                            : _stepIcons[index],
                        color: isActive || isCompleted
                            ? Colors.white
                            : const Color(0xFF6B7280),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _stepTitles[index],
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight
                              .w500,
                          color: isActive || isCompleted
                              ? Colors.white
                              : const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (index < _stepTitles.length - 1)
                Container(
                  width: 20,
                  height: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  color: index < _currentStep
                      ? const Color(0xFF10B981)
                      : const Color(0xFFE5E7EB),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCurrentStepContent(ProfileProvider_NEW prov) {
    switch (_currentStep) {
      case 0:
        return _buildPersonalInfo(prov);
      case 1:
        return _buildEducation(prov);
      case 2:
        return _buildProfessionalProfile(prov);
      case 3:
        return _buildExperience(prov);
      case 4:
        return _buildCertifications(prov);
      case 5:
        return _buildPublications(prov);
      case 6:
        return _buildAwards(prov);
      case 7:
        return _buildReferences(prov);
      case 8:
        return _buildDocuments(prov);
      default:
        return const SizedBox();
    }
  }

  Widget _buildPersonalInfo(ProfileProvider_NEW prov) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                FaIcon(
                    FontAwesomeIcons.userCircle, color: const Color(0xFF6366F1),
                    size: 28),
                const SizedBox(width: 12),
                Text(
                  'Personal Information',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111827),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: const Color(0xFFEEF2FF),
                      backgroundImage: prov.profilePicUrl.isNotEmpty
                          ? NetworkImage(prov.profilePicUrl)
                          : null,
                      child: prov.profilePicUrl.isEmpty
                          ? const FaIcon(FontAwesomeIcons.user, size: 40,
                          color: Color(0xFF6366F1))
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => _pickAndUploadProfilePic(prov),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: const FaIcon(
                              FontAwesomeIcons.camera, color: Colors.white,
                              size: 16),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Upload Profile Photo',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildIOSTextField(
                        label: 'Full Name',
                        controller: _nameCtrl,
                        icon: FontAwesomeIcons.user,
                        onChanged: prov.updateName,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildIOSTextField(
                    label: 'Email Address',
                    controller: _emailCtrl,
                    icon: FontAwesomeIcons.envelope,
                    onChanged: prov.updateEmail,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildIOSTextField(
                    label: 'Secondary Email',
                    controller: _secondaryEmailCtrl,
                    icon: FontAwesomeIcons.envelope,
                    onChanged: prov.updateSecondaryEmail,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildIOSTextField(
                    label: 'Contact Number',
                    controller: _contactCtrl,
                    icon: FontAwesomeIcons.phone,
                    onChanged: prov.updateContactNumber,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildIOSTextField(
                    label: 'Nationality',
                    controller: _nationalityCtrl,
                    icon: FontAwesomeIcons.globe,
                    onChanged: prov.updateNationality,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child:
                    _buildIOSTextField(
              label: 'Date of Birth (YYYY-MM-DD)',
              controller: _dobCtrl,
              icon: FontAwesomeIcons.calendar,
              onChanged: prov.updateDob,
            ),
                    ),
            const SizedBox(width: 12),
                Expanded(
                    child:
                    _buildIOSTextField(
              label: 'Career Objectives',

              controller: _objectivesCtrl,
              icon: FontAwesomeIcons.lightbulb,
              maxLines: 3,
              onChanged: prov.updateObjectives,
            ),
                    ),
            ]
            ),
            const SizedBox(height: 12),
            _buildIOSTextField(
              label: 'Professional Summary',
              controller: _personalSummaryCtrl,
              icon: FontAwesomeIcons.fileAlt,
              maxLines: 5,
              hint: 'Provide a brief overview of yourself...',

              onChanged: prov.updatePersonalSummary,
            ),
            const SizedBox(height: 10),
            _buildSkillsSection(prov),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillsSection(ProfileProvider_NEW prov) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const FaIcon(FontAwesomeIcons.layerGroup, color: Color(0xFF6366F1),
                size: 18),
            const SizedBox(width: 8),
            Text(
              'Skills',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF111827),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: prov.skillsList
              .asMap()
              .entries
              .map((e) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF6366F1)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    e.value,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => prov.removeSkillAt(e.key),
                    child: const FaIcon(
                        FontAwesomeIcons.timesCircle, color: Colors.white70,
                        size: 14),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: prov.skillController,
                decoration: InputDecoration(
                  hintText: 'Add a skill',
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                ),
                style: GoogleFonts.poppins(fontSize: 14),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                padding: const EdgeInsets.all(14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => prov.addSkillEntry(context),
              child: const FaIcon(
                  FontAwesomeIcons.plus, size: 18, color: Colors.white),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEducation(ProfileProvider_NEW prov) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                FaIcon(FontAwesomeIcons.graduationCap,
                    color: const Color(0xFF6366F1), size: 28),
                const SizedBox(width: 12),
                Text(
                  'Education Background',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111827),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildIOSTextField(
              label: 'Institution Name',
              controller: _institutionCtrl,
              icon: FontAwesomeIcons.building,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildIOSTextField(
                    label: 'Duration',
                    controller: _durationCtrl,
                    icon: FontAwesomeIcons.clock,
                    hint: 'e.g. 2016 - 2020',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildIOSTextField(
                    label: 'Major Subjects',
                    controller: _majorCtrl,
                    icon: FontAwesomeIcons.book,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildIOSTextField(
              label: 'Marks / CGPA',
              controller: _marksCtrl,
              icon: FontAwesomeIcons.checkCircle,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                prov.tempSchool = _institutionCtrl.text;
                prov.tempEduStart = _durationCtrl.text;
                prov.tempFieldOfStudy = _majorCtrl.text;
                prov.tempDegree = _marksCtrl.text;
                prov.addEducationEntry(context);
                _institutionCtrl.clear();
                _durationCtrl.clear();
                _majorCtrl.clear();
                _marksCtrl.clear();
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const FaIcon(FontAwesomeIcons.plusCircle, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Add Education',
                    style: GoogleFonts.poppins(
                        fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (prov.educationalProfile.isNotEmpty) ...[
              Text(
                'Added Education',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 12),
              ...prov.educationalProfile
                  .asMap()
                  .entries
                  .map((e) {
                final item = e.value;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const FaIcon(
                            FontAwesomeIcons.building, color: Color(0xFF6366F1),
                            size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['institutionName']?.toString() ??
                                  'Institution',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF111827),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${item['duration'] ??
                                  ''} • ${item['majorSubjects'] ?? ''}',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => prov.removeEducationAt(e.key),
                        icon: const FaIcon(
                            FontAwesomeIcons.trash, color: Color(0xFFEF4444),
                            size: 18),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProfessionalProfile(ProfileProvider_NEW prov) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                FaIcon(
                    FontAwesomeIcons.briefcase, color: const Color(0xFF6366F1),
                    size: 28),
                const SizedBox(width: 12),
                Text(
                  'Professional Profile',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111827),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildIOSTextField(
              label: 'Professional Summary',
              controller: _profSummaryCtrl,
              icon: FontAwesomeIcons.fileAlt,
              maxLines: 8,
              hint: 'Provide a detailed overview of your professional background...',
              onChanged: (v) {
                prov.professionalProfileSummary = v;
                prov.markPersonalDirty();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExperience(ProfileProvider_NEW prov) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                FaIcon(FontAwesomeIcons.clock, color: const Color(0xFF6366F1),
                    size: 28),
                const SizedBox(width: 12),
                Text(
                  'Professional Experience',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111827),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildIOSTextField(
              label: 'Experience Details',
              controller: _experienceTextCtrl,
              icon: FontAwesomeIcons.briefcase,
              maxLines: 5,
              hint: 'Job title, Company, Duration, Key responsibilities...',
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                prov.tempCompany = '';
                prov.tempRole = '';
                prov.tempExpStart = '';
                prov.tempExpEnd = '';
                prov.tempExpDescription = _experienceTextCtrl.text.trim();
                prov.addExperienceEntry(context);
                _experienceTextCtrl.clear();
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const FaIcon(FontAwesomeIcons.plusCircle, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Add Experience',
                    style: GoogleFonts.poppins(
                        fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (prov.professionalExperience.isNotEmpty) ...[
              Text(
                'Added Experience',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 12),
              ...prov.professionalExperience
                  .asMap()
                  .entries
                  .map((e) {
                final item = e.value;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDDEAFF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const FaIcon(FontAwesomeIcons.briefcase,
                            color: Color(0xFF6366F1), size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item['text']?.toString() ?? 'Experience',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: const Color(0xFF111827),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        onPressed: () => prov.removeExperienceAt(e.key),
                        icon: const FaIcon(
                            FontAwesomeIcons.trash, color: Color(0xFFEF4444),
                            size: 18),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCertifications(ProfileProvider_NEW prov) {
    return _buildListSection(
      title: 'Certifications',
      icon: FontAwesomeIcons.award,
      items: prov.certifications,
      controller: _singleLineCtrl,
      hint: 'Certification name',
      onAdd: () {
        prov.tempCertName = _singleLineCtrl.text.trim();
        prov.addCertificationEntry(context);
        _singleLineCtrl.clear();
      },
      onRemove: prov.removeCertificationAt,
      itemIcon: FontAwesomeIcons.award,
    );
  }

  Widget _buildPublications(ProfileProvider_NEW prov) {
    return _buildListSection(
      title: 'Publications',
      icon: FontAwesomeIcons.fileAlt,
      items: prov.publications,
      controller: _singleLineCtrl,
      hint: 'Publication title',
      onAdd: () {
        prov.addPublication(_singleLineCtrl.text);
        _singleLineCtrl.clear();
      },
      onRemove: prov.removePublicationAt,
      itemIcon: FontAwesomeIcons.file,
    );
  }

  Widget _buildAwards(ProfileProvider_NEW prov) {
    return _buildListSection(
      title: 'Awards & Honors',
      icon: FontAwesomeIcons.award,
      items: prov.awards,
      controller: _singleLineCtrl,
      hint: 'Award name',
      onAdd: () {
        prov.addAward(_singleLineCtrl.text);
        _singleLineCtrl.clear();
      },
      onRemove: prov.removeAwardAt,
      itemIcon: FontAwesomeIcons.trophy,
    );
  }

  Widget _buildReferences(ProfileProvider_NEW prov) {
    return _buildListSection(
      title: 'References',
      icon: FontAwesomeIcons.users,
      items: prov.references,
      controller: _singleLineCtrl,
      hint: 'Reference details',
      onAdd: () {
        prov.addReference(_singleLineCtrl.text);
        _singleLineCtrl.clear();
      },
      onRemove: prov.removeReferenceAt,
      itemIcon: FontAwesomeIcons.user,
    );
  }

  Widget _buildListSection({
    required String title,
    required IconData icon,
    required List<String> items,
    required TextEditingController controller,
    required String hint,
    required VoidCallback onAdd,
    required Function(int) onRemove,
    required IconData itemIcon,
  }) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                FaIcon(icon, color: const Color(0xFF6366F1), size: 28),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111827),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: hint,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      filled: true,
                      fillColor: const Color(0xFFF9FAFB),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                    ),
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: onAdd,
                  child: const FaIcon(FontAwesomeIcons.plus, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (items.isNotEmpty) ...[
              Text(
                'Added $title',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 12),
              ...items
                  .asMap()
                  .entries
                  .map((e) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: FaIcon(
                            itemIcon, color: const Color(0xFF6366F1), size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          e.value,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: const Color(0xFF111827),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => onRemove(e.key),
                        icon: const FaIcon(
                            FontAwesomeIcons.trash, color: Color(0xFFEF4444),
                            size: 18),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDocuments(ProfileProvider_NEW prov) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                FaIcon(FontAwesomeIcons.folder, color: const Color(0xFF6366F1),
                    size: 28),
                const SizedBox(width: 12),
                Text(
                  'Documents',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111827),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => _pickAndUploadDocument(prov),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const FaIcon(FontAwesomeIcons.cloudUploadAlt, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Upload Document',
                    style: GoogleFonts.poppins(
                        fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (prov.documents.isNotEmpty) ...[
              Text(
                'Uploaded Documents',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 12),
              ...prov.documents
                  .asMap()
                  .entries
                  .map((e) {
                final item = e.value;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEDED),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const FaIcon(
                            FontAwesomeIcons.fileAlt, color: Color(0xFFEF4444),
                            size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['name']?.toString() ?? 'Document',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF111827),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['contentType']?.toString() ?? '',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          prov.removeDocumentAt(e.key);
                          prov.saveDocumentsSection(context);
                        },
                        icon: const FaIcon(
                            FontAwesomeIcons.trash, color: Color(0xFFEF4444),
                            size: 18),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons(ProfileProvider_NEW prov) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 🔙 Previous Button
        if (_currentStep > 0)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF3F4F6),
              foregroundColor: const Color(0xFF111827),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18), // ↑ thicker
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14), // slightly rounder
              ),
              elevation: 1,
            ),
            onPressed: () {
              setState(() => _currentStep--);
              _animController.reset();
              _animController.forward();
              _scrollToCurrentStep();
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const FaIcon(FontAwesomeIcons.chevronLeft, size: 18), // ↑ larger
                const SizedBox(width: 10),
                Text(
                  'Previous',
                  style: GoogleFonts.poppins(
                    fontSize: 15, // ↑
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          )
        else
          const SizedBox(),

        // ✅ Save + Next Buttons
        Row(
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18), // ↑ thicker
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 2,
              ),
              onPressed: () => _saveCurrentSection(prov),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const FaIcon(FontAwesomeIcons.check, size: 18),
                  const SizedBox(width: 10),
                  Text(
                    'Save Section',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            if (_currentStep < _stepTitles.length - 1) ...[
              const SizedBox(width: 14),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
                ),
                onPressed: () {
                  setState(() => _currentStep++);
                  _animController.reset();
                  _animController.forward();
                  _scrollToCurrentStep();
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Next',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const FaIcon(FontAwesomeIcons.chevronRight, size: 18),
                  ],
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  void _saveCurrentSection(ProfileProvider_NEW prov) {
    switch (_currentStep) {
      case 0:
        prov.savePersonalSection(context);
        break;
      case 1:
        prov.saveEducationSection(context);
        break;
      case 2:
        prov.saveProfessionalProfileSection(context);
        break;
      case 3:
        prov.saveExperienceSection(context);
        break;
      case 4:
        prov.saveCertificationsSection(context);
        break;
      case 5:
        prov.savePublicationsSection(context);
        break;
      case 6:
        prov.saveAwardsSection(context);
        break;
      case 7:
        prov.saveReferencesSection(context);
        break;
      case 8:
        prov.saveDocumentsSection(context);
        break;
    }
  }

  Widget _buildIOSTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? hint,
    int maxLines = 1,
    Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            FaIcon(icon, color: const Color(0xFF6B7280), size: 14),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF374151),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint ?? label,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF3B82F6)),
            ),
          ),
          style: GoogleFonts.poppins(fontSize: 14),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Future<void> _pickAndUploadProfilePic(ProfileProvider_NEW prov) async {
    final res = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      withData: true,
      type: FileType.image,
    );
    if (res == null) return;

    final file = res.files.first;
    final bytes = file.bytes;
    if (bytes == null) return;

    final mimeType = lookupMimeType(file.name, headerBytes: bytes);
    await prov.uploadProfilePicture(
        Uint8List.fromList(bytes), file.name, mimeType: mimeType);
  }

  Future<void> _pickAndUploadDocument(ProfileProvider_NEW prov) async {
    final res = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      withData: true,
    );
    if (res == null) return;

    final file = res.files.first;
    final bytes = file.bytes;
    if (bytes == null) return;

    final mimeType = lookupMimeType(file.name, headerBytes: bytes);
    final entry = await prov.uploadDocument(
        Uint8List.fromList(bytes), file.name, mimeType: mimeType);
    if (entry != null) {
      _showWebNotification(
          context, 'Document uploaded successfully', isSuccess: true);
    } else {
      _showWebNotification(
          context, 'Failed to upload document', isSuccess: false);
    }
  }

  void _showWebNotification(BuildContext context, String message,
      {required bool isSuccess}) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                FaIcon(
                  isSuccess ? FontAwesomeIcons.checkCircle : FontAwesomeIcons
                      .timesCircle,
                  color: isSuccess ? const Color(0xFF10B981) : const Color(
                      0xFFEF4444),
                  size: 32,
                ),
                const SizedBox(width: 12),
                Text(
                  isSuccess ? 'Success' : 'Error',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            content: Text(
              message,
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'OK',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6366F1),
                  ),
                ),
              ),
            ],
          ),
    );
  }
}