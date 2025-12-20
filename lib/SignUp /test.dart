
// lib/screens/signup_screen_auth.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_portal/SignUp%20/signup_provider.dart';
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
  //static final String GEMINI_API_KEY = '';
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

  Future<void> onPickImage() async {
    final p = Provider.of<SignupProvider>(context, listen: false);
    p.generalError = null;

    try {
      await p.pickProfilePicture();

      if (p.generalError != null && p.generalError!.isNotEmpty) {
        if (!mounted) return;
        _showSnackBar(p.generalError!, isError: true);
      } else {
        if (!mounted) return;
        _showSnackBar('Image selected successfully', isError: false);
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Image pick failed: $e', isError: true);
    }
  }

  /*

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
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
        duration: Duration(milliseconds: isError ? 3500 : 2000),
      ),
    );
  }


   */
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

  Widget leftPanel(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final panelHeight = screenHeight * 1.15;

    return RepaintBoundary(
      child: Container(
        height: panelHeight,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                      'https://images.unsplash.com/photo-1556761175-b413da4baf72?ixlib=rb-4.0.3&auto=format&fit=crop&w=1374&q=80',
                    ),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.5),
                      BlendMode.darken,
                    ),
                  ),
                ),
              ),
            ),

            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.indigo.withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 20),

                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                                ),
                                child: Icon(Icons.work_outline_rounded, size: 36, color: Colors.white),
                              ),
                              SizedBox(width: 16),
                              Text(
                                'Maha Services',
                                style: GoogleFonts.poppins(
                                  fontSize: 34,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 30),

                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.white.withOpacity(0.2)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.verified_user_outlined, size: 24, color: Colors.greenAccent),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Enterprise Grade Security',
                                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                      Text(
                                        'Data encrypted & secure',
                                        style: TextStyle(fontSize: 13, color: Colors.white70),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text('Active', style: TextStyle(fontSize: 12, color: Colors.white)),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 30),

                          GridView.count(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 2.5,
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            children: [
                              _buildStatCard('Jobs Posted', '1,230', '+12% this month', Colors.blue),
                              _buildStatCard('Active Recruiters', '342', 'Online now', Colors.green),
                              _buildStatCard('Successful Hires', '5,410', '+28% growth', Colors.orange),
                            ],
                          ),

                          SizedBox(height: 30),

                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Platform Features',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                SizedBox(height: 12),
                                _buildFeature('Lightning-fast profile creation'),
                                _buildFeature('AI-powered job matching'),
                                _buildFeature('Premium employer connections'),
                              ],
                            ),
                          ),

                          SizedBox(height: 20),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, String subtitle, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.white70)),
          Text(subtitle, style: TextStyle(fontSize: 10, color: color)),
        ],
      ),
    );
  }

  Widget _buildFeature(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.check, size: 16, color: Colors.white70),
          SizedBox(width: 8),
          Text(text, style: TextStyle(fontSize: 13, color: Colors.white)),
        ],
      ),
    );
  }


  // ========== ACCOUNT PANEL ==========

  // ========== ACCOUNT PANEL ==========
  Widget accountPanel(BuildContext context, SignupProvider p) {
    final provider = context.watch<SignupProvider>();

    return Form(
      key: _formKeyAccount,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.indigo.shade200),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.indigo,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.account_circle_outlined, color: Colors.white, size: 26),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create Account',
                        style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Start your journey to find the perfect opportunity',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 30),

          // Role selector
          _buildRoleSelector(p),

          SizedBox(height: 30),

          // RECRUITER FLOW
          if (provider.role == 'recruiter') ...[
            _buildTextField(
              controller: provider.nameController,
              label: 'Full Name',
              hint: 'Enter your full name',
              icon: Icons.person_outline,
              validator: (v) => v?.trim().isEmpty ?? true ? 'Name required' : null,
            ),

            SizedBox(height: 18),

            _buildTextField(
              controller: provider.emailController,
              label: 'Email Address',
              hint: 'your.email@company.com',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              errorText: provider.emailError,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Email required';
                if (!RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(v.trim())) return 'Enter valid email';
                return null;
              },
            ),

            SizedBox(height: 18),

            _buildTextField(
              controller: provider.passwordController,
              label: 'Password',
              hint: 'Min. 8 characters',
              icon: Icons.lock_outline,
              obscureText: true,
              errorText: provider.passwordError,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Password required';
                if (v.length < 8) return 'Minimum 8 characters';
                return null;
              },
            ),

            SizedBox(height: 18),

            _buildTextField(
              controller: provider.confirmPasswordController,
              label: 'Confirm Password',
              hint: 'Re-enter password',
              icon: Icons.lock_outline,
              obscureText: true,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Confirm password';
                if (v != provider.passwordController.text) return 'Passwords must match';
                return null;
              },
            ),

            SizedBox(height: 40),

            Center(
              child: SizedBox(
                width: 280,
                child: ElevatedButton(
                  onPressed: () async {
                    final okForm = _formKeyAccount.currentState?.validate() ?? false;
                    final okEmail = provider.validateEmail();
                    final okPass = provider.validatePasswords();
                    final okName = provider.nameController.text.trim().isNotEmpty;

                    if (!okForm || !okEmail || !okPass || !okName) {
                      _showSnackBar('Please fix all errors before proceeding', isError: true);
                      return;
                    }

                    showDialog(context: context, barrierDismissible: false, builder: (_) => _buildLoadingDialog());

                    try {
                      final success = await provider.registerRecruiter();
                      if (mounted) Navigator.pop(context);

                      await Future.delayed(Duration(milliseconds: 300));

                      if (success) {
                        _showSnackBar('✓ Recruiter account created successfully!', isError: false);
                      } else {
                        _showSnackBar(provider.generalError ?? 'Failed to create account', isError: true);
                      }
                    } catch (e) {
                      if (mounted) Navigator.pop(context);
                      _showSnackBar('Error: ${e.toString()}', isError: true);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    padding: EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text('Create Recruiter Account', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),
            ),

            SizedBox(height: 20),
          ]
          // JOB SEEKER FLOW
          else ...[
            _buildTextField(
              controller: p.emailController,
              label: 'Email Address',
              hint: 'your.email@example.com',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              errorText: p.emailError,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Email required';
                if (!RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(v.trim())) return 'Enter valid email';
                return null;
              },
            ),

            SizedBox(height: 18),

            _buildTextField(
              controller: p.passwordController,
              label: 'Password',
              hint: 'Min. 8 characters',
              icon: Icons.lock_outline,
              obscureText: true,
              errorText: p.passwordError,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Password required';
                if (v.length < 8) return 'Minimum 8 characters';
                return null;
              },
            ),

            SizedBox(height: 18),

            _buildTextField(
              controller: p.confirmPasswordController,
              label: 'Confirm Password',
              hint: 'Re-enter password',
              icon: Icons.lock_outline,
              obscureText: true,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Confirm password';
                if (v != p.passwordController.text) return 'Passwords must match';
                return null;
              },
            ),

            SizedBox(height: 30),

            // CV Upload Section
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.indigo.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.indigo, borderRadius: BorderRadius.circular(10)),
                        child: Icon(Icons.description_outlined, color: Colors.white, size: 22),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Do you have a CV/Resume?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                            Text('Upload for faster registration', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(child: _buildActionButton('Upload CV', Icons.upload_file_rounded, false, () {
                        p.revealCvUpload(reveal: true);
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          final ctx = _cvSectionKey.currentContext;
                          if (ctx != null) Scrollable.ensureVisible(ctx, duration: Duration(milliseconds: 400));
                        });
                      })),
                      SizedBox(width: 12),
                      Expanded(child: _buildActionButton('Continue Manually', Icons.arrow_forward_rounded, true, () {
                        final okForm = _formKeyAccount.currentState?.validate() ?? false;
                        final okEmail = p.validateEmail();
                        final okPass = p.validatePasswords();
                        if (!okForm || !okEmail || !okPass) {
                          _showSnackBar('Please fix all errors before proceeding', isError: true);
                          return;
                        }
                        p.revealNextPersonalField();
                        p.goToStep(1);
                        _animateStepChange();
                      })),
                    ],
                  ),

                  Consumer<SignupProvider>(
                    builder: (_, prov, __) {
                      if (!prov.showCvUploadSection) return SizedBox.shrink();
                      return Container(
                        key: _cvSectionKey,
                        margin: EdgeInsets.only(top: 20),
                        padding: EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.indigo.shade200),
                        ),
                        child: CvUploadSection(
                          extractor: extractor,
                          provider: prov,
                          onSuccess: () => context.go('/login'),
                          onManualContinue: () {
                            prov.revealCvUpload(reveal: false);
                            prov.revealNextPersonalField();
                            prov.goToStep(1);
                            _animateStepChange();
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingDialog() {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.indigo),
            SizedBox(height: 20),
            Text('Creating Your Account', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            Text('Please wait...', style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleSelector(SignupProvider p) {
    return Container(
      padding: EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(child: _buildRoleChip('Job Seeker', Icons.person_search_rounded, p.role == 'job_seeker', () => p.setRole('job_seeker'))),
          SizedBox(width: 6),
          Expanded(child: _buildRoleChip('Recruiter', Icons.business_center_rounded, p.role == 'recruiter', () => p.setRole('recruiter'))),
        ],
      ),
    );
  }

  Widget _buildRoleChip(String label, IconData icon, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? Colors.indigo : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: selected ? Colors.white : Colors.grey.shade700, size: 20),
            SizedBox(width: 8),
            Text(label, style: TextStyle(color: selected ? Colors.white : Colors.grey.shade700, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? errorText,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            prefixIcon: Icon(icon, color: Colors.indigo),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.indigo, width: 2)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.red.shade400)),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            errorText: errorText,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, bool primary, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: primary ? Colors.indigo : Colors.grey.shade200,
        foregroundColor: primary ? Colors.white : Colors.grey.shade800,
        padding: EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          SizedBox(width: 8),
          Text(label, style: TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
  // ========== PERSONAL PANEL ==========
  Widget personalPanel(BuildContext context, SignupProvider p) {
    final progress = p.computeProgress();

    return Form(
      key: _personalFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.indigo.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.indigo, borderRadius: BorderRadius.circular(10)),
                      child: Icon(Icons.person_outline_rounded, color: Colors.white, size: 24),
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Personal Profile', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                          SizedBox(height: 4),
                          Text('Tell us about yourself and showcase your expertise', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 18),
                // Progress
                Container(
                  padding: EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Profile Completion', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.indigo.shade900)),
                          Text('${(progress * 100).toInt()}%', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo)),
                        ],
                      ),
                      SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation(Colors.indigo),
                          minHeight: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 24),

          // Form Fields
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 720;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildResponsiveRow(isNarrow, [
                    if (p.personalVisibleIndex >= 0) _buildTextField2(p.nameController, 'Full Name', 'Enter your full name', Icons.person_outline, validator: (v) => v?.trim().isEmpty ?? true ? 'Name required' : null, onChanged: (v) => p.onFieldTypedAutoReveal(0, v)),
                    if (p.personalVisibleIndex >= 1) _buildTextField2(p.contactNumberController, 'Contact Number', '+92 300 1234567', Icons.phone_outlined, keyboardType: TextInputType.phone, validator: (v) {
                      if (v?.trim().isEmpty ?? true) return 'Contact required';
                      if (!RegExp(r'^[\d\+\-\s]{5,20}$').hasMatch(v!.trim())) return 'Enter valid number';
                      return null;
                    }, onChanged: (v) => p.onFieldTypedAutoReveal(1, v)),
                    if (p.personalVisibleIndex >= 2) _buildTextField2(p.nationalityController, 'Nationality', 'e.g., Pakistani', Icons.flag_outlined, validator: (v) => v?.trim().isEmpty ?? true ? 'Nationality required' : null, onChanged: (v) => p.onFieldTypedAutoReveal(2, v)),
                  ]),

                  SizedBox(height: 16),

                  if (p.personalVisibleIndex >= 3)
                    _buildTextField2(p.summaryController, 'Professional Summary', 'Brief description of your background and expertise', Icons.article_outlined, maxLines: 3, validator: (v) => v?.trim().isEmpty ?? true ? 'Summary required' : null, onChanged: (v) => p.onFieldTypedAutoReveal(3, v)),

                  SizedBox(height: 16),

                  if (p.personalVisibleIndex >= 4)
                    _buildResponsiveRow(isNarrow, [
                      Expanded(flex: 3, child: _buildAvatarCompact(p)),
                      Expanded(flex: 4, child: _buildSkillsCompact(p)),
                    ]),

                  SizedBox(height: 16),

                  if (p.personalVisibleIndex >= 5)
                    _buildResponsiveRow(isNarrow, [
                      Expanded(flex: 6, child: _buildTextField2(p.objectivesController, 'Career Objectives', 'What are your career goals?', Icons.flag_circle_rounded, maxLines: 3, validator: (v) => v?.trim().isEmpty ?? true ? 'Objectives required' : null, onChanged: (v) => p.onFieldTypedAutoReveal(5, v))),
                      Expanded(flex: 2, child: _buildDobCompact(p)),
                    ]),
                ],
              );
            },
          ),

          SizedBox(height: 32),

          // Navigation
          Row(
            children: [
              Expanded(child: OutlinedButton.icon(
                onPressed: () { p.goToStep(0); _animateStepChange(); },
                icon: Icon(Icons.arrow_back_rounded),
                label: Text('Back', style: TextStyle(fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              )),
              SizedBox(width: 12),
              Expanded(flex: 2, child: ElevatedButton.icon(
                onPressed: () {
                  if (!(_personalFormKey.currentState?.validate() ?? false)) {
                    _showSnackBar('Please complete all required fields', isError: true);
                    return;
                  }
                  if (p.skills.isEmpty) { _showSnackBar('Please add at least one skill', isError: true); return; }
                  if (p.dob == null) { _showSnackBar('Please select date of birth', isError: true); return; }
                  p.goToStep(2);
                  _animateStepChange();
                },
                icon: Icon(Icons.arrow_forward_rounded),
                label: Text('Next: Education', style: TextStyle(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, padding: EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveRow(bool isNarrow, List<Widget> children) {
    if (isNarrow) return Column(children: children.map((c) => Padding(padding: EdgeInsets.only(bottom: 16), child: c)).toList());
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: children.asMap().entries.map((e) {
      final isLast = e.key == children.length - 1;
      return Expanded(child: Padding(padding: EdgeInsets.only(right: isLast ? 0 : 16), child: e.value));
    }).toList());
  }

  Widget _buildTextField2(TextEditingController controller, String label, String hint, IconData icon, {TextInputType? keyboardType, int maxLines = 1, String? Function(String?)? validator, void Function(String)? onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            prefixIcon: Icon(icon, color: Colors.indigo),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.indigo, width: 2)),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarCompact(SignupProvider p) {
    Widget avatar = p.profilePicBytes != null
        ? CircleAvatar(radius: 50, backgroundImage: MemoryImage(p.profilePicBytes!))
        : (p.imageDataUrl != null
        ? CircleAvatar(radius: 50, backgroundImage: MemoryImage(base64Decode(p.imageDataUrl!.split(',').last)))
        : CircleAvatar(radius: 50, backgroundColor: Colors.indigo.shade100, child: Icon(Icons.person, size: 40, color: Colors.indigo.shade400)));

    return Container(
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.indigo.shade200)),
      child: Column(
        children: [
          avatar,
          SizedBox(height: 14),
          Text('Profile Photo', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          SizedBox(height: 12),
          Wrap(spacing: 10, runSpacing: 8, alignment: WrapAlignment.center, children: [
            ElevatedButton.icon(
              onPressed: () async {
                await p.pickProfilePicture();
                if (p.personalVisibleIndex == 4) p.revealNextPersonalField();
              },
              icon: Icon(Icons.upload_file, size: 18),
              label: Text(p.profilePicBytes == null && p.imageDataUrl == null ? 'Upload' : 'Change'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            ),
            if (p.profilePicBytes != null || p.imageDataUrl != null)
              OutlinedButton.icon(
                onPressed: p.removeProfilePicture,
                icon: Icon(Icons.delete_outline, size: 18),
                label: Text('Remove'),
                style: OutlinedButton.styleFrom(padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSkillsCompact(SignupProvider p) {
    return Container(
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.indigo.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.indigo, size: 24),
              SizedBox(width: 10),
              Text('Skills', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              Spacer(),
              Container(padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.indigo.shade100, borderRadius: BorderRadius.circular(20)), child: Text('${p.skills.length} added', style: TextStyle(fontSize: 12, color: Colors.indigo.shade900))),
            ],
          ),
          SizedBox(height: 14),
          if (p.skills.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: p.skills.asMap().entries.map((e) => Chip(
                label: Text(e.value),
                deleteIcon: Icon(Icons.close, size: 16),
                onDeleted: () => p.removeSkillAt(e.key),
                backgroundColor: Colors.indigo.shade50,
              )).toList(),
            ),
          SizedBox(height: 12),
          TextField(
            controller: p.skillInputController,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText: 'Type skill and press Enter',
              prefixIcon: Icon(Icons.add, color: Colors.indigo),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            onSubmitted: (v) {
              if (v.trim().isNotEmpty) {
                p.addSkill(v.trim());
                p.skillInputController.clear();
              }
            },
            onChanged: (v) => p.onFieldTypedAutoReveal(5, v),
          ),
        ],
      ),
    );
  }

  Widget _buildDobCompact(SignupProvider p) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.orange.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.cake_outlined, color: Colors.orange.shade700, size: 22),
              SizedBox(width: 8),
              Text('Date of Birth', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
          SizedBox(height: 20),
          Text(p.dob == null ? 'Not selected' : DateFormat.yMMMMd().format(p.dob!), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: p.dob == null ? Colors.grey : Colors.black)),
          SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().subtract(Duration(days: 365 * 22)),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now().subtract(Duration(days: 365 * 13)),
                  builder: (context, child) => Theme(data: Theme.of(context).copyWith(colorScheme: Theme.of(context).colorScheme.copyWith(primary: Colors.indigo)), child: child!),
                );
                if (picked != null) p.setDob(picked);
              },
              icon: Icon(Icons.calendar_today, color: Colors.orange.shade700),
              label: Text('Select Date', style: TextStyle(color: Colors.orange.shade700, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 12), side: BorderSide(color: Colors.orange.shade300), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            ),
          ),
        ],
      ),
    );
  }
  // ========== EDUCATION PANEL ==========
  Widget educationPanel(BuildContext context, SignupProvider p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Educational Background',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.indigo),
        ),
        SizedBox(height: 8),
        Text(
          'Add your academic qualifications',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        SizedBox(height: 30),

        if (p.educationalProfile.isEmpty)
          Container(
            padding: EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.indigo.shade200),
            ),
            child: Column(
              children: [
                Icon(Icons.school_outlined, size: 50, color: Colors.indigo.shade400),
                SizedBox(height: 16),
                Text('No education added yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.indigo.shade900)),
                SizedBox(height: 8),
                Text('Add at least one education entry to continue', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
              ],
            ),
          ),

        if (p.educationalProfile.isNotEmpty)
          ...p.educationalProfile.asMap().entries.map((entry) {
            final idx = entry.key;
            final data = entry.value;
            return Container(
              margin: EdgeInsets.only(bottom: 16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.indigo.shade200),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.indigo, borderRadius: BorderRadius.circular(10)),
                    child: Icon(Icons.school_rounded, color: Colors.white, size: 24),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(data['institutionName'] ?? '', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                        SizedBox(height: 6),
                        Text(data['majorSubjects'] ?? '', style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
                        SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade500),
                            SizedBox(width: 4),
                            Text(data['duration'] ?? '', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                            SizedBox(width: 16),
                            Icon(Icons.grade, size: 14, color: Colors.grey.shade500),
                            SizedBox(width: 4),
                            Text(data['marksOrCgpa'] ?? '', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(onPressed: () => _showEditEducationDialog(p, idx, data), icon: Icon(Icons.edit_outlined, color: Colors.indigo)),
                      IconButton(onPressed: () => p.removeEducation(idx), icon: Icon(Icons.delete_outline, color: Colors.red.shade600)),
                    ],
                  ),
                ],
              ),
            );
          }),

        SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _showAddEducationDialog(p),
            icon: Icon(Icons.add_rounded),
            label: Text('Add Education', style: TextStyle(fontWeight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, padding: EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          ),
        ),

        SizedBox(height: 40),

        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () { p.goToStep(1); _animateStepChange(); },
                icon: Icon(Icons.arrow_back_rounded),
                label: Text('Back', style: TextStyle(fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (!p.educationSectionIsComplete()) {
                    _showSnackBar('Please add at least one education entry', isError: true);
                    return;
                  }
                  p.goToStep(3);
                  _animateStepChange();
                },
                icon: Icon(Icons.arrow_forward_rounded),
                label: Text('Review & Submit', style: TextStyle(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, padding: EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showAddEducationDialog(SignupProvider p) {
    final inst = TextEditingController();
    final dur = TextEditingController();
    final major = TextEditingController();
    final marks = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.school, color: Colors.indigo, size: 28),
            SizedBox(width: 12),
            Text('Add Education', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDialogField(inst, 'Institution / University', Icons.account_balance),
                SizedBox(height: 16),
                _buildDialogField(dur, 'Duration (e.g. 2017-2021)', Icons.calendar_today),
                SizedBox(height: 16),
                _buildDialogField(major, 'Major Subjects', Icons.book),
                SizedBox(height: 16),
                _buildDialogField(marks, 'Marks / CGPA', Icons.grade),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: TextStyle(color: Colors.grey.shade600))),
          ElevatedButton(
            onPressed: () {
              if ([inst, dur, major, marks].any((c) => c.text.trim().isEmpty)) {
                _showSnackBar('Please fill all fields', isError: true);
                return;
              }
              p.addEducation(
                institutionName: inst.text.trim(),
                duration: dur.text.trim(),
                majorSubjects: major.text.trim(),
                marksOrCgpa: marks.text.trim(),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: Text('Add', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _showEditEducationDialog(SignupProvider p, int idx, Map<String, dynamic> data) {
    final inst = TextEditingController(text: data['institutionName'] ?? '');
    final dur = TextEditingController(text: data['duration'] ?? '');
    final major = TextEditingController(text: data['majorSubjects'] ?? '');
    final marks = TextEditingController(text: data['marksOrCgpa'] ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.edit, color: Colors.indigo, size: 28),
            SizedBox(width: 12),
            Text('Edit Education', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDialogField(inst, 'Institution', Icons.account_balance),
                SizedBox(height: 16),
                _buildDialogField(dur, 'Duration', Icons.calendar_today),
                SizedBox(height: 16),
                _buildDialogField(major, 'Major Subjects', Icons.book),
                SizedBox(height: 16),
                _buildDialogField(marks, 'Marks / CGPA', Icons.grade),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: TextStyle(color: Colors.grey.shade600))),
          ElevatedButton(
            onPressed: () {
              p.updateEducation(idx, {
                'institutionName': inst.text.trim(),
                'duration': dur.text.trim(),
                'majorSubjects': major.text.trim(),
                'marksOrCgpa': marks.text.trim(),
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: Text('Save', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogField(TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.indigo),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.indigo, width: 2)),
        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
  // ========== REVIEW PANEL ==========
  Widget reviewPanel(BuildContext context, SignupProvider p) {
    Widget avatar() {
      if (p.profilePicBytes != null) {
        return CircleAvatar(radius: 60, backgroundImage: MemoryImage(p.profilePicBytes!));
      }
      if (p.imageDataUrl != null) {
        try {
          final bytes = base64Decode(p.imageDataUrl!.split(',').last);
          return CircleAvatar(radius: 60, backgroundImage: MemoryImage(bytes));
        } catch (_) {}
      }
      return CircleAvatar(radius: 60, backgroundColor: Colors.indigo.shade100, child: Icon(Icons.person, size: 50, color: Colors.indigo.shade400));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Review & Submit', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.indigo)),
        SizedBox(height: 8),
        Text('Review your information before submitting', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
        SizedBox(height: 30),

        // Profile Overview Card
        Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.indigo.shade200),
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      avatar(),
                      SizedBox(height: 16),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(color: Colors.indigo, borderRadius: BorderRadius.circular(20)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(p.role == 'job_seeker' ? Icons.person_search : Icons.business_center, size: 16, color: Colors.white),
                            SizedBox(width: 6),
                            Text(p.role == 'job_seeker' ? 'Job Seeker' : 'Recruiter', style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(child: Text(p.nameController.text.trim(), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.indigo))),
                            IconButton(onPressed: () { p.goToStep(1); _animateStepChange(); }, icon: Icon(Icons.edit_outlined, color: Colors.indigo)),
                          ],
                        ),
                        SizedBox(height: 10),
                        Text(p.summaryController.text.trim(), style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.5)),
                        SizedBox(height: 16),
                        _buildInfo(Icons.email_outlined, p.emailController.text.trim()),
                        SizedBox(height: 8),
                        _buildInfo(Icons.phone_outlined, p.contactNumberController.text.trim()),
                        SizedBox(height: 8),
                        _buildInfo(Icons.flag_outlined, p.nationalityController.text.trim()),
                        SizedBox(height: 8),
                        _buildInfo(Icons.cake_outlined, p.dob == null ? 'Not set' : DateFormat.yMMMMd().format(p.dob!)),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 30),
              Divider(),

              SizedBox(height: 20),
              _buildSection('Skills', Icons.lightbulb_outline, () { p.goToStep(1); _animateStepChange(); },
                  Wrap(spacing: 10, runSpacing: 10, children: p.skills.map((s) => Chip(label: Text(s), backgroundColor: Colors.indigo.shade50)).toList())),

              SizedBox(height: 20),
              _buildSection('Career Objectives', Icons.flag_circle_rounded, () { p.goToStep(1); _animateStepChange(); },
                  Text(p.objectivesController.text.trim(), style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.6))),

              SizedBox(height: 20),
              _buildSection('Education', Icons.school_outlined, () { p.goToStep(2); _animateStepChange(); },
                  Column(children: p.educationalProfile.map((edu) => Container(
                    margin: EdgeInsets.only(bottom: 12),
                    padding: EdgeInsets.all(14),
                    decoration: BoxDecoration(color: Colors.indigo.shade50, borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.school, color: Colors.indigo, size: 20),
                            SizedBox(width: 10),
                            Expanded(child: Text(edu['institutionName'] ?? '', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.indigo))),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(edu['majorSubjects'] ?? '', style: TextStyle(fontSize: 13)),
                        SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
                            SizedBox(width: 4),
                            Text(edu['duration'] ?? '', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                            SizedBox(width: 16),
                            Icon(Icons.grade, size: 14, color: Colors.grey.shade600),
                            SizedBox(width: 4),
                            Text(edu['marksOrCgpa'] ?? '', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                          ],
                        ),
                      ],
                    ),
                  )).toList())),
            ],
          ),
        ),

        SizedBox(height: 40),

        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () { p.goToStep(2); _animateStepChange(); },
                icon: Icon(Icons.arrow_back_rounded),
                label: Text('Back', style: TextStyle(fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              flex: 2,
// Updated: reviewPanel button logic (now only creates account, then navigates to new profile screen)
              child: ElevatedButton.icon(
                onPressed: p.isLoading ? null : () async {
                  // Only create Firebase Auth account + upload profile picture if selected
                  final accountOk = await p.createJobSeekerAccount();

                  if (accountOk) {
                    // Success: Show brief confirmation
                    _showSnackBar('Account created successfully! Now complete your profile.', isError: false);

                    // Navigate to a fresh new screen for profile creation
                    // Replace '/complete-profile' with your actual route
                    context.go('/profile-builder');

                    // Optional: reset step if you want to start fresh
                    // p.currentStep = 0; // don't reset if you have separate flow
                  } else {
                    _showSnackBar(p.generalError ?? 'Failed to create account', isError: true);
                  }
                },
                icon: p.isLoading
                    ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Icon(Icons.check_circle_outline),
                label: Text('Create Account & Continue', style: TextStyle(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  padding: EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.indigo),
        SizedBox(width: 12),
        Expanded(child: Text(text, style: TextStyle(fontSize: 13, color: Colors.grey.shade700))),
      ],
    );
  }

  Widget _buildSection(String title, IconData icon, VoidCallback onEdit, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: Colors.indigo),
                SizedBox(width: 8),
                Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo)),
              ],
            ),
            IconButton(onPressed: onEdit, icon: Icon(Icons.edit_outlined, color: Colors.indigo)),
          ],
        ),
        SizedBox(height: 12),
        content,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SignupProvider(),
      child: const _SignUp_Screen2Inner(),
    );
  }
}

