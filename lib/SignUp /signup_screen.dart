// lib/screens/signup_screen.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_portal/SignUp%20/signup_panels.dart';
import 'package:job_portal/SignUp%20/signup_provider.dart';
import 'package:job_portal/SignUp%20/signup_widgets.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../Constant/Header_Nav.dart';
import '../extractor_CV/cv_extraction_UI.dart';
import '../extractor_CV/cv_extractor.dart';
import '../main.dart';

class SignUp_Screen2 extends StatefulWidget {
  const SignUp_Screen2({super.key});

  @override
  State<SignUp_Screen2> createState() => _SignUp_Screen2State();
}

class _SignUp_Screen2State extends State<SignUp_Screen2>
    with TickerProviderStateMixin {
  final _formKeyAccount = GlobalKey<FormState>();
  final _personalFormKey = GlobalKey<FormState>();
  final _educationFormKey = GlobalKey<FormState>();

  final _editInstitution = TextEditingController();
  final _editDuration = TextEditingController();
  final _editMajor = TextEditingController();
  final _editMarks = TextEditingController();

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  static final String GEMINI_API_KEY = Env.geminiApiKey;
  late final extractor = CvExtractor(geminiApiKey: GEMINI_API_KEY);
  final GlobalKey _cvSectionKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.1, 0), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _fadeController.forward();
    _slideController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = Provider.of<SignupProvider>(context, listen: false);
      p.clearAll();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _editInstitution.dispose();
    _editDuration.dispose();
    _editMajor.dispose();
    _editMarks.dispose();
    super.dispose();
  }

  void _animateStepChange() {
    _fadeController.reset();
    _slideController.reset();
    _fadeController.forward();
    _slideController.forward();
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isError
                    ? Icons.error_outline_rounded
                    : Icons.check_circle_outline_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
        margin: const EdgeInsets.all(16),
        duration: Duration(milliseconds: isError ? 3500 : 2500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SignupProvider(),
      child: _SignUp_Screen2Inner(
        state: this,
        fadeAnimation: _fadeAnimation,
        slideAnimation: _slideAnimation,
      ),
    );
  }
}

// ========== INNER WIDGET ==========
class _SignUp_Screen2Inner extends StatelessWidget {
  final _SignUp_Screen2State state;
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;

  const _SignUp_Screen2Inner({
    required this.state,
    required this.fadeAnimation,
    required this.slideAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final p = Provider.of<SignupProvider>(context);
    final isWide = MediaQuery.of(context).size.width > 900;

    Widget bodyForStep() {
      final panels = SignupPanels(
        state: state,
        formKeyAccount: state._formKeyAccount,
        personalFormKey: state._personalFormKey,
        educationFormKey: state._educationFormKey,
        editInstitution: state._editInstitution,
        editDuration: state._editDuration,
        editMajor: state._editMajor,
        editMarks: state._editMarks,
        cvSectionKey: state._cvSectionKey,
        extractor: state.extractor,
      );

      switch (p.currentStep) {
        case 0:
          return panels.accountPanel(context, p);
        case 1:
          return panels.personalPanel(context, p);
        case 2:
          return panels.educationPanel(context, p);
        case 3:
          return panels.reviewPanel(context, p);
        default:
          return panels.accountPanel(context, p);
      }
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            const HeaderNav(),
            Expanded(
              child: Row(
                children: [
                  if (isWide)
                    Flexible(
                      flex: 5,
                      child: RepaintBoundary(
                        child: SignupWidgets.leftPanel(context),
                      ),
                    ),
                  Flexible(
                    flex: 5,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          padding: const EdgeInsets.all(32),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: SizedBox(
                              height: constraints.maxHeight,
                              child: FadeTransition(
                                opacity: fadeAnimation,
                                child: SlideTransition(
                                  position: slideAnimation,
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      if (!isWide)
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  padding:
                                                  const EdgeInsets.all(12),
                                                  decoration: BoxDecoration(
                                                    gradient:
                                                    const LinearGradient(
                                                      colors: [
                                                        Color(0xFF6366F1),
                                                        Color(0xFF3949AB),
                                                      ],
                                                    ),
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        12),
                                                  ),
                                                  child: const Icon(
                                                    Icons.work_outline_rounded,
                                                    color: Colors.white,
                                                    size: 24,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Text(
                                                  'Maha Services',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.w700,
                                                    color:
                                                    const Color(0xFF6366F1),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Container(
                                              padding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 8,
                                              ),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.indigo.shade50,
                                                    Colors.indigo.shade50,
                                                  ],
                                                ),
                                                borderRadius:
                                                BorderRadius.circular(20),
                                                border: Border.all(
                                                  color:
                                                  Colors.indigo.shade100,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.info_outline,
                                                    size: 16,
                                                    color:
                                                    Colors.indigo.shade700,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    'Step ${p.currentStep + 1} of 4',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 12,
                                                      fontWeight:
                                                      FontWeight.w600,
                                                      color: Colors
                                                          .indigo.shade700,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      if (!isWide) const SizedBox(height: 12),
                                      Flexible(
                                        child: SingleChildScrollView(
                                          padding: const EdgeInsets.fromLTRB(
                                            30,
                                            5,
                                            30,
                                            5,
                                          ),
                                          child: bodyForStep(),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Already have an account?',
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                context.go('/login'),
                                            child: Text(
                                              'Login',
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                color: const Color(0xFF6366F1),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}