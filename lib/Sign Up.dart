// lib/Screens/Job_Seeker/sign_up_elegant.dart
import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'Constant/Header_Nav.dart';
import 'widgets/signup_steps.dart';
import 'widgets/signup_widgets.dart';
import 'Signup_Provider.dart';

class SignUp_Screen extends StatefulWidget {
  const SignUp_Screen({Key? key}) : super(key: key);

  @override
  State<SignUp_Screen> createState() => _SignUp_ScreenState();
}

class _SignUp_ScreenState extends State<SignUp_Screen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  int _step = 0;
  int _totalSteps = 13;
  late PageController _reviewPageController;
  int _currentReviewPage = 0;
  String role = 'Job Seeker';
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nationalityController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  DateTime? _dob;
  final _fatherController = TextEditingController();

  String? _imageDataUrl;
  int? _imageBytes;

  final List<Map<String, String>> _educations = [];
  final List<Map<String, String>> _experiences = [];
  final List<String> _skills = [];
  final List<String> _misc = [];
  final List<String> _certs = [];
  final List<String> _refs = [];

  final _skillController = TextEditingController();

  String? _psid;
  bool _paid = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  late Map<int, StepDetails> _jobSeekerSteps;
  late Map<int, StepDetails> _recruiterSteps;

  // Color scheme
  final primaryColor = const Color(0xFF6366F1);
  final secondaryColor = const Color(0xFF8B5CF6);
  final accentColor = const Color(0xFFEC4899);

  // Scroll controllers for desktop/mobile form areas
  final ScrollController _desktopFormScrollController = ScrollController();
  final ScrollController _mobileFormScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
    _fadeController.forward();
    _reviewPageController = PageController();

    _jobSeekerSteps = {
      0: StepDetails(icon: Icons.person_outline_rounded, title: 'Role', subtitle: 'Choose your path'),
      1: StepDetails(icon: Icons.badge_outlined, title: 'Name', subtitle: 'Your identity'),
      2: StepDetails(icon: Icons.mail_outline_rounded, title: 'Email', subtitle: 'Stay connected'),
      3: StepDetails(icon: Icons.phone_outlined, title: 'Phone', subtitle: 'Contact info'),
      4: StepDetails(icon: Icons.flag_outlined, title: 'Nationality', subtitle: 'Your origin'),
      5: StepDetails(icon: Icons.lock_outline_rounded, title: 'Password', subtitle: 'Secure access'),
      6: StepDetails(icon: Icons.family_restroom_outlined, title: 'Details', subtitle: 'Personal info'),
      7: StepDetails(icon: Icons.camera_alt_outlined, title: 'Photo', subtitle: 'Your face'),
      8: StepDetails(icon: Icons.school_outlined, title: 'Education', subtitle: 'Academic background'),
      9: StepDetails(icon: Icons.work_outline_rounded, title: 'Experience', subtitle: 'Career history'),
      10: StepDetails(icon: Icons.lightbulb_outline_rounded, title: 'Skills', subtitle: 'Your expertise'),
      11: StepDetails(icon: Icons.verified_outlined, title: 'Certificates', subtitle: 'Credentials'),
      12: StepDetails(icon: Icons.group_outlined, title: 'References', subtitle: 'Recommendations'),
      13: StepDetails(icon: Icons.check_circle_outline_rounded, title: 'Review', subtitle: 'Final check'),
    };

    _recruiterSteps = {
      0: StepDetails(icon: Icons.person_outline_rounded, title: 'Role', subtitle: 'Choose your path'),
      1: StepDetails(icon: Icons.badge_outlined, title: 'Name', subtitle: 'Your identity'),
      2: StepDetails(icon: Icons.mail_outline_rounded, title: 'Email', subtitle: 'Stay connected'),
      3: StepDetails(icon: Icons.phone_outlined, title: 'Phone', subtitle: 'Contact info'),
      4: StepDetails(icon: Icons.flag_outlined, title: 'Nationality', subtitle: 'Your origin'),
      5: StepDetails(icon: Icons.lock_outline_rounded, title: 'Password', subtitle: 'Secure access'),
      6: StepDetails(icon: Icons.check_circle_outline_rounded, title: 'Review', subtitle: 'Final check'),
    };
    _updateStepsForRole();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _nameController.dispose();
    _reviewPageController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _nationalityController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _fatherController.dispose();
    _skillController.dispose();
    _fadeController?.dispose();
    _desktopFormScrollController.dispose();
    _mobileFormScrollController.dispose();
    super.dispose();
  }

  void _updateStepsForRole() {
    setState(() {
      if (role == 'Recruiter') {
        _totalSteps = 6;
      } else {
        _totalSteps = 13;
      }
      if (_step > _totalSteps) _step = _totalSteps;
    });
  }

  void _next() {
    if (!_validateCurrentStep()) return;
    if (_step < _totalSteps) {
      setState(() => _step++);
      _fadeController.reset();
      _fadeController.forward();

      // After changing step, animate scroll to top for form panel (desktop + mobile)
      _desktopFormScrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      _mobileFormScrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  void _back() {
    if (_step > 0) {
      setState(() => _step--);
      _fadeController.reset();
      _fadeController.forward();

      _desktopFormScrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      _mobileFormScrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  bool _validateCurrentStep() {
    final stepsMap = (role == 'Recruiter') ? _recruiterSteps : _jobSeekerSteps;
    final stepDetails = stepsMap[_step];
    final stepTitle = (stepDetails?.title ?? '').toString().toLowerCase();

    if (stepTitle.isEmpty) return true;

    switch (stepTitle) {
      case 'name':
        if (_nameController.text.trim().isEmpty) {
          _showSnack('Please enter your full name', isError: true);
          return false;
        }
        return true;
      case 'email':
        if (!_emailController.text.contains('@')) {
          _showSnack('Please enter a valid email address', isError: true);
          return false;
        }
        return true;
      case 'phone':
        if (_phoneController.text.trim().isEmpty || _phoneController.text.trim().length < 7) {
          _showSnack('Please enter a valid phone number', isError: true);
          return false;
        }
        return true;
      case 'password':
        if (_passwordController.text.length < 6) {
          _showSnack('Password must be at least 6 characters', isError: true);
          return false;
        }
        if (_passwordController.text != _confirmController.text) {
          _showSnack('Passwords do not match', isError: true);
          return false;
        }
        return true;
      case 'nationality':
        if (_nationalityController.text.trim().isEmpty) {
          _showSnack('Please enter your nationality', isError: true);
          return false;
        }
        return true;
      case 'details':
      case 'personal':
      case 'personal information':
        if (_dob == null) {
          _showSnack('Please select your date of birth', isError: true);
          return false;
        }
        if (_fatherController.text.trim().isEmpty) {
          _showSnack('Please enter father\'s name', isError: true);
          return false;
        }
        return true;
      case 'photo':
      case 'photo upload':
      case 'image':
        if (_imageDataUrl == null) {
          _showSnack('Please upload a profile image (max 2 MB)', isError: true);
          return false;
        }
        return true;
      default:
        return true;
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(msg, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500))),
          ],
        ),
        backgroundColor: isError ? const Color(0xFFEF4444) : const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _pickImageWeb() async {
    if (!kIsWeb) {
      _showSnack("Image upload is only available on web", isError: true);
      return;
    }

    final uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.click();

    await uploadInput.onChange.first;
    if (uploadInput.files == null || uploadInput.files!.isEmpty) return;

    final file = uploadInput.files!.first;
    const maxBytes = 2 * 1024 * 1024;
    if (file.size > maxBytes) {
      _showSnack('Selected image exceeds 2 MB', isError: true);
      return;
    }

    final reader = html.FileReader();
    reader.readAsDataUrl(file);
    await reader.onLoad.first;
    setState(() {
      _imageDataUrl = reader.result as String?;
      _imageBytes = file.size;
    });
  }

  void _generatePsid() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final rand = (1000 + (DateTime.now().microsecond % 9000)).toString();
    _psid = 'EP${now.toString().substring(now.toString().length - 6)}$rand';
  }

  Widget _stepContent() {
    final stepBuilder = SignUpSteps(
      reviewPageController: _reviewPageController,
      currentReviewPage: _currentReviewPage,
      onReviewPageChanged: (index) {
        setState(() => _currentReviewPage = index);
      },
      role: role,
      nameController: _nameController,
      emailController: _emailController,
      phoneController: _phoneController,
      nationalityController: _nationalityController,
      passwordController: _passwordController,
      confirmController: _confirmController,
      fatherController: _fatherController,
      skillController: _skillController,
      dob: _dob,
      imageDataUrl: _imageDataUrl,
      educations: _educations,
      experiences: _experiences,
      skills: _skills,
      certs: _certs,
      refs: _refs,
      obscurePassword: _obscurePassword,
      obscureConfirm: _obscureConfirm,
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
      accentColor: accentColor,
      onRoleChanged: (newRole) {
        setState(() {
          role = newRole;
          _updateStepsForRole();
          if (role == 'Job Seeker' && _psid == null) _generatePsid();
        });
      },
      onDobChanged: (date) => setState(() => _dob = date),
      onObscurePasswordToggle: () => setState(() => _obscurePassword = !_obscurePassword),
      onObscureConfirmToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
      onPickImage: _pickImageWeb,
      onAddEducation: () => SignUpDialogs.addEducationDialog(context, primaryColor, (edu) {
        setState(() => _educations.add(edu));
      }),
      onAddExperience: () => SignUpDialogs.addExperienceDialog(context, secondaryColor, (exp) {
        setState(() => _experiences.add(exp));
      }),
      onAddSkill: () {
        final v = _skillController.text.trim();
        if (v.isEmpty) return;
        if (!_skills.contains(v)) {
          setState(() {
            _skills.add(v);
            _skillController.clear();
          });
        }
      },
      onRemoveEducation: (index) => setState(() => _educations.removeAt(index)),
      onRemoveExperience: (index) => setState(() => _experiences.removeAt(index)),
      onRemoveSkill: (skill) => setState(() => _skills.remove(skill)),
      onRemoveCert: (cert) => setState(() => _certs.remove(cert)),
      onRemoveRef: (ref) => setState(() => _refs.remove(ref)),
      onAddCert: () => SignUpDialogs.addSimpleItemDialog(
        context,
        'Add Certification',
        'Certificate Name',
        primaryColor,
            (item) => setState(() => _certs.add(item)),
      ),
      onAddRef: () => SignUpDialogs.addSimpleItemDialog(
        context,
        'Add Reference',
        'Reference (Name, Contact)',
        primaryColor,
            (item) => setState(() => _refs.add(item)),
      ),
    );

    return (role == 'Recruiter') ? stepBuilder.getRecruiterStep(_step) : stepBuilder.getJobSeekerStep(_step);
  }

  Future<void> _register() async {
    final provider = Provider.of<SignUpProvider>(context, listen: false);

    final userData = {
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'nationality': _nationalityController.text.trim(),
      'dob': _dob?.toIso8601String(),
      'father_name': _fatherController.text.trim(),
      'psid': _psid,
    };

    final profileData = {
      'image_data_url': _imageDataUrl,
      'educations': _educations,
      'experiences': _experiences,
      'skills': _skills,
      'certifications': _certs,
      'references': _refs,
      'misc': _misc,
    };

    final success = await provider.registerAndSaveAll(
      context,
      email: _emailController.text.trim(),
      password: _passwordController.text,
      role: role,
      userData: userData,
      profileData: profileData,
    );

    if (success) {
      _showSnack('Registration successful! Procced to Login! 🎉');
      Future.delayed(const Duration(milliseconds: 700));
      context.go('/login');
    }
  }

  // Helper that builds the form panel with adaptive, animated sizing and scrolling
  Widget _buildAdaptiveFormPanel({required Widget child, required double maxHeight, required bool isMobile}) {
    // For desktop we use the desktop controller; for mobile the mobile controller
    final controller = isMobile ? _mobileFormScrollController : _desktopFormScrollController;

    return SafeArea(
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: maxHeight),
          child: Scrollbar(
            thumbVisibility: true,
            controller: controller,
            child: SingleChildScrollView(
              controller: controller,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 28),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: maxHeight - 32),
                child: IntrinsicHeight(
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          const HeaderNav(),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxWidth = constraints.maxWidth;
                final maxHeight = constraints.maxHeight;

                // Mobile layout (narrow)
                if (maxWidth < 700) {
                  return _buildAdaptiveFormPanel(
                    isMobile: true,
                    maxHeight: maxHeight,
                    child: SignUpWidgets.buildFormContent(
                      context: context,
                      isStacked: true,
                      step: _step,
                      totalSteps: _totalSteps,
                      role: role,
                      jobSeekerSteps: _jobSeekerSteps,
                      recruiterSteps: _recruiterSteps,
                      fadeAnimation: _fadeAnimation,
                      stepContent: _stepContent(),
                      primaryColor: primaryColor,
                      onBack: _back,
                      onNext: (_step == _totalSteps) ? _register : _next,
                    ),
                  );
                }

                // Desktop/tablet: two-column layout. Left panel fixed, right panel adaptive/scrollable.
                return Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: SignUpWidgets.buildLeftPanel(primaryColor, secondaryColor, accentColor),
                    ),
                    Expanded(
                      flex: 7,
                      child: _buildAdaptiveFormPanel(
                        isMobile: false,
                        maxHeight: maxHeight,
                        child: SignUpWidgets.buildFormContent(
                          context: context,
                          isStacked: false,
                          step: _step,
                          totalSteps: _totalSteps,
                          role: role,
                          jobSeekerSteps: _jobSeekerSteps,
                          recruiterSteps: _recruiterSteps,
                          fadeAnimation: _fadeAnimation,
                          stepContent: _stepContent(),
                          primaryColor: primaryColor,
                          onBack: _back,
                          onNext: (_step == _totalSteps) ? _register : _next,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