// ========== INNER WIDGET ==========
class _SignUp_Screen2Inner extends StatelessWidget {
  const _SignUp_Screen2Inner();

  @override
  Widget build(BuildContext context) {
    final p = Provider.of<SignupProvider>(context);
    final state = context.findAncestorStateOfType<_SignUp_Screen2State>()!;
    final isWide = MediaQuery.of(context).size.width > 900;

    Widget bodyForStep() {
      switch (p.currentStep) {
        case 0:
          return state.accountPanel(context, p);
        case 1:
          return state.personalPanel(context, p);
        case 2:
          return state.educationPanel(context, p);
        case 3:
          return state.reviewPanel(context, p);
        default:
          return state.accountPanel(context, p);
      }
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            const HeaderNav(),

            // Main content
            Expanded(
              child: Row(
                children: [
                  // Left decorative panel (wide screens only)
                  if (isWide)
                    Flexible(
                      flex: 5,
                      child: RepaintBoundary(child: state.leftPanel(context)),
                    ),

                  // Right form panel
                  Flexible(
                    flex: 5,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          padding: EdgeInsets.all(32),
                          child: FadeTransition(
                            opacity: state._fadeAnimation,
                            child: SlideTransition(
                              position: state._slideAnimation,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Mobile header (logo + step)
                                  if (!isWide) ...[
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: Colors.indigo,
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Icon(Icons.work_outline_rounded, color: Colors.white, size: 24),
                                            ),
                                            SizedBox(width: 12),
                                            Text(
                                              'Maha Services',
                                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.indigo),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.indigo.shade50,
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(color: Colors.indigo.shade200),
                                          ),
                                          child: Text(
                                            'Step ${p.currentStep + 1} of 4',
                                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.indigo.shade800),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 20),
                                  ],

                                  // Form content (this is the main scrollable part)
                                  bodyForStep(),

                                  SizedBox(height: 30),

                                  // Footer login link
                                  Center(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text('Already have an account?', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                                        TextButton(
                                          onPressed: () => context.go('/login'),
                                          child: Text('Login', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.indigo)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
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