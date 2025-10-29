// lib/screens/signup_screen.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_portal/SignUp%20/signup_provider.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class SignUp_Screen2 extends StatefulWidget {
  const SignUp_Screen2({Key? key}) : super(key: key);

  @override
  State<SignUp_Screen2> createState() => _SignUp_Screen2State();
}

class _SignUp_Screen2State extends State<SignUp_Screen2> with TickerProviderStateMixin {
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

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

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

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: Duration(milliseconds: isError ? 3000 : 1500),
      ),
    );
  }

  // ========== LEFT PANEL - REDESIGNED ==========
  Widget leftPanel(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF6366F1),
              const Color(0xFF283593),
              const Color(0xFF3949AB),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Animated background pattern
            Positioned.fill(
              child: CustomPaint(
                painter: _BackgroundPatternPainter(),
              ),
            ),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo and branding
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        Icons.work_outline_rounded,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 32),

                    Text(
                      'TalentForge',
                      style: GoogleFonts.poppins(
                        fontSize: 42,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -1,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      'Build your profile.\nGet discovered by top companies.',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                        height: 1.6,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Stats cards
                    _buildStatCard(
                      icon: Icons.work_outline_rounded,
                      label: 'Jobs Posted',
                      value: '1,230',
                      delay: 0,
                    ),

                    const SizedBox(height: 16),

                    _buildStatCard(
                      icon: Icons.people_outline_rounded,
                      label: 'Active Recruiters',
                      value: '342',
                      delay: 100,
                    ),

                    const SizedBox(height: 16),

                    _buildStatCard(
                      icon: Icons.trending_up_rounded,
                      label: 'Successful Hires',
                      value: '5,410',
                      delay: 200,
                    ),

                    const Spacer(),

                    // Trust indicators
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.15),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.verified_user_outlined,
                            color: Colors.white.withOpacity(0.9),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Your data is secure and encrypted',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required int delay,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, animValue, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - animValue)),
          child: Opacity(
            opacity: animValue,
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.85),
                      fontWeight: FontWeight.w500,
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

  // ========== ACCOUNT PANEL ==========
  Widget accountPanel(BuildContext context, SignupProvider p) {
    return Form(
      key: _formKeyAccount,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Create Account',
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF6366F1),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start your journey to find the perfect opportunity',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: 32),

          // Role selector with modern design
          _buildRoleSelector(p),

          const SizedBox(height: 24),

          _buildEnhancedTextField(
            controller: p.emailController,
            label: 'Email Address',
            hint: 'Enter your email',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            errorText: p.emailError,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Email required';
              final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
              if (!emailRegex.hasMatch(v.trim())) return 'Enter valid email';
              return null;
            },
          ),

          const SizedBox(height: 24),

          _buildEnhancedTextField(
            controller: p.passwordController,
            label: 'Password',
            hint: 'Create a strong password',
            icon: Icons.lock_outline_rounded,
            obscureText: true,
            errorText: p.passwordError,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Password required';
              if (v.length < 8) return 'Minimum 8 characters';
              return null;
            },
          ),

          const SizedBox(height: 24),

          _buildEnhancedTextField(
            controller: p.confirmPasswordController,
            label: 'Confirm Password',
            hint: 'Re-enter your password',
            icon: Icons.lock_outline_rounded,
            obscureText: true,
            errorText: p.passwordError,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Confirm your password';
              if (v != p.passwordController.text) return 'Passwords must match';
              return null;
            },
          ),

          const SizedBox(height: 32),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.indigo.shade50,
                  Colors.indigo.shade50,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.indigo.shade100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.description_outlined, color: Colors.indigo.shade700),
                    const SizedBox(width: 12),
                    Text(
                      'Do you have a CV?',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.indigo.shade900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        label: 'Yes, Upload CV',
                        icon: Icons.upload_file_rounded,
                        isPrimary: false,
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (c) => _buildComingSoonDialog(c),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionButton(
                        label: 'No, Continue Manually',
                        icon: Icons.arrow_forward_rounded,
                        isPrimary: true,
                        onPressed: () {
                          final okForm = _formKeyAccount.currentState?.validate() ?? false;
                          final okEmail = p.validateEmail();
                          final okPass = p.validatePasswords();

                          if (!okForm || !okEmail || !okPass) {
                            _showSnackBar(
                              'Please fix all errors before proceeding',
                              isError: true,
                            );
                            return;
                          }

                          p.revealNextPersonalField();
                          p.goToStep(1);
                          _animateStepChange();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleSelector(SignupProvider p) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildRoleChip(
              label: 'Job Seeker',
              icon: Icons.person_search_rounded,
              isSelected: p.role == 'job_seeker',
              onTap: () => p.setRole('job_seeker'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildRoleChip(
              label: 'Recruiter',
              icon: Icons.business_center_rounded,
              isSelected: p.role == 'recruiter',
              onTap: () => p.setRole('recruiter'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Material(
        color: isSelected ? const Color(0xFF6366F1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isSelected ? Colors.white : Colors.grey.shade600,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? errorText,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLines: maxLines,
          onChanged: onChanged,
          validator: validator,
          style: GoogleFonts.poppins(fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
              color: Colors.grey.shade400,
              fontSize: 14,
            ),
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF6366F1).withOpacity(0.1),
                    const Color(0xFF3949AB).withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF6366F1), size: 20),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF3949AB), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.red.shade300),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.red.shade400, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            errorText: errorText,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required bool isPrimary,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        gradient: isPrimary
            ? const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF3949AB)],
        )
            : null,
        color: isPrimary ? null : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isPrimary ? null : Border.all(color: Colors.indigo.shade200),
        boxShadow: isPrimary
            ? [
          BoxShadow(
            color: const Color(0xFF3949AB).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isPrimary ? Colors.white : Colors.indigo.shade700,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isPrimary ? Colors.white : Colors.indigo.shade700,
                  ),
                ),
              ],
            ),
          ),
        ),
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
          Text(
            'Personal Profile',
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF6366F1),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tell us about yourself',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: 20),

          // Progress indicator (unchanged)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.indigo.shade50, Colors.indigo.shade50],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Profile Completion',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.indigo.shade900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          backgroundColor: Colors.white,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo.shade600),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.indigo.shade700,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // -------- Row 1: Name | Contact | Nationality (responsive) ----------
          LayoutBuilder(builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 720;
            if (isNarrow) {
              // stack vertically on small screens
              return Column(
                children: [
                  if (p.personalVisibleIndex >= 0)
                    _buildEnhancedTextField(
                      controller: p.nameController,
                      label: 'Full Name',
                      hint: 'Enter your full name',
                      icon: Icons.person_outline_rounded,
                      onChanged: (v) => p.onFieldTypedAutoReveal(0, v),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Name required' : null,
                    ),
                  const SizedBox(height: 12),
                  if (p.personalVisibleIndex >= 1)
                    _buildEnhancedTextField(
                      controller: p.contactNumberController,
                      label: 'Contact Number',
                      hint: '+92 300 1234567',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      onChanged: (v) => p.onFieldTypedAutoReveal(1, v),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Contact required';
                        final phoneRegex = RegExp(r'^[\d\+\-\s]{5,20}$');
                        if (!phoneRegex.hasMatch(v.trim())) return 'Enter valid number';
                        return null;
                      },
                    ),
                  const SizedBox(height: 12),
                  if (p.personalVisibleIndex >= 2)
                    _buildEnhancedTextField(
                      controller: p.nationalityController,
                      label: 'Nationality',
                      hint: 'e.g., Pakistani',
                      icon: Icons.flag_outlined,
                      onChanged: (v) => p.onFieldTypedAutoReveal(2, v),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Nationality required' : null,
                    ),
                ],
              );
            }

            // wide layout - three columns
            return Row(
              children: [
                if (p.personalVisibleIndex >= 0)
                  Expanded(
                    flex: 3,
                    child: _buildEnhancedTextField(
                      controller: p.nameController,
                      label: 'Full Name',
                      hint: 'Enter your full name',
                      icon: Icons.person_outline_rounded,
                      onChanged: (v) => p.onFieldTypedAutoReveal(0, v),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Name required' : null,
                    ),
                  ),
                const SizedBox(width: 12),
                if (p.personalVisibleIndex >= 1)
                  Expanded(
                    flex: 2,
                    child: _buildEnhancedTextField(
                      controller: p.contactNumberController,
                      label: 'Contact Number',
                      hint: '+92 300 1234567',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      onChanged: (v) => p.onFieldTypedAutoReveal(1, v),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Contact required';
                        final phoneRegex = RegExp(r'^[\d\+\-\s]{5,20}$');
                        if (!phoneRegex.hasMatch(v.trim())) return 'Enter valid number';
                        return null;
                      },
                    ),
                  ),
                const SizedBox(width: 12),
                if (p.personalVisibleIndex >= 2)
                  Expanded(
                    flex: 2,
                    child: _buildEnhancedTextField(
                      controller: p.nationalityController,
                      label: 'Nationality',
                      hint: 'e.g., Pakistani',
                      icon: Icons.flag_outlined,
                      onChanged: (v) => p.onFieldTypedAutoReveal(2, v),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Nationality required' : null,
                    ),
                  ),
              ],
            );
          }),

          const SizedBox(height: 16),

          // -------- Row 2: Summary (full width) ----------
          if (p.personalVisibleIndex >= 3)
            _buildEnhancedTextField(
              controller: p.summaryController,
              label: 'Professional Summary',
              hint: 'Brief description of your professional background',
              icon: Icons.article_outlined,
              maxLines: 3,
              onChanged: (v) => p.onFieldTypedAutoReveal(3, v),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Summary required' : null,
            ),

          const SizedBox(height: 16),

          // -------- Row 3: Avatar (compact) | Skills (compact) ----------
          if (p.personalVisibleIndex >= 4)
            LayoutBuilder(builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 720;
              if (isNarrow) {
                // stack vertically on narrow widths
                return Column(
                  children: [
                    _buildAvatarCompact(p),
                    const SizedBox(height: 12),
                    _buildSkillsCompact(p),
                  ],
                );
              }

              // wide: avatar left, skills right
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: _buildAvatarCompact(p)),
                  const SizedBox(width: 16),
                  Expanded(flex: 4, child: _buildSkillsCompact(p)),
                ],
              );
            }),

          const SizedBox(height: 16),

          // -------- Row 4: Objectives | DOB (single row responsive) ----------
          if (p.personalVisibleIndex >= 6)
            LayoutBuilder(builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 720;
              if (isNarrow) {
                return Column(
                  children: [
                    _buildEnhancedTextField(
                      controller: p.objectivesController,
                      label: 'Career Objectives',
                      hint: 'What are your career goals?',
                      icon: Icons.flag_circle_rounded,
                      maxLines: 3,
                      onChanged: (v) => p.onFieldTypedAutoReveal(6, v),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Objectives required' : null,
                    ),
                    const SizedBox(height: 12),
                    _buildDobCompact(p),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    flex: 6,
                    child: _buildEnhancedTextField(
                      controller: p.objectivesController,
                      label: 'Career Objectives',
                      hint: 'What are your career goals?',
                      icon: Icons.flag_circle_rounded,
                      maxLines: 3,
                      onChanged: (v) => p.onFieldTypedAutoReveal(6, v),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Objectives required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(flex: 2, child: _buildDobCompact(p)),
                ],
              );
            }),

          const SizedBox(height: 22),

          // Buttons (unchanged)
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    p.goToStep(0);
                    _animateStepChange();
                  },
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: Text(
                    'Back',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: Colors.grey.shade300, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: _buildGradientButton(
                  label: 'Next: Education',
                  icon: Icons.arrow_forward_rounded,
                  onPressed: () {
                    final okForm = _personalFormKey.currentState?.validate() ?? false;

                    if (!okForm) {
                      _showSnackBar(
                        'Please complete all required fields',
                        isError: true,
                      );
                      return;
                    }

                    if (p.skills.isEmpty) {
                      _showSnackBar('Please add at least one skill', isError: true);
                      return;
                    }

                    if (p.dob == null) {
                      _showSnackBar('Please select date of birth', isError: true);
                      return;
                    }

                    p.goToStep(2);
                    _animateStepChange();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildAvatarCompact(SignupProvider p) {
    Widget avatarPreview() {
      if (p.profilePicBytes != null) {
        return CircleAvatar(
          radius: 50,
          backgroundColor: Colors.grey.shade100,
          backgroundImage: MemoryImage(p.profilePicBytes!),
        );
      }
      if (p.imageDataUrl != null) {
        try {
          final bytes = base64Decode(p.imageDataUrl!.split(',').last);
          return CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey.shade100,
            backgroundImage: MemoryImage(bytes),
          );
        } catch (_) {}
      }
      return CircleAvatar(
        radius: 50,
        backgroundColor: Colors.indigo.shade50,
        child: Icon(Icons.person_outline_rounded, size: 40, color: Colors.indigo.shade300),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        border: Border.all(color: Colors.indigo.shade50),
      ),
      child: Row(
      children: [
        Column(
        children: [
          avatarPreview(),
          const SizedBox(height: 8),
          Text(
            'Profile Photo',
            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
        ],
    ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(padding: EdgeInsets.all(10),

              child: _buildActionButton(
                label: p.profilePicBytes == null && p.imageDataUrl == null ? 'Upload' : 'Change',
                icon: Icons.upload_file_rounded,
                isPrimary: true,
                onPressed: () async {
                  await p.pickProfilePicture();
                  if (p.personalVisibleIndex == 4) p.revealNextPersonalField();
                },
              ),
            ),
            if (p.profilePicBytes != null || p.imageDataUrl != null) ...[
              const SizedBox(width: 8),
              _buildActionButton(
                label: 'Remove',
                icon: Icons.delete_outline,
                isPrimary: false,
                onPressed: () => p.removeProfilePicture(),
              ),
            ],
          ],
        ),
          ]
      ),

    );
  }

  Widget _buildSkillsCompact(SignupProvider p) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        border: Border.all(color: Colors.purple.shade50),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.lightbulb_outline, color: Colors.purple.shade700),
            const SizedBox(width: 8),
            Text('Skills', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 8),
          if (p.skills.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: p.skills.asMap().entries.map((e) {
                return Chip(
                  label: Text(e.value, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500)),
                  deleteIcon: const Icon(Icons.close_rounded, size: 16),
                  onDeleted: () => p.removeSkillAt(e.key),
                  backgroundColor: Colors.purple.shade50,
                );
              }).toList(),
            ),
          const SizedBox(height: 8),
          TextField(
            controller: p.skillInputController,
            textInputAction: TextInputAction.done,
            style: GoogleFonts.poppins(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Type skill and press Enter',
              hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 13),
              prefixIcon: Icon(Icons.add_circle_outline, color: Colors.purple.shade600),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: (v) => p.onFieldTypedAutoReveal(5, v),
            onSubmitted: (v) {
              if (v.trim().isNotEmpty) {
                p.addSkill(v);
                p.skillInputController.clear();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDobCompact(SignupProvider p) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        border: Border.all(color: Colors.orange.shade50),
      ),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.cake_outlined, color: Colors.orange.shade700)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Date of Birth', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.orange.shade900)),
              const SizedBox(height: 4),
              Text(p.dob == null ? 'Not selected' : DateFormat.yMMMMd().format(p.dob!), style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
            ]),
          ),
          _buildActionButton(
            label: 'Select',
            icon: Icons.calendar_today_outlined,
            isPrimary: true,
            onPressed: () async {
              final now = DateTime.now();
              final initial = DateTime(now.year - 22);
              final picked = await showDatePicker(context: context, initialDate: initial, firstDate: DateTime(1900), lastDate: DateTime(now.year - 13));
              if (picked != null) p.setDob(picked);
            },
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
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF6366F1),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Add your academic qualifications',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),

        const SizedBox(height: 24),

        if (p.educationalProfile.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.indigo.shade50, Colors.indigo.shade50],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.indigo.shade100, width: 2),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.school_outlined,
                  size: 48,
                  color: Colors.indigo.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  'No education added yet',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.indigo.shade900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add at least one education entry to continue',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

        if (p.educationalProfile.isNotEmpty)
          ...p.educationalProfile.asMap().entries.map((entry) {
            final idx = entry.key;
            final data = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, Colors.indigo.shade50],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.indigo.shade100),
                boxShadow: [
                  BoxShadow(
                    color: Colors.indigo.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF3949AB)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                title: Text(
                  data['institutionName'] ?? '',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['majorSubjects'] ?? '',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 12, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Text(
                            data['duration'] ?? '',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(Icons.grade, size: 12, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Text(
                            data['marksOrCgpa'] ?? '',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => _showEditEducationDialog(p, idx, data),
                      icon: Icon(Icons.edit_outlined, color: Colors.indigo.shade700),
                      tooltip: 'Edit',
                    ),
                    IconButton(
                      onPressed: () => p.removeEducation(idx),
                      icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
                      tooltip: 'Delete',
                    ),
                  ],
                ),
              ),
            );
          }),

        const SizedBox(height: 16),

        SizedBox(
          width: double.infinity,
          child: _buildGradientButton(
            label: 'Add Education',
            icon: Icons.add_rounded,
            onPressed: () => _showAddEducationDialog(p),
          ),
        ),

        const SizedBox(height: 32),

        Row(
          children: [
            Padding(
    padding: EdgeInsetsGeometry.all(10),
          child:  Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  p.goToStep(1);
                  _animateStepChange();
                },
                icon: const Icon(Icons.arrow_back_rounded),
                label: Text(
                  'Back',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Colors.grey.shade300, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: _buildGradientButton(
                label: 'Review & Submit',
                icon: Icons.arrow_forward_rounded,
                onPressed: () {
                  if (!p.educationSectionIsComplete()) {
                    _showSnackBar(
                      'Please add at least one education entry',
                      isError: true,
                    );
                    return;
                  }
                  p.goToStep(3);
                  _animateStepChange();
                },
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
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF3949AB)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.school, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'Add Education',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Form(
            key: _educationFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDialogTextField(
                  controller: inst,
                  label: 'Institution / University',
                  icon: Icons.account_balance,
                ),
                const SizedBox(height: 16),
                _buildDialogTextField(
                  controller: dur,
                  label: 'Duration (e.g. 2017-2021)',
                  icon: Icons.calendar_today,
                ),
                const SizedBox(height: 16),
                _buildDialogTextField(
                  controller: major,
                  label: 'Major Subjects',
                  icon: Icons.book,
                ),
                const SizedBox(height: 16),
                _buildDialogTextField(
                  controller: marks,
                  label: 'Marks / CGPA',
                  icon: Icons.grade,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(c).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (inst.text.trim().isEmpty ||
                  dur.text.trim().isEmpty ||
                  major.text.trim().isEmpty ||
                  marks.text.trim().isEmpty) {
                _showSnackBar(
                  'Please fill all education fields',
                  isError: true,
                );
                return;
              }
              p.addEducation(
                institutionName: inst.text,
                duration: dur.text,
                majorSubjects: major.text,
                marksOrCgpa: marks.text,
              );
              Navigator.of(c).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              'Add',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditEducationDialog(SignupProvider p, int idx, Map<String, dynamic> data) {
    _editInstitution.text = data['institutionName'] ?? '';
    _editDuration.text = data['duration'] ?? '';
    _editMajor.text = data['majorSubjects'] ?? '';
    _editMarks.text = data['marksOrCgpa'] ?? '';

    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF3949AB)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.edit, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'Edit Education',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogTextField(
                controller: _editInstitution,
                label: 'Institution',
                icon: Icons.account_balance,
              ),
              const SizedBox(height: 16),
              _buildDialogTextField(
                controller: _editDuration,
                label: 'Duration',
                icon: Icons.calendar_today,
              ),
              const SizedBox(height: 16),
              _buildDialogTextField(
                controller: _editMajor,
                label: 'Major Subjects',
                icon: Icons.book,
              ),
              const SizedBox(height: 16),
              _buildDialogTextField(
                controller: _editMarks,
                label: 'Marks / CGPA',
                icon: Icons.grade,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(c).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final newEntry = {
                'institutionName': _editInstitution.text.trim(),
                'duration': _editDuration.text.trim(),
                'majorSubjects': _editMajor.text.trim(),
                'marksOrCgpa': _editMarks.text.trim(),
              };
              p.updateEducation(idx, newEntry);
              Navigator.of(c).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              'Save',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      style: GoogleFonts.poppins(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(fontSize: 13),
        prefixIcon: Icon(icon, size: 20, color: const Color(0xFF6366F1)),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3949AB), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  // ========== REVIEW PANEL ==========
  Widget reviewPanel(BuildContext context, SignupProvider p) {
    Widget avatarCard() {
      if (p.profilePicBytes != null) {
        return CircleAvatar(
          radius: 70,
          backgroundColor: Colors.grey.shade100,
          backgroundImage: MemoryImage(p.profilePicBytes!),
        );
      }
      if (p.imageDataUrl != null) {
        try {
          final bytes = base64Decode(p.imageDataUrl!.split(',').last);
          return CircleAvatar(
            radius: 70,
            backgroundColor: Colors.grey.shade100,
            backgroundImage: MemoryImage(bytes),
          );
        } catch (_) {}
      }
      return CircleAvatar(
        radius: 70,
        backgroundColor: Colors.indigo.shade50,
        child: Icon(
          Icons.person_outline_rounded,
          size: 60,
          color: Colors.indigo.shade300,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Review & Submit',
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF6366F1),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Review your information before submitting',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),

        const SizedBox(height: 24),

        // Profile Overview Card
        RepaintBoundary(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Colors.indigo.shade50],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.indigo.shade100, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.indigo.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Avatar and Name Section
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.indigo.withOpacity(0.2),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: avatarCard(),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6366F1), Color(0xFF3949AB)],
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  p.role == 'job_seeker'
                                      ? Icons.person_search_rounded
                                      : Icons.business_center_rounded,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  p.role == 'job_seeker' ? 'Job Seeker' : 'Recruiter',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    p.nameController.text.trim(),
                                    style: GoogleFonts.poppins(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF6366F1),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    p.goToStep(1);
                                    _animateStepChange();
                                  },
                                  icon: Icon(
                                    Icons.edit_outlined,
                                    color: Colors.indigo.shade600,
                                  ),
                                  tooltip: 'Edit Personal Info',
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              p.summaryController.text.trim(),
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildInfoRow(
                              Icons.email_outlined,
                              p.emailController.text.trim(),
                            ),
                            const SizedBox(height: 8),
                            _buildInfoRow(
                              Icons.phone_outlined,
                              p.contactNumberController.text.trim(),
                            ),
                            const SizedBox(height: 8),
                            _buildInfoRow(
                              Icons.flag_outlined,
                              p.nationalityController.text.trim(),
                            ),
                            const SizedBox(height: 8),
                            _buildInfoRow(
                              Icons.cake_outlined,
                              p.dob == null
                                  ? 'Not set'
                                  : DateFormat.yMMMMd().format(p.dob!),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),

                  // Skills Section
                  _buildReviewSection(
                    title: 'Skills',
                    icon: Icons.lightbulb_outlined,
                    onEdit: () {
                      p.goToStep(1);
                      _animateStepChange();
                    },
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: p.skills.map((skill) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.indigo.shade100,
                                Colors.indigo.shade100,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.indigo.shade200),
                          ),
                          child: Text(
                            skill,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.indigo.shade900,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Objectives Section
                  _buildReviewSection(
                    title: 'Career Objectives',
                    icon: Icons.flag_circle_rounded,
                    onEdit: () {
                      p.goToStep(1);
                      _animateStepChange();
                    },
                    child: Text(
                      p.objectivesController.text.trim(),
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                        height: 1.6,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Education Section
                  _buildReviewSection(
                    title: 'Education',
                    icon: Icons.school_outlined,
                    onEdit: () {
                      p.goToStep(2);
                      _animateStepChange();
                    },
                    child: Column(
                      children: p.educationalProfile.map((edu) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.indigo.shade100),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF6366F1),
                                          Color(0xFF3949AB),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.school,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      edu['institutionName'] ?? '',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF6366F1),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                edu['majorSubjects'] ?? '',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 12,
                                    color: Colors.grey.shade500,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    edu['duration'] ?? '',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Icon(
                                    Icons.grade,
                                    size: 12,
                                    color: Colors.grey.shade500,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    edu['marksOrCgpa'] ?? '',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 32),

        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  p.goToStep(2);
                  _animateStepChange();
                },
                icon: const Icon(Icons.arrow_back_rounded),
                label: Text(
                  'Back',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  side: BorderSide(color: Colors.grey.shade300, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF3949AB)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3949AB).withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: p.isLoading
                        ? null
                        : () async {
                      final ok = await p.submitAllAndCreateAccount();
                      if (ok) {
                        if (!mounted) return;
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (c) => WillPopScope(
                            onWillPop: () async => false,
                            child: AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              title: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF6366F1),
                                          Color(0xFF3949AB),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.check_circle_outline,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Finalizing Setup',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Finishing account setup...',
                                    style: GoogleFonts.poppins(),
                                  ),
                                  const SizedBox(height: 24),
                                  const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFF6366F1),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );

                        await Future.delayed(const Duration(seconds: 2));

                        if (Navigator.canPop(context)) {
                          Navigator.of(context).pop();
                        }

                        p.clearAll();

                        _showSnackBar(
                          'Account created & data saved successfully!',
                          isError: false,
                        );

                        // Navigate to home or login
                        // Navigator.of(context).pushReplacementNamed('/home');
                      } else {
                        if (!mounted) return;
                        _showSnackBar(
                          p.generalError ?? 'Failed to sign up',
                          isError: true,
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Center(
                      child: p.isLoading
                          ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                          : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            color: Colors.white,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Submit & Create Account',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.indigo.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: Colors.indigo.shade600),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewSection({
    required String title,
    required IconData icon,
    required VoidCallback onEdit,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: const Color(0xFF6366F1)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF6366F1),
                  ),
                ),
              ],
            ),
            IconButton(
              onPressed: onEdit,
              icon: Icon(Icons.edit_outlined, color: Colors.indigo.shade600),
              tooltip: 'Edit',
            ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildGradientButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF3949AB)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3949AB).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(icon, color: Colors.white, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildComingSoonDialog(BuildContext c) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF3949AB)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.info_outline, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            'Coming Soon',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
          ),
        ],
      ),
      content: Text(
        'CV upload feature is coming soon. Stay tuned!',
        style: GoogleFonts.poppins(),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(c).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6366F1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text('OK', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        ),
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
  const _SignUp_Screen2Inner({Key? key}) : super(key: key);

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
        child: Row(
          children: [
            if (isWide)
              Flexible(
                flex: 4,
                child: RepaintBoundary(child: state.leftPanel(context)),
              ),

            Flexible(
              flex: 6,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: FadeTransition(
                  opacity: state._fadeAnimation,
                  child: SlideTransition(
                    position: state._slideAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (!isWide)
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF6366F1),
                                          Color(0xFF3949AB),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.work_outline_rounded,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'TalentForge',
                                    style: GoogleFonts.poppins(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF6366F1),
                                    ),
                                  ),
                                ],
                              ),

                            // Step indicator
                            Container(
                              padding: const EdgeInsets.symmetric(
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
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.indigo.shade100),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 16,
                                    color: Colors.indigo.shade700,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Step ${p.currentStep + 1} of 4',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.indigo.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Main content card
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(50),
                            child: bodyForStep(),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Footer
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account?',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            TextButton(
                              onPressed: () => context.go('/login'),
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
          ],
        ),
      ),
    );
  }
}

// ========== CUSTOM PAINTER FOR BACKGROUND PATTERN ==========
class _BackgroundPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..style = PaintingStyle.fill;

    const spacing = 40.0;

    for (double i = 0; i < size.width; i += spacing) {
      for (double j = 0; j < size.height; j += spacing) {
        canvas.drawCircle(Offset(i, j), 2, paint);
      }
    }

    // Draw some decorative lines
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(0, size.height * 0.3),
      Offset(size.width, size.height * 0.35),
      linePaint,
    );

    canvas.drawLine(
      Offset(0, size.height * 0.7),
      Offset(size.width, size.height * 0.65),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}