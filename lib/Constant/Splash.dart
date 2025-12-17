import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'CTA_Dynamic.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Maha Services - Smart End-To-End Hiring Platform',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.indigo,
        brightness: Brightness.dark,
      ),
      home: const LandingPage(),
    );
  }
}

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _workflowController;
  late Animation<double> _workflowAnimation;
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;
  late AnimationController _controller;

  late AnimationController _contentAnimationController;
  static const Color pureWhite = Color(0xFFFFFFFF);
  static Color charcoalGray = Colors.black87;
  // Your existing variables
  bool isDarkMode = false;
  int _activeStage = 0;

  // ADD THIS: Animation controller for particles
  late AnimationController _particleAnimationController;
  Timer? _stageTimer;

  // Workflow stages data - centralized
  final List<WorkflowStage> _stages = [
    WorkflowStage(
      step: 'Step 1',
      title: 'Candidate Register',
      subtitle: 'Create profile and showcase skills',
      icon: Icons.person_add_rounded,
      color: const Color(0xFF6366F1),
      details: [
        'Profile Registration',
        'Documents Upload',
        'CV Generation',
        'CV Analysis',
      ],
    ),

    WorkflowStage(
      step: 'Step 2',
      title: 'Recruiter Panel',
      subtitle: 'Shortlist and submit request',
      icon: Icons.how_to_reg_rounded,
      color: const Color(0xFFF59E0B),
      details: [
        'Candidates Section',
        'Request Submission',
        'Track Requests'
      ],
    ),
    WorkflowStage(
      step: 'Step 3',
      title: 'Admin Processes',
      subtitle: 'Review, train & evaluate',
      icon: Icons.admin_panel_settings_rounded,
      color: const Color(0xFFEC4899),
      details: [
        'Interview Scheduling',
        'Candidate Evaluation',
        'Skill Testing & Panel Review',
      ],
    ),
    WorkflowStage(
      step: 'Step 4',
      title: 'Handover to Recruiter',
      subtitle: 'Deliver trained candidates',
      icon: Icons.verified_rounded,
      color: const Color(0xFF8B5CF6),
      details: [
        'Candidate Training',
        'Skill Development',
        'Final Preparation',
        'Handover to Recruiter',
      ],
    ),
  ];

  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();

    _rotationController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();
    _rotationAnimation =
        Tween<double>(begin: 0, end: 2 * math.pi).animate(_rotationController);
    _particleAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _contentAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();



    _workflowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _workflowAnimation = CurvedAnimation(
      parent: _workflowController,
      curve: Curves.easeInOut,
    );
    _workflowController.forward();

    _stageTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        _activeStage = (_activeStage + 1) % _stages.length;
      });
    });

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();

    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _stageTimer?.cancel();
    _controller.dispose();

    _workflowController.dispose();
    _fadeController.dispose();
    _rotationController.dispose();
    _particleAnimationController.dispose();
    _contentAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0F172A) : Colors.transparent,
      body: Stack(
        children: [
          // Animated grid pattern background
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: _GridPainter(_controller.value),
                  size: Size.infinite,
                );
              },
            ),
          ),

          // Content on top of background
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                _buildTopBar(),
                _buildHeroSection(),
                //_buildWorkflowVisualization(),
                _buildFeaturesSection(),
                _buildFooter(),

              ],
            ),
          ),

          // Floating FAB-like CTA buttons
          ScrollAwareCTAButtons(
            isDarkMode: isDarkMode,
            scrollController: _scrollController,
          ),
        ],
      ),
    );
  }
  // ==================== TOP BAR ====================
  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 65, vertical: 10),
      decoration: BoxDecoration(
        color: isDarkMode
            ? const Color(0x00f9fafb)
            : Colors.transparent,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildEnhancedLogo(),
          _buildNavigation(),
        ],
      ),
    );
  }
  Widget _buildEnhancedLogo() {
    return Row(
      children: [
        // --- Replace shimmer container with your logo image
         Image.asset(
            'images/logo.png',
            width: 100,
            height: 100,
            fit: BoxFit.fill,
          ),

        const SizedBox(width: 14),

        // --- Brand title and subtitle
      ],
    );
  }

  Widget _buildNavigation() {
    return Row(
      children: [
        _buildNavItem('Features', Icons.stars_rounded),
        const SizedBox(width: 32),
        _buildNavItem('Workflow', Icons.account_tree_rounded),
        const SizedBox(width: 32),
        _buildNavItem('Pricing', Icons.payments_rounded),
        const SizedBox(width: 40),
        _buildThemeToggle(),
        const SizedBox(width: 16),

        _AnimatedButton(
          onPressed: () => context.go('/register'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFF59E0B).withOpacity(0.12),
                  const Color(0xFFEC4899).withOpacity(0.12),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFFF59E0B).withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF59E0B), Color(0xFFEC4899)],
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.business_center_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  "For Recruiters",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: isDarkMode ? const Color(0xFFFFFFFF) : const Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),


        // Login button (flat, no extra header shadow)
        _AnimatedButton(
          onPressed: () => context.go('/login'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFF6366F1),
                width: 2,
              ),
            ),
            child: Text(
              "Login",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: const Color(0xFF6366F1),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        _AnimatedButton(
          onPressed: () => context.go('/register'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Get Started",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                  color: Colors.white,
                ),

              ],
            ),
          ),
        ),
        const SizedBox(width: 16),

        _AnimatedButton(
          onPressed: () => context.go('/admin'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFF6366F1),
                width: 2,
              ),
            ),
            child: Text(
              "Admin Portal",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: const Color(0xFF6366F1),
              ),
            ),
          ),
        ),

      ],
    );
  }
  Widget _buildNavItem(String title, IconData icon) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {},
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isDarkMode ? const Color(0xFF94A3B8) : const Color(
                  0xFF6B7280),
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: isDarkMode ? const Color(0xFF94A3B8) : const Color(
                    0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildThemeToggle() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: toggleTheme,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF334155) : const Color(
                0xFFF3F4F6),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDarkMode ? const Color(0xFF475569) : const Color(
                  0xFFE5E7EB),
            ),
          ),
          child: Icon(
            isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            color: isDarkMode ? const Color(0xFFFBBF24) : const Color(
                0xFF6366F1),
            size: 20,
          ),
        ),
      ),
    );
  }
  Widget _buildAuthButtons() {
    return Row(
      children: [
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: Text(
            'Sign In',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? const Color(0xFFA5B4FC) : const Color(
                  0xFF6366F1),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withOpacity(0.4),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.rocket_launch_rounded, size: 18),
            label: Text(
              'Get Started',
              style: GoogleFonts.poppins(
                  fontSize: 15, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }

  // ==================== HERO SECTION ====================
  Widget _buildHeroSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [const Color(0x00f9fafb), const Color(0x00f9fafb)]
              : [
            const Color(0x00f9fafb),
            const Color(0x00f9fafb),
            const Color(0x00f9fafb)
          ],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Keep left content as-is but isolate it from repaints
          Expanded(
            flex: 5,
            child: RepaintBoundary(
              child: buildHeroContent(
                _contentAnimationController,
                isDarkMode,
                context,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Isolate the heavy circular workflow in its own repaint boundary
          Expanded(
            flex: 6,
            child: RepaintBoundary(
              child: _buildCircularWorkflow(),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildHeroContent(
      AnimationController animationController,
      bool isDarkMode,
      BuildContext context,
      ) {
    // Helper to create an animated + repaint-isolated child
    Widget animatedSection(Widget Function() builder) {
      return RepaintBoundary(
        child: AnimatedBuilder(
          animation: animationController,
          builder: (context, _) => builder(),
        ),
      );
    }

    // Helper for non-animated but still heavy sections (keeps them on their own layer)
    Widget staticSection(Widget child) => RepaintBoundary(child: child);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Animated badge
        animatedSection(() => _buildAnimatedBadge(animationController, isDarkMode)),
        const SizedBox(height: 30),

        // Headline (animated)
        animatedSection(() => _buildGradientHeadline(animationController, isDarkMode)),
        const SizedBox(height: 24),

        // Description (animated)
        animatedSection(() => _buildEnhancedDescription(animationController, isDarkMode)),
        const SizedBox(height: 32),

        // Feature highlights (may contain animated parts)
        animatedSection(() => _buildFeatureHighlights(animationController, isDarkMode)),
        const SizedBox(height: 40),

        // CTA Buttons (wrap in RepaintBoundary + AnimatedBuilder so hover/animation is isolated)
        animatedSection(() => _buildEnhancedCTAButtons(animationController, context, isDarkMode)),
        const SizedBox(height: 40),

        // Animated stats (definitely animated)
      //  animatedSection(() => _buildAnimatedStats(animationController, isDarkMode)),
     //   const SizedBox(height: 32),

        // Trust indicators (animated or static depending on implementation)
        animatedSection(() => _buildTrustIndicators(animationController, isDarkMode)),
      ],
    );
  }


  Widget _buildAnimatedBadge(AnimationController controller, bool isDarkMode) {
    final slideAnimation = Tween<Offset>(
      begin: const Offset(-0.5, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    ));

    return SlideTransition(
      position: slideAnimation,
      child: FadeTransition(
        opacity: controller,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDarkMode
                  ? [const Color(0xFF312E81), const Color(0xFF4C1D95)]
                  : [const Color(0xFFEDE9FE), const Color(0xFFDDD6FE)],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFF6366F1).withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Color(0xFF6366F1),
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'AI-Powered 4-Stage Hiring System',
                style: GoogleFonts.poppins(
                  color: isDarkMode ? const Color(0xFFDDD6FE) : const Color(0xFF6366F1),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildGradientHeadline(AnimationController controller, bool isDarkMode) {
    final slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: const Interval(0.1, 0.5, curve: Curves.easeOut),
    ));

    return SlideTransition(
      position: slideAnimation,
      child: FadeTransition(
        opacity: controller,
        child: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: isDarkMode
                ? [Colors.white, const Color(0xFFDDD6FE)]
                : [const Color(0xFF1F2937), const Color(0xFF6366F1)],
          ).createShader(bounds),
          child: Text(
            'Smart Hiring\nMade Simple',
            style: GoogleFonts.poppins(
              fontSize: 64,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.1,
              letterSpacing: -1,
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildEnhancedDescription(AnimationController controller, bool isDarkMode){
    final fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
    ));

    return FadeTransition(
      opacity: fadeAnimation,
      child: Container(
        padding: const EdgeInsets.only(left: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Connect job seekers with recruiters through an intelligent platform that streamlines the entire hiring process.',
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: isDarkMode ? const Color(0xFFCBD5E1) : const Color(0xFF4B5563),
                fontWeight: FontWeight.w400,
                height: 1.7,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.verified_rounded,
                  size: 20,
                  color: const Color(0xFF10B981),
                ),
                const SizedBox(width: 8),
                Text(
                  'Trusted Employment from Pakistan',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildFeatureHighlights(AnimationController controller, bool isDarkMode) {
    final slideAnimation = Tween<Offset>(
      begin: const Offset(-0.2, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
    ));

    final features = [
           {
        'icon': Icons.psychology_rounded,
        'text': 'AI-powered matching',
        'color': const Color(0xFF8B5CF6),
      },
      {
        'icon': Icons.speed_rounded,
        'text': '3x faster hiring',
        'color': const Color(0xFF10B981),
      }, {
        'icon': Icons.security,
        'text': 'Secure & End-To-End hiring',
        'color': const Color(0xFFF59E0B),
      },
    ];

    return SlideTransition(
      position: slideAnimation,
      child: FadeTransition(
        opacity: controller,
        child: Wrap(
          spacing: 16,
          runSpacing: 12,
          children: features.map((feature) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: (feature['color'] as Color).withOpacity(isDarkMode ? 0.15 : 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: (feature['color'] as Color).withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    feature['icon'] as IconData,
                    size: 18,
                    color: feature['color'] as Color,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    feature['text'] as String,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
  Widget _buildEnhancedCTAButtons(
      AnimationController controller,
      BuildContext context,
      bool isDarkMode,
      ) {
    final slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
    ));

    return SlideTransition(
      position: slideAnimation,
      child: FadeTransition(
        opacity: controller,
        child: Row(
          children: [
            Expanded(
              child: _EnhancedButton(
                onPressed: () => context.go('/register'),
                isPrimary: true,
                icon: Icons.person_add_rounded,
                label: 'Join as Candidate',
                isDarkMode: isDarkMode,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _EnhancedButton(
                onPressed: () => context.go('/register'),
                isPrimary: false,
                icon: Icons.business_center_rounded,
                label: 'I\'m a Recruiter',
                isDarkMode: isDarkMode,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularWorkflow() {
    return buildModernRecruitmentTimeline(
      _particleAnimationController,
      _activeStage,
      isDarkMode,
      _stages,
    );
  }






  Widget buildModernRecruitmentTimeline(
      AnimationController animationController,
      int activeStage,
      bool isDarkMode,
      List stages,
      ) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        return SizedBox(
          height: 1030,
          child: Column(
            children: [
              // Header with animated progress (isolated in its own layer)
              RepaintBoundary(
                child: _buildTimelineHeader(
                  activeStage,
                  stages.length,
                  isDarkMode,
                  animationController.value,
                ),
              ),
              const SizedBox(height: 30),

              // Scrollable timeline isolated in its own layer so list repaints don't affect header
              Expanded(
                child: RepaintBoundary(
                  child: ListView.builder(
                    itemCount: stages.length,
                    itemBuilder: (context, index) {
                      // Wrap each built item in a RepaintBoundary inside the list as well
                      return RepaintBoundary(
                        child: _buildTimelineCard(
                          stages[index],
                          index,
                          activeStage,
                          isDarkMode,
                          animationController.value,
                          stages,
                          isLast: index == stages.length - 1,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  Widget _buildTimelineHeader(int activeStage, int totalStages, bool isDarkMode, double animationValue) {
    final progress = (activeStage + 1) / totalStages;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.timeline_rounded, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Complete Hiring Ecosystem',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Step ${activeStage + 1} of $totalStages',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Animated progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeInOut,
                height: 8,
                width: 520 * progress,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF6366F1),
                      Color(0xFF8B5CF6),
                      Color(0xFFEC4899),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              // Flowing shimmer effect
              Positioned(
                left: (520 * progress) - 100,
                child: Container(
                  height: 8,
                  width: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0),
                        Colors.white.withOpacity(0.3 + (math.sin(animationValue * 2 * math.pi) * 0.2)),
                        Colors.white.withOpacity(0),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineCard(
      dynamic stage,
      int index,
      int activeStage,
      bool isDarkMode,
      double animationValue,
      List stages, {
        bool isLast = false,
      }) {
    final isActive = index == activeStage;
    final isCompleted = index < activeStage;
    final isPending = index > activeStage;

    // Put the whole animated card into its own repaint boundary so it composes to a separate layer
    return RepaintBoundary(
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, animValue, child) {
          return Transform.translate(
            offset: Offset(0, (1 - animValue) * 20),
            child: Opacity(
              opacity: animValue,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Timeline connector column
                    Column(
                      children: [
                        // Stage indicator (isolated below inside its own repaint boundary)
                        _buildStageIndicator(
                          stage,
                          index,
                          isActive,
                          isCompleted,
                          isDarkMode,
                          animationValue,
                        ),

                        // Connecting line (connector is isolated inside its own repaint boundary)
                        if (!isLast)
                          _buildConnectorLine(
                            isCompleted || isActive,
                            isDarkMode,
                            animationValue,
                            stage.color,
                            index + 1 < stages.length ? stages[index + 1].color : stage.color,
                          ),
                      ],
                    ),

                    const SizedBox(width: 20),

                    // Card content
                    Expanded(
                      child: _buildStageCard(
                        stage,
                        index,
                        isActive,
                        isCompleted,
                        isPending,
                        isDarkMode,
                        animationValue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }


  Widget _buildStageIndicator(
      dynamic stage,
      int index,
      bool isActive,
      bool isCompleted,
      bool isDarkMode,
      double animationValue,
      ) {
    final pulseScale = isActive ? 1.0 + (math.sin(animationValue * 2 * math.pi) * 0.1) : 1.0;

    return RepaintBoundary(
      child: Transform.scale(
        scale: pulseScale,
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: (isActive || isCompleted)
                ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [stage.color, stage.color.withOpacity(0.7)],
            )
                : null,
            color: (isActive || isCompleted) ? null : (isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
            border: Border.all(
              color: isActive ? Colors.white : (isCompleted ? stage.color.withOpacity(0.5) : Colors.transparent),
              width: isActive ? 3 : 2,
            ),
            boxShadow: (isActive || isCompleted)
                ? [
              BoxShadow(
                color: stage.color.withOpacity(0.4),
                blurRadius: isActive ? 20 : 12,
                spreadRadius: isActive ? 4 : 2,
              ),
            ]
                : null,
          ),
          child: Icon(
            isCompleted ? Icons.verified_rounded : stage.icon,
            color: (isActive || isCompleted) ? Colors.white : (isDarkMode ? const Color(0xFF475569) : const Color(0xFF94A3B8)),
            size: 30,
          ),
        ),
      ),
    );
  }


  Widget _buildConnectorLine(
      bool isActive,
      bool isDarkMode,
      double animationValue,
      Color currentStageColor,
      Color nextStageColor,
      ) {
    return RepaintBoundary(
      child: Container(
        width: 4,
        height: 130,
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          gradient: isActive
              ? LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              currentStageColor,
              nextStageColor.withOpacity(0.6),
            ],
          )
              : null,
          color: isActive ? null : (isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: isActive
            ? Stack(
          children: [
            Positioned(
              top: (60 * animationValue) % 60,
              left: 0,
              right: 0,
              child: Container(
                height: 20,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0),
                      Colors.white.withOpacity(0.6),
                      Colors.white.withOpacity(0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        )
            : null,
      ),
    );
  }


  Widget _buildStageCard(
      dynamic stage,
      int index,
      bool isActive,
      bool isCompleted,
      bool isPending,
      bool isDarkMode,
      double animationValue,
      ) {
    return RepaintBoundary(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: isActive ? (isDarkMode ? const Color(0xFF1E293B) : Colors.white) : (isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC)),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isActive ? stage.color : (isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              width: isActive ? 2 : 1,
            ),
            boxShadow: [
              if (isActive)
                BoxShadow(
                  color: stage.color.withOpacity(0.2),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              BoxShadow(
                color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Step badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: (isActive || isCompleted) ? stage.color.withOpacity(0.15) : (isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: (isActive || isCompleted) ? stage.color.withOpacity(0.3) : Colors.transparent,
                      ),
                    ),
                    child: Text(
                      stage.step,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: (isActive || isCompleted) ? stage.color : (isDarkMode ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  Text(
                    stage.title,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: (isActive || isCompleted)
                          ? (isDarkMode ? Colors.white : const Color(0xFF0F172A))
                          : (isDarkMode ? const Color(0xFF64748B) : const Color(0xFF64748B)),
                    ),
                  ),

                  const Spacer(),

                  // Status indicator
                  if (isCompleted)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.verified, color: Color(0xFF10B981), size: 14),
                          const SizedBox(width: 4),
                          Text(
                            'Completed',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: stage.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: stage.color,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'In Progress',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: stage.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              // Process Steps from details list
              if (stage.details != null && stage.details.isNotEmpty) ...[
                const SizedBox(height: 13),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: (isActive || isCompleted) ? stage.color.withOpacity(isDarkMode ? 0.1 : 0.05) : (isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9)),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: (isActive || isCompleted) ? stage.color.withOpacity(0.2) : (isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.checklist_rounded,
                            size: 16,
                            color: (isActive || isCompleted) ? stage.color : (isDarkMode ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Process Steps',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: (isActive || isCompleted) ? stage.color : (isDarkMode ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Dynamic process steps with arrows
                      Wrap(
                        spacing: 6,
                        runSpacing: 8,
                        children: [
                          for (int i = 0; i < stage.details.length; i++) ...[
                            _buildProcessStep(
                              stage.details[i],
                              stage.color,
                              isActive,
                              isCompleted,
                              isDarkMode,
                            ),
                            if (i < stage.details.length - 1)
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 14,
                                color: (isActive || isCompleted)
                                    ? stage.color.withOpacity(0.6)
                                    : (isDarkMode ? const Color(0xFF475569) : const Color(0xFF94A3B8)),
                              ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
            )
        );
    }






// Helper widget for individual process steps
  Widget _buildProcessStep(
      String text,
      Color color,
      bool isActive,
      bool isCompleted,
      bool isDarkMode,
      ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: (isActive || isCompleted)
            ? color.withOpacity(0.1)
            : (isDarkMode ? const Color(0xFF1E293B) : Colors.white),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: (isActive || isCompleted)
              ? color.withOpacity(0.3)
              : (isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: (isActive || isCompleted)
              ? (isDarkMode ? Colors.white : const Color(0xFF1F2937))
              : (isDarkMode ? const Color(0xFF64748B) : const Color(0xFF6B7280)),
        ),
      ),
    );
  }
















  /*

  // ==================== CIRCULAR WORKFLOW ====================
  Widget buildCreativeCircularWorkflow(AnimationController animationController, int activeStage, bool isDarkMode, List stages) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        return SizedBox(
          width: 600,
          height: 600,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Animated orbital ring
              SizedBox(
                width: 480,
                height: 480,
                child: CustomPaint(
                  painter: CreativeWorkflowPainter(
                    activeStage: activeStage,
                    isDarkMode: isDarkMode,
                    stages: stages.length,
                    animationValue: animationController.value,
                    showAllLines: true,
                  ),
                ),
              ),
              // Central hub with animation
              _buildAnimatedCentralHub(animationController.value, isDarkMode),
              // Stage cards with enhanced styling
              ..._buildEnhancedStageCards(stages, activeStage, isDarkMode),
            ],
          ),
        );
      },
    );
  }
  Widget _buildAnimatedCentralHub(double animationValue, bool isDarkMode) {
    final pulse = 1.0 + (math.sin(animationValue * 2 * math.pi) * 0.05);

    return Transform.scale(
      scale: pulse,
      child: Container(
        width: 160,
        height: 160,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF6366F1),
              const Color(0xFF8B5CF6),
              const Color(0xFFEC4899),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withOpacity(0.4),
              blurRadius: 40,
              spreadRadius: 10,
            ),
            BoxShadow(
              color: const Color(0xFFEC4899).withOpacity(0.3),
              blurRadius: 60,
              spreadRadius: -5,
            ),
          ],
        ),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.rocket_launch_rounded,
                color: Colors.white,
                size: 42,
              ),
              const SizedBox(height: 12),
              Text(
                'Recruitment',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                'Journey',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  List<Widget> _buildEnhancedStageCards(List stages, int activeStage, bool isDarkMode) {
    final indices = List<int>.generate(stages.length, (i) => i);
    indices.sort((a, b) {
      final aActive = a <= activeStage;
      final bActive = b <= activeStage;
      if (aActive == bActive) return a.compareTo(b);
      return aActive ? 1 : -1;
    });

    return indices.map((index) {
      final angle = (index * 2 * math.pi / stages.length) - (math.pi / 2);
      final radius = 240.0;
      final x = radius * math.cos(angle);
      final y = radius * math.sin(angle);

      return Transform.translate(
        offset: Offset(x, y),
        child: _buildModernStageCard(stages[index], index, activeStage, isDarkMode),
      );
    }).toList();
  }
  Widget _buildModernStageCard(dynamic stage, int index, int activeStage, bool isDarkMode) {
    final isCurrentActive = activeStage == index;
    final isProgressiveActive = index <= activeStage;
    final isCompleted = index < activeStage;

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutBack,
      tween: Tween(begin: 0.0, end: isCurrentActive ? 1.0 : 0.0),
      builder: (context, value, child) {
        final scale = 1.0 + (value * 0.08);
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 200,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isProgressiveActive
                  ? (isDarkMode ? const Color(0xFF1E293B) : Colors.white)
                  : (isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC)),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isCurrentActive
                    ? stage.color
                    : isProgressiveActive
                    ? stage.color.withOpacity(0.5)
                    : (isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                width: isCurrentActive ? 2.5 : 1.5,
              ),
              boxShadow: [
                if (isCurrentActive)
                  BoxShadow(
                    color: stage.color.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 8),
                  ),
                BoxShadow(
                  color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon with completion check
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: isProgressiveActive
                            ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [stage.color, stage.color.withOpacity(0.7)],
                        )
                            : null,
                        color: isProgressiveActive ? null : stage.color.withOpacity(0.15),
                        boxShadow: isProgressiveActive
                            ? [
                          BoxShadow(
                            color: stage.color.withOpacity(0.4),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ]
                            : null,
                      ),
                      child: Icon(
                        isCompleted ? Icons.check_circle_rounded : stage.icon,
                        size: 32,
                        color: isProgressiveActive ? Colors.white : stage.color.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Step badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isProgressiveActive
                        ? stage.color.withOpacity(0.15)
                        : (isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isProgressiveActive ? stage.color.withOpacity(0.3) : Colors.transparent,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    stage.step,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isProgressiveActive ? stage.color : (isDarkMode ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Title
                Text(
                  stage.title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isProgressiveActive
                        ? (isDarkMode ? Colors.white : const Color(0xFF0F172A))
                        : (isDarkMode ? const Color(0xFF64748B) : const Color(0xFF64748B)),
                  ),
                ),
                const SizedBox(height: 6),
                // Subtitle
                Text(
                  stage.subtitle,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: isProgressiveActive
                        ? (isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B))
                        : (isDarkMode ? const Color(0xFF475569) : const Color(0xFF94A3B8)),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

*/








  // ==================== Linear ANiamtions SECTION ====================
/*
  Widget _buildWorkflowVisualization() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 100),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDarkMode
              ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
              : [const Color(0xFFFAFAFA), const Color(0xFFFFFFFF)],
        ),
      ),
      child: Column(
        children: [
          _buildSectionHeader(
            'Workflow Process',
            '4-Stage Hiring Journey',
            'From profile creation to final placement - automated and intelligent',
            Icons.account_tree_rounded,
          ),
          const SizedBox(height: 80),
          _buildLinearWorkflow(),
        ],
      ),
    );
  }
  Widget _buildLinearWorkflow() {
    return SizedBox(
      height: 500,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: WorkflowLinePainter(
                activeStage: _activeStage,
                isDarkMode: isDarkMode,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(
              _stages.length,
                  (index) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: _buildLinearStageCard(_stages[index], index),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildLinearStageCard(WorkflowStage stage, int index) {
    final isActive = _activeStage == index;
    final isPassed = _activeStage > index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            width: isActive ? 80 : 64,
            height: isActive ? 80 : 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isActive || isPassed
                  ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [stage.color, stage.color.withOpacity(0.7)],
              )
                  : null,
              color: isActive || isPassed
                  ? null
                  : isDarkMode
                  ? const Color(0xFF334155)
                  : const Color(0xFFE5E7EB),
              border: Border.all(
                color: isActive
                    ? stage.color
                    : isPassed
                    ? stage.color.withOpacity(0.5)
                    : isDarkMode
                    ? const Color(0xFF475569)
                    : const Color(0xFFD1D5DB),
                width: isActive ? 3 : 2,
              ),
              boxShadow: isActive
                  ? [
                BoxShadow(
                  color: stage.color.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ]
                  : [],
            ),
            child: Center(
              child: Icon(
                isPassed ? Icons.check_rounded : stage.icon,
                color: isActive || isPassed
                    ? Colors.white
                    : isDarkMode
                    ? const Color(0xFF64748B)
                    : const Color(0xFF9CA3AF),
                size: isActive ? 36 : 28,
              ),
            ),
          ),
          const SizedBox(height: 24),
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: isActive
                  ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDarkMode
                    ? [stage.color.withOpacity(0.2), stage.color.withOpacity(0.1)]
                    : [stage.color.withOpacity(0.15), stage.color.withOpacity(0.05)],
              )
                  : null,
              color: isActive
                  ? null
                  : isDarkMode
                  ? const Color(0xFF1E293B).withOpacity(0.5)
                  : Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isActive
                    ? stage.color
                    : isDarkMode
                    ? const Color(0xFF334155)
                    : const Color(0xFFE5E7EB),
                width: isActive ? 2 : 1,
              ),
              boxShadow: isActive
                  ? [
                BoxShadow(
                  color: stage.color.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ]
                  : [
                BoxShadow(
                  color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isActive
                        ? stage.color.withOpacity(0.2)
                        : isDarkMode
                        ? const Color(0xFF334155)
                        : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isActive
                          ? stage.color.withOpacity(0.5)
                          : isDarkMode
                          ? const Color(0xFF475569)
                          : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: Text(
                    stage.step,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isActive
                          ? stage.color
                          : isDarkMode
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF6B7280),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  stage.title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isActive
                        ? (isDarkMode ? Colors.white : const Color(0xFF1F2937))
                        : isDarkMode
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  stage.subtitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: isActive
                        ? (isDarkMode ? const Color(0xFFCBD5E1) : const Color(0xFF6B7280))
                        : isDarkMode
                        ? const Color(0xFF64748B)
                        : const Color(0xFF9CA3AF),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  */

  // ==================== FEATURES SECTION ====================
  Widget _buildFeaturesSection() {
    final features = [
      FeaturePortal(
        number: '01',
        title: 'Candidate Portal',
        subtitle: 'Your Career, Your Control',
        color: const Color(0xFF6366F1),
        icon: Icons.person_rounded,
        items: [
          FeatureItem(
              'Profile Builder', 'Create comprehensive professional profiles',
              Icons.account_circle_rounded),
          FeatureItem('CV Generator', 'AI-powered resume creation tools',
              Icons.description_rounded),
          FeatureItem(
              'Skill Showcase', 'Highlight expertise and certifications',
              Icons.workspace_premium_rounded),
          FeatureItem('Public Portfolio', 'Share your journey with recruiters',
              Icons.public_rounded),
        ],
      ),
      FeaturePortal(
        number: '02',
        title: 'Recruiter Portal',
        subtitle: 'Find Perfect Candidates Fast',
        color: const Color(0xFF10B981),
        icon: Icons.business_rounded,
        items: [
          FeatureItem('Candidate Search', 'Browse qualified talent pool',
              Icons.search_rounded),
          FeatureItem('Bulk Selection', 'Select multiple candidates at once',
              Icons.checklist_rounded),
          FeatureItem('Request Management', 'Submit hiring requests to admin',
              Icons.send_rounded),
          FeatureItem(
              'Request Tracker', 'Realtime Recruitment Request Tracking',
              Icons.auto_graph),
        ],
      ),
      FeaturePortal(
        number: '03',
        title: 'Admin Portal',
        subtitle: 'End-to-End Hiring Management',
        color: const Color(0xFFF59E0B),
        icon: Icons.admin_panel_settings_rounded,
        items: [
          FeatureItem('Request Review', 'Evaluate recruiter requests',
              Icons.rate_review_rounded),
          FeatureItem('Interview Scheduling', 'Organize and conduct interviews',
              Icons.event_rounded),
          FeatureItem('Candidate Training', 'Skill development and preparation',
              Icons.school_rounded),
          FeatureItem('Final Selection', 'Complete hiring and onboarding',
              Icons.how_to_reg_rounded),
        ],
      ),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 90),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [const Color(0x00f9fafb), const Color(0x00f9fafb)]
              : [
            const Color(0x00f9fafb),
            const Color(0x00f9fafb),
            const Color(0x00f9fafb)
          ],
        ),
      ),
      child: Column(
        children: [
          _buildSectionHeader(
            '🚀 COMPLETE ECOSYSTEM',
            'Complete Hiring Ecosystem',
            'Three powerful portals, one seamless journey',
            Icons.apps_rounded,
          ),

          const SizedBox(height: 40),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < features.length; i++) ...[
                Expanded(child: _buildFeatureCard(features[i])),
                if (i < features.length - 1)
                  Padding(
                    padding: const EdgeInsets.only(top: 100),
                    child: Icon(
                      Icons.arrow_forward,
                      color: isDarkMode ? const Color(0xFF475569) : const Color(
                          0xFFD1D5DB),
                      size: 40,
                    ),
                  ),
              ],
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildMetricCard(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              foreground: Paint()
                ..shader = LinearGradient(
                  colors: [color, color.withOpacity(0.6)],
                ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: isDarkMode ? const Color(0xFF94A3B8) : const Color(
                  0xFF6B7280),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildFeatureCard(FeaturePortal portal) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: portal.color.withOpacity(0.2), width: 2),
        boxShadow: [
          BoxShadow(
            color: portal.color.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [portal.color, portal.color.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  portal.number,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      portal.color.withOpacity(0.1),
                      portal.color.withOpacity(0.05)
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(portal.icon, color: portal.color, size: 32),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            portal.title,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            portal.subtitle,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: isDarkMode ? const Color(0xFF94A3B8) : const Color(
                  0xFF6B7280),
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),
          ...portal.items
              .asMap()
              .entries
              .map((entry) {
            final i = entry.key;
            final item = entry.value;
            return Padding(
              padding: EdgeInsets.only(
                  bottom: i < portal.items.length - 1 ? 16 : 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: portal.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: portal.color.withOpacity(0.2)),
                    ),
                    child: Icon(item.icon, color: portal.color, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isDarkMode ? Colors.white : const Color(
                                0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.description,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: isDarkMode
                                ? const Color(0xFF64748B)
                                : const Color(0xFF9CA3AF),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
  // ==================== STATS SHOWCASE ====================
  Widget _buildStatsShowcase() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 80),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [
            const Color(0x00f9fafb),
            const Color(0x00f9fafb),
            const Color(0x00f9fafb)
          ]
              : [
            const Color(0x00f9fafb),
            const Color(0x00f9fafb),
            const Color(0x00f9fafb)
          ],
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Text(
              '⚡ PROVEN SUCCESS',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Trusted by Industry Leaders',
            style: GoogleFonts.poppins(
              fontSize: 42,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Real numbers, real impact - see how we transform hiring',
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: Colors.white.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 70),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSuccessMetric(
                  '15K+', 'Successfully Hired', Icons.people_rounded),
              const SizedBox(width: 50),
              _buildSuccessMetric(
                  '98%', 'Success Rate', Icons.trending_up_rounded),
              const SizedBox(width: 50),
              _buildSuccessMetric(
                  '24h', 'Avg. Response', Icons.schedule_rounded),
              const SizedBox(width: 50),
              _buildSuccessMetric(
                  '500+', 'Active Recruiters', Icons.business_rounded),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildSuccessMetric(String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.6), size: 24),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  // ==================== FOOTER ====================
  Widget _buildFooter() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDarkMode
              ? [const Color(0xFF111827), const Color(0xFF000000)]
              : [const Color(0xFF1F2937), const Color(0xFF111827)],
        ),
      ),
      child: Column(
        children: [
          _buildStatsShowcase(),
          SizedBox(height: 10,),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 50),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: _buildFooterBrand()),
                    const SizedBox(width: 80),
                    Expanded(child: _buildFooterColumn('For Candidates', [
                      'Create Profile',
                      'Build CV',
                      'Browse Jobs',
                      'Career Resources',
                    ])),
                    const SizedBox(width: 60),
                    Expanded(child: _buildFooterColumn('For Recruiters', [
                      'Find Talent',
                      'Submit Requests',
                      'Pricing Plans',
                      'Success Stories',
                    ])),
                    const SizedBox(width: 60),
                    Expanded(child: _buildFooterColumn('Company', [
                      'About Us', 'Contact', 'Careers', 'Privacy Policy',
                    ])),
                  ],
                ),
                const SizedBox(height: 60),
                _buildNewsletterSection(),
              ],
            ),
          ),
          _buildFooterBottom(),
        ],
      ),
    );
  }
  Widget _buildFooterBrand() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MAHA SERVICES',
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Revolutionizing recruitment through an intelligent 4-stage hiring ecosystem. Connecting talent with opportunity seamlessly.',
          style: GoogleFonts.poppins(
            color: const Color(0xFF9CA3AF),
            fontSize: 14,
            height: 1.8,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            _buildSocialIcon(Icons.facebook, const Color(0xFF1877F2)),
            const SizedBox(width: 12),
            _buildSocialIcon(Icons.link, const Color(0xFF0A66C2)),
            const SizedBox(width: 12),
            _buildSocialIcon(Icons.mail_rounded, const Color(0xFFEA4335)),
          ],
        ),
      ],
    );
  }
  Widget _buildSocialIcon(IconData icon, Color color) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
  Widget _buildFooterColumn(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        ...items.map((item) =>
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Row(
                  children: [
                    const Icon(Icons.arrow_forward_ios_rounded,
                        color: Color(0xFF6366F1), size: 12),
                    const SizedBox(width: 8),
                    Text(
                      item,
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF9CA3AF),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }
  Widget _buildNewsletterSection() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6366F1).withOpacity(0.1),
            const Color(0xFF8B5CF6).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(
              Icons.mail_outline_rounded, color: Color(0xFF6366F1), size: 32),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stay Updated',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Get the latest hiring insights and platform updates',
                  style: GoogleFonts.poppins(
                      fontSize: 13, color: const Color(0xFF9CA3AF)),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Subscribe',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildFooterBottom() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 30),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFF374151), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '© 2025 Maha Services. All rights reserved.',
            style: GoogleFonts.poppins(
                color: const Color(0xFF6B7280), fontSize: 13),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: const Color(0xFF6366F1).withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.psychology_rounded, color: Color(0xFF6366F1),
                    size: 16),
                const SizedBox(width: 6),
                Text(
                  'Powered by AI',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF6366F1),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildSectionHeader(String badge, String title, String subtitle,
      IconData icon) {
    return FadeTransition(
      opacity: _workflowAnimation,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF6366F1).withOpacity(0.2),
                  const Color(0xFF8B5CF6).withOpacity(0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                color: const Color(0xFF6366F1).withOpacity(0.5),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: const Color(0xFF7233FB), size: 18),
                const SizedBox(width: 10),
                Text(
                  badge,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF7233FB),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 48,
              fontWeight: FontWeight.w900,
              color: isDarkMode ? Colors.white : const Color(0xFF081D69),
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: isDarkMode ? const Color(0xFF94A3B8) : const Color(
                  0xFF6B7280),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
class _AnimatedButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;

  const _AnimatedButton({
    required this.onPressed,
    required this.child,
  });

  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedScale(
          scale: _isHovered ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: widget.child,
        ),
      ),
    );
  }
}

class WorkflowLinePainter extends CustomPainter {
  final int activeStage;
  final bool isDarkMode;

  WorkflowLinePainter({
    required this.activeStage,
    required this.isDarkMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final cardWidth = size.width / 5;
    final centerY = 40.0;

    for (int i = 0; i < 4; i++) {
      final startX = (cardWidth * i) + (cardWidth / 2) + 32;
      final endX = (cardWidth * (i + 1)) + (cardWidth / 2) - 32;
      final isActive = activeStage > i;

      paint.color = isActive
          ? _getStageColor(i)
          : isDarkMode
          ? const Color(0xFF334155)
          : const Color(0xFFE5E7EB);

      // Draw connecting line
      canvas.drawLine(
        Offset(startX, centerY),
        Offset(endX, centerY),
        paint,
      );

      // Draw arrow if stage is active
      if (isActive) {
        final arrowPaint = Paint()
          ..color = _getStageColor(i)
          ..style = PaintingStyle.fill;

        final arrowPath = Path()
          ..moveTo(endX, centerY)
          ..lineTo(endX - 10, centerY - 6)
          ..lineTo(endX - 10, centerY + 6)
          ..close();

        canvas.drawPath(arrowPath, arrowPaint);
      }
    }
  }

  Color _getStageColor(int index) {
    final colors = [
      const Color(0xFF6366F1), // Blue
      const Color(0xFF10B981), // Green
      const Color(0xFFF59E0B), // Orange
      const Color(0xFFEC4899), // Pink
    ];
    return colors[index];
  }

  @override
  bool shouldRepaint(covariant WorkflowLinePainter oldDelegate) {
    return oldDelegate.activeStage != activeStage ||
        oldDelegate.isDarkMode != isDarkMode;
  }
}
// ==================== DATA MODELS ====================
class WorkflowStage {
  final String step;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final List<String> details;

  WorkflowStage({
    required this.step,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.details,
  });
}
class FeaturePortal {
  final String number;
  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;
  final List<FeatureItem> items;

  FeaturePortal({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
    required this.items,
  });
}
class FeatureItem {
  final String title;
  final String description;
  final IconData icon;

  FeatureItem(this.title, this.description, this.icon);
}
// ==================== CUSTOM PAINTERS ====================
class _GridPainter extends CustomPainter {
  final double animationValue;

  _GridPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    const double gridSize = 100.0;
    final offset = animationValue * gridSize;

    // Base grid paint (dimmed, more prominent)
    final baseGridPaint = Paint()
      ..color = const Color(0xFF4A90E2).withOpacity(0.15)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;

    // Neon beam paint for grid lines
    final beamPaint = Paint()
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    // Draw vertical lines with moving beam effect
    int verticalIndex = 0;
    for (double x = -gridSize + (offset % gridSize);
    x < size.width + gridSize;
    x += gridSize) {

      // Draw base line
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        baseGridPaint,
      );

      // Create moving beam along the line
      final beamProgress = (animationValue * 2 + verticalIndex * 0.3) % 1.0;
      final beamStart = beamProgress * size.height;
      final beamLength = size.height * 0.4; // Beam covers 30% of line

      final verticalGradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          const Color(0xFFF7E6FF).withOpacity(0.4),
          const Color(0xFFF7E6FF).withOpacity(0.9),
          const Color(0xFFF7E6FF).withOpacity(0.4),
          Colors.transparent,
        ],
        stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
      );

      beamPaint.shader = verticalGradient.createShader(
        Rect.fromLTWH(x - 20, beamStart - beamLength/2, 40, beamLength),
      );

      canvas.drawLine(
        Offset(x, math.max(0, beamStart - beamLength/2)),
        Offset(x, math.min(size.height, beamStart + beamLength/2)),
        beamPaint,
      );

      verticalIndex++;
    }

    // Draw horizontal lines with moving beam effect
    int horizontalIndex = 0;
    for (double y = -gridSize + (offset % gridSize);
    y < size.height + gridSize;
    y += gridSize) {

      // Draw base line
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        baseGridPaint,
      );

      // Create moving beam along the line
      final beamProgress = (animationValue * 1.5 + horizontalIndex * 0.25) % 1.0;
      final beamStart = beamProgress * size.width;
      final beamLength = size.width * 0.6; // Beam covers 30% of line

      final horizontalGradient = LinearGradient(
        colors: [
          Colors.transparent,
          const Color(0xFFE6EFFF).withOpacity(0.4),
          const Color(0xFFE6EFFF).withOpacity(0.9),
          const Color(0xFFE6EFFF).withOpacity(0.4),
          Colors.transparent,
        ],
        stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
      );

      beamPaint.shader = horizontalGradient.createShader(
        Rect.fromLTWH(beamStart - beamLength/2, y - 20, beamLength, 40),
      );

      canvas.drawLine(
        Offset(math.max(0, beamStart - beamLength/2), y),
        Offset(math.min(size.width, beamStart + beamLength/2), y),
        beamPaint,
      );

      horizontalIndex++;
    }

    // Add extra glow at beam intersections
    final intersectionPaint = Paint()
      ..color = const Color(0xFFFFFFFF).withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    verticalIndex = 0;
    for (double x = -gridSize + (offset % gridSize);
    x < size.width + gridSize;
    x += gridSize) {
      horizontalIndex = 0;
      for (double y = -gridSize + (offset % gridSize);
      y < size.height + gridSize;
      y += gridSize) {

        final beamProgressV = (animationValue * 2 + verticalIndex * 0.3) % 1.0;
        final beamProgressH = (animationValue * 1.5 + horizontalIndex * 0.25) % 1.0;

        // Check if beams are near intersection
        final verticalBeamY = beamProgressV * size.height;
        final horizontalBeamX = beamProgressH * size.width;

        if ((verticalBeamY - y).abs() < 50 && (horizontalBeamX - x).abs() < 50) {
          canvas.drawCircle(
            Offset(x, y),
            8,
            intersectionPaint,
          );
        }

        horizontalIndex++;
      }
      verticalIndex++;
    }
  }

  @override
  bool shouldRepaint(_GridPainter oldDelegate) => true;
}

// ==================== CIRCULAR WORKFLOW PAINTER ====================
class CreativeWorkflowPainter extends CustomPainter {
  final int activeStage;
  final bool isDarkMode;
  final int stages;
  final double animationValue; // 0.0 to 1.0 for continuous animation
  final bool showAllLines;

  CreativeWorkflowPainter({
    required this.activeStage,
    required this.isDarkMode,
    required this.stages,
    required this.animationValue,
    this.showAllLines = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) / 2) - 40;

    // Draw orbital rings with glow effect
    _drawOrbitalRings(canvas, center, radius);

    // Draw animated connection lines
    _drawConnectionLines(canvas, center, radius);

    // Draw flowing particles on active path
    _drawFlowingParticles(canvas, center, radius);

    // Draw stage nodes with pulse effect
    _drawStageNodes(canvas, center, radius);
  }

  void _drawOrbitalRings(Canvas canvas, Offset center, double radius) {
    // Outer glow ring
    final glowPaint = Paint()
      ..color = (isDarkMode ? const Color(0xFF6366F1) : const Color(0xFF8B5CF6))
          .withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(center, radius, glowPaint);

    // Main orbital ring with gradient
    final rect = Rect.fromCircle(center: center, radius: radius);
    final gradientPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          const Color(0xFF6366F1),
          const Color(0xFF8B5CF6),
          const Color(0xFF10B981),
          const Color(0xFFF59E0B),
          const Color(0xFFEC4899),
          const Color(0xFF6366F1),
        ],
        stops: const [0.0, 0.2, 0.4, 0.6, 0.8, 1.0],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, gradientPaint);

    // Inner decorative rings
    for (int i = 1; i <= 3; i++) {
      final innerPaint = Paint()
        ..color = (isDarkMode ? Colors.white : Colors.black)
            .withOpacity(0.03 * i)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      canvas.drawCircle(center, radius - (i * 15), innerPaint);
    }
  }

  void _drawConnectionLines(Canvas canvas, Offset center, double radius) {
    final segmentColors = <Color>[
      const Color(0xFF6A6BE1),
      const Color(0xFF8D68E1),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFFEC4899),
    ];

    final anglePerStage = 2 * math.pi / stages;

    for (int i = 0; i < stages; i++) {
      final startAngle = (i * anglePerStage) - (math.pi / 2);
      final endAngle = ((i + 1) * anglePerStage) - (math.pi / 2);

      final isActive = i <= activeStage;
      final baseColor = segmentColors[i % segmentColors.length];

      if (isActive || showAllLines) {
        // Draw arc segment with glow
        final path = Path();
        path.addArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          anglePerStage * 0.85,
        );

        // Glow effect
        if (isActive) {
          final glowPaint = Paint()
            ..color = baseColor.withOpacity(0.3)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 12
            ..strokeCap = StrokeCap.round
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
          canvas.drawPath(path, glowPaint);
        }

        // Main line
        final linePaint = Paint()
          ..color = isActive ? baseColor : baseColor.withOpacity(0.2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = isActive ? 6 : 3
          ..strokeCap = StrokeCap.round;
        canvas.drawPath(path, linePaint);

        // Animated dash effect for active stage
        if (i == activeStage) {
          final dashPaint = Paint()
            ..color = Colors.white.withOpacity(0.8)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..strokeCap = StrokeCap.round;

          // Create dashed effect
          final dashPath = _createDashedPath(path, animationValue);
          canvas.drawPath(dashPath, dashPaint);
        }
      }
    }
  }

  void _drawFlowingParticles(Canvas canvas, Offset center, double radius) {
    if (activeStage < 0) return;

    final particleColors = [
      Colors.white,
      const Color(0xFF6366F1),
      const Color(0xFF8B5CF6),
    ];

    final anglePerStage = 2 * math.pi / stages;

    // Draw particles flowing along active segments
    for (int i = 0; i <= activeStage && i < stages; i++) {
      final startAngle = (i * anglePerStage) - (math.pi / 2);
      final segmentProgress = i == activeStage ? animationValue : 1.0;

      // Multiple particles per segment
      for (int p = 0; p < 3; p++) {
        final particleOffset = (p / 3.0 + animationValue) % 1.0;
        final angle = startAngle + (anglePerStage * 0.85 * particleOffset * segmentProgress);

        final x = center.dx + radius * math.cos(angle);
        final y = center.dy + radius * math.sin(angle);

        final particlePaint = Paint()
          ..color = particleColors[p % particleColors.length]
              .withOpacity(0.6 - (particleOffset * 0.3))
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

        canvas.drawCircle(
          Offset(x, y),
          3 - (particleOffset * 1.5),
          particlePaint,
        );
      }
    }
  }

  void _drawStageNodes(Canvas canvas, Offset center, double radius) {
    final segmentColors = <Color>[
      const Color(0xFF6366F1),
      const Color(0xFF8B5CF6),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFFEC4899),
    ];

    final anglePerStage = 2 * math.pi / stages;

    for (int i = 0; i < stages; i++) {
      final angle = (i * anglePerStage) - (math.pi / 2);
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      final nodeCenter = Offset(x, y);

      final isActive = i <= activeStage;
      final isCurrent = i == activeStage;
      final baseColor = segmentColors[i % segmentColors.length];

      // Outer pulse ring for current stage
      if (isCurrent) {
        final pulseRadius = 25.0 + (math.sin(animationValue * 2 * math.pi) * 5).toDouble();
        final pulsePaint = Paint()
          ..color = baseColor.withOpacity(0.3 - (animationValue * 0.2))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
        canvas.drawCircle(nodeCenter, pulseRadius, pulsePaint);
      }

      // Outer glow
      if (isActive) {
        final glowPaint = Paint()
          ..color = baseColor.withOpacity(0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
        canvas.drawCircle(nodeCenter, 18, glowPaint);
      }

      // Node background
      final bgPaint = Paint()
        ..color = isActive ? baseColor : baseColor.withOpacity(0.2)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(nodeCenter, 16, bgPaint);

      // Node border
      final borderPaint = Paint()
        ..color = isActive ? Colors.white : baseColor.withOpacity(0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = isCurrent ? 3 : 2;
      canvas.drawCircle(nodeCenter, 16, borderPaint);

      // Inner dot with animation
      final innerSize = isCurrent ? 6.0 + (math.sin(animationValue * 2 * math.pi) * 2).toDouble() : 5.0;
      final innerPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(nodeCenter, innerSize, innerPaint);
    }
  }


  Path _createDashedPath(Path source, double phase) {
    final path = Path();
    final dashLength = 10.0;
    final gapLength = 8.0;
    final offset = phase * (dashLength + gapLength);

    final metrics = source.computeMetrics();
    for (final metric in metrics) {
      double distance = -offset;
      bool draw = true;
      while (distance < metric.length) {
        final length = draw ? dashLength : gapLength;
        if (distance + length > metric.length) {
          if (draw) {
            path.addPath(
              metric.extractPath(distance, metric.length),
              Offset.zero,
            );
          }
          break;
        }
        if (draw) {
          path.addPath(
            metric.extractPath(distance, distance + length),
            Offset.zero,
          );
        }
        distance += length;
        draw = !draw;
      }
    }
    return path;
  }

  @override
  bool shouldRepaint(covariant CreativeWorkflowPainter oldDelegate) =>
      oldDelegate.activeStage != activeStage ||
          oldDelegate.isDarkMode != isDarkMode ||
          oldDelegate.stages != stages ||
          oldDelegate.animationValue != animationValue ||
          oldDelegate.showAllLines != showAllLines;
}
class _EnhancedButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isPrimary;
  final IconData icon;
  final String label;
  final bool isDarkMode;

  const _EnhancedButton({
    required this.onPressed,
    required this.isPrimary,
    required this.icon,
    required this.label,
    required this.isDarkMode,
  });

  @override
  State<_EnhancedButton> createState() => _EnhancedButtonState();
}
class _EnhancedButtonState extends State<_EnhancedButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..scale(_isHovered ? 1.02 : 1.0),
        child: ElevatedButton(
          onPressed: widget.onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.isPrimary
                ? const Color(0xFF6366F1)
                : (widget.isDarkMode ? const Color(0xFF1E293B) : Colors.white),
            foregroundColor: widget.isPrimary
                ? Colors.white
                : const Color(0xFF10B981),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 25),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: widget.isPrimary
                  ? BorderSide.none
                  : BorderSide(
                color: const Color(0xFF10B981),
                width: 2,
              ),
            ),
            elevation: _isHovered ? 8 : 3,
            shadowColor: widget.isPrimary
                ? const Color(0xFF6366F1).withOpacity(0.4)
                : const Color(0xFF10B981).withOpacity(0.2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: 20),
              const SizedBox(width: 10),
              Text(
                widget.label,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
Widget _buildAnimatedStats(AnimationController controller, bool isDarkMode) {
  final slideAnimation = Tween<Offset>(
    begin: const Offset(0, 0.3),
    end: Offset.zero,
  ).animate(CurvedAnimation(
    parent: controller,
    curve: const Interval(0.5, 0.9, curve: Curves.easeOut),
  ));

  return SlideTransition(
    position: slideAnimation,
    child: FadeTransition(
      opacity: controller,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDarkMode
                ? [
              const Color(0xFF1E293B).withOpacity(0.5),
              const Color(0xFF0F172A).withOpacity(0.3),
            ]
                : [
              const Color(0xFFF8FAFC),
              const Color(0xFFEEF2FF),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDarkMode
                ? const Color(0xFF334155).withOpacity(0.5)
                : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildAnimatedStatItem(
              '12K+',
              'Active Users',
              Icons.people_alt_rounded,
              const Color(0xFF6366F1),
              isDarkMode,
              controller,
            ),
            _buildStatDivider(isDarkMode),
            _buildAnimatedStatItem(
              '850+',
              'Companies',
              Icons.business_rounded,
              const Color(0xFF10B981),
              isDarkMode,
              controller,
            ),
            _buildStatDivider(isDarkMode),
            _buildAnimatedStatItem(
              '98%',
              'Success Rate',
              Icons.verified_rounded,
              const Color(0xFFF59E0B),
              isDarkMode,
              controller,
            ),
          ],
        ),
      ),
    ),
  );
}
Widget _buildStatDivider(bool isDarkMode) {
  return Container(
    width: 1,
    height: 40,
    color: isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
  );
}
Widget _buildAnimatedStatItem(
    String number,
    String label,
    IconData icon,
    Color color,
    bool isDarkMode,
    AnimationController controller,
    ) {
  return TweenAnimationBuilder<double>(
    duration: const Duration(milliseconds: 1500),
    tween: Tween(begin: 0.0, end: 1.0),
    curve: Curves.easeOut,
    builder: (context, value, child) {
      return Opacity(
        opacity: value,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.7)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              number,
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF6B7280),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    },
  );
}
Widget _buildTrustIndicators(AnimationController controller, bool isDarkMode) {
  final fadeAnimation = Tween<double>(
    begin: 0.0,
    end: 1.0,
  ).animate(CurvedAnimation(
    parent: controller,
    curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
  ));

  return FadeTransition(
    opacity: fadeAnimation,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildTrustBadge(Icons.security_rounded, 'Secure', isDarkMode),
            const SizedBox(width: 12),
            _buildTrustBadge(Icons.verified_user_rounded, 'Verified', isDarkMode),
            const SizedBox(width: 12),
            _buildTrustBadge(Icons.support_agent_rounded, '24/7 Support', isDarkMode),
          ],
        ),
      ],
    ),
  );
}
Widget _buildTrustBadge(IconData icon, String label, bool isDarkMode) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF6B7280),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF6B7280),
          ),
        ),
      ],
    ),
  );
}