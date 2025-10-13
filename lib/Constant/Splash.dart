import 'dart:math' as math;
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:job_portal/Constant/Tagline_anim.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  bool _hoverJobSeeker = false;
  bool _hoverRecruiter = false;
  bool _checkingUser = true;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _floatingController;
  late AnimationController _morphController;
  late AnimationController _breatheController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _floatingAnimation;
  late Animation<double> _morphAnimation;
  late Animation<double> _breatheAnimation;

  final ScrollController _scrollController = ScrollController();

  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color snowWhite = Color(0xFFFAFAFA);
  static const Color paleGray = Color(0xFFF5F5F7);
  static const Color lightGray = Color(0xFFE5E5EA);
  static const Color subtleGray = Color(0xFFD1D1D6);
  static Color charcoalGray = Colors.black87;
  static const Color softShadow = Color(0x08000000);
  static const Color mediumShadow = Color(0x12000000);
  late AnimationController _subtleController;
  late Animation<double> _subtleAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _checkLoggedInUser();
    _subtleController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )
      ..repeat();

    _subtleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _subtleController, curve: Curves.easeInOut),
    );
  }
  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200), // slower fade
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1100), // smoother slide
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(seconds: 30), // slower background rotation
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 5), // even slower breathing
      vsync: this,
    )..repeat(reverse: true);

    _floatingController = AnimationController(
      duration: const Duration(seconds: 20), // smoother floating
      vsync: this,
    )..repeat(reverse: true);

    _morphController = AnimationController(
      duration: const Duration(seconds: 20), // smoother background bar animation
      vsync: this,
    )..repeat();

    _breatheController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat(reverse: true);

    // fade → slide → scale with smoother easing
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutQuad),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.04), // smaller offset = less jerk
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutQuad),
    );

    _scaleAnimation = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInCirc),
    );

    _rotationAnimation =
        Tween<double>(begin: 0, end: 2 * math.pi).animate(_rotationController);

    _pulseAnimation = Tween<double>(begin: 0.99, end: 1.01).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );

    _floatingAnimation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInCubic),
    );

    _morphAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _morphController, curve: Curves.easeInBack),
    );

    _breatheAnimation = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _breatheController, curve: Curves.easeOutSine),
    );
  }

  void _startAnimations() {
    // Start fade immediately
    _fadeController.forward();

    // Slide in after fade begins (slightly longer gap)
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _slideController.forward();
    });

    // Scale in last, so motion feels layered instead of all at once
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) _scaleController.forward();
    });
  }

  Future<void> _checkLoggedInUser() async {
    final user = FirebaseAuth.instance.currentUser;
    final firestore = FirebaseFirestore.instance;

    await Future.delayed(const Duration(seconds: 2));

    if (user != null) {
      final uid = user.uid;
      try {
        final jobSeeker =
        await firestore.collection('Job_Seeker').doc(uid).get();
        if (jobSeeker.exists) {
          if (mounted) context.go('/dashboard');
          return;
        }

        final recruiter =
        await firestore.collection('Recruiter').doc(uid).get();
        if (recruiter.exists) {
          if (mounted) context.go('/recruiter-dashboard');
          return;
        }

        await FirebaseAuth.instance.signOut();
      } catch (e) {
        debugPrint('Error checking user role: $e');
        await FirebaseAuth.instance.signOut();
      }
    }

    if (mounted) {
      setState(() => _checkingUser = false);
      _startAnimations();
    }
  }


  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _rotationController.dispose();
    _pulseController.dispose();
    _floatingController.dispose();
    _morphController.dispose();
    _breatheController.dispose();
    _scrollController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    if (_checkingUser) {
      return _buildLoadingScreen();
    }

    return Scaffold(
      backgroundColor: pureWhite,
      body: Stack(
        children: [
          // Subtle animated background pattern
          Positioned.fill(
            child: CustomPaint(
              painter: _GeometricPatternPainter(),
            ),
          ),
          FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: [
                    _buildMinimalHeader(),
                    _buildExcitingHeroSection(),
                    _buildProfessionalFeaturesSection(),
                    _buildTestimonialsSection(),
                    _buildProfessionalFooter(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: pureWhite,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 0.8,
            colors: [
              Colors.indigo.shade50,
              pureWhite,
              Colors.grey.shade50,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  // Outer ring animation
                  AnimatedBuilder(
                    animation: _breatheController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 1 + (_breatheAnimation.value * 0.3),
                        child: Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.indigo.shade900.withOpacity(0.1),
                              width: 2,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  // Main loading circle
                  AnimatedBuilder(
                    animation: _breatheController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _breatheAnimation.value,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.indigo.shade900,
                                Colors.indigo.shade700,
                                Colors.indigo.shade800,
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.indigo.withOpacity(0.3),
                                blurRadius: 40,
                                spreadRadius: 0,
                                offset: const Offset(0, 20),
                              ),
                              BoxShadow(
                                color: mediumShadow,
                                blurRadius: 80,
                                spreadRadius: 0,
                                offset: const Offset(0, 40),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.auto_awesome_outlined,
                            color: Colors.white,
                            size: 50,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 60),
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [
                    Colors.indigo.shade900,
                    Colors.indigo.shade600,
                    Colors.indigo.shade800,
                  ],
                ).createShader(bounds),
                child: Text(
                  'Maha Services',
                  style: GoogleFonts.poppins(
                    fontSize: 42,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                    letterSpacing: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Elite Professional Solutions',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                  color: charcoalGray.withOpacity(0.7),
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 40),
              Container(
                width: 240,
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  gradient: LinearGradient(
                    colors: [
                      Colors.indigo.shade900.withOpacity(0.2),
                      Colors.indigo.shade900,
                      Colors.indigo.shade900.withOpacity(0.2),
                    ],
                  ),
                ),
                child: AnimatedBuilder(
                  animation: _morphController,
                  builder: (context, child) {
                    return FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: (_morphAnimation.value * 2) % 1,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.8),
                              Colors.white,
                              Colors.white.withOpacity(0.8),
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
      ),
    );
  }

  Widget _buildMinimalHeader() {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: pureWhite.withOpacity(0.95),
        border: Border(
          bottom: BorderSide(
            color: Colors.indigo.shade900.withOpacity(0.1),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 20,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildCleanLogo(),
            _buildMinimalNav(),
            _buildHeaderActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildCleanLogo() {
    return Row(
      children: [
        AnimatedBuilder(
          animation: _rotationController,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotationAnimation.value * 0.05,
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.indigo.shade900,
                      Colors.indigo.shade700,
                      Colors.indigo.shade800,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.indigo.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome_outlined,
                  color: pureWhite,
                  size: 28,
                ),
              ),
            );
          },
        ),
        const SizedBox(width: 20),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [Colors.indigo.shade900, Colors.indigo.shade600],
              ).createShader(bounds),
              child: Text(
                'Maha Services',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
            ),
            Text(
              'Professional Excellence',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w300,
                color: charcoalGray.withOpacity(0.6),
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMinimalNav() {
    final navItems = [
      {'text': 'CV Builder Pro', 'icon': Icons.description_outlined},
      {'text': 'AI CV Analysis', 'icon': Icons.analytics_outlined},
      {'text': 'Executive Recruiting', 'icon': Icons.business_center_outlined},
      {'text': 'Enterprise TaaS', 'icon': Icons.school_outlined},
    ];

    return Row(
      children: navItems.map((item) => _buildNavItem(item['text'] as String, item['icon'] as IconData)).toList(),
    );
  }

  Widget _buildNavItem(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.transparent,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: charcoalGray.withOpacity(0.7),
              ),
              const SizedBox(width: 8),
              Text(
                text,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: charcoalGray.withOpacity(0.8),
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderActions() {
    return Row(
      children: [
        _buildCleanButton('Sign In', false, () {}),
        const SizedBox(width: 12),
        _buildCleanButton('Build Career', true, () {}),
      ],
    );
  }

  Widget _buildCleanButton(String text, bool isPrimary, VoidCallback onPressed) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
        decoration: BoxDecoration(
          gradient: isPrimary
              ? LinearGradient(
            colors: [Colors.indigo.shade900, Colors.indigo.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : null,
          color: isPrimary ? null : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: isPrimary
              ? null
              : Border.all(color: Colors.indigo.shade900.withOpacity(0.2), width: 1.5),
          boxShadow: isPrimary
              ? [
            BoxShadow(
              color: Colors.indigo.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ]
              : [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: isPrimary ? pureWhite : Colors.indigo.shade900,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExcitingHeroSection() {
    return Container(
      height: 1000,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            pureWhite,
            Colors.indigo.shade50.withOpacity(0.3),
            pureWhite,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 40),
        child: Row(
          children: [
            Expanded(
              flex: 7,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _buildExcitingBadge(),
                      const SizedBox(height: 40),
                      ProfessionalDefenseTagline(),
                      const SizedBox(height: 32),
                      _buildEnhancedSubtitle(),
                      const SizedBox(height: 50),
                      _buildModernCTAs(),
                      const SizedBox(height: 60),
                      _buildMinimalTrustIndicators(),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 50),
            Expanded(
              flex: 6,
              child: _buildExcitingHeroVisual(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExcitingBadge() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.indigo.shade900,
                  Colors.indigo.shade700,
                  Colors.indigo.shade800,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.indigo.withOpacity(0.4),
                  blurRadius: 25,
                  offset: const Offset(0, 12),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [Colors.white, Colors.white.withOpacity(0.8)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Next-Gen AI • Fortune 500 Trusted • Enterprise Ready',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedSubtitle() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 600),
      child: Text(
        'Empowering global professionals with intelligent career acceleration tools, executive-level training programs, and AI-driven recruitment solutions that deliver measurable results.',
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w400,
          color: charcoalGray.withOpacity(0.8),
          height: 1.7,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildModernCTAs() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child:
      Row(
        children: [
          _buildExcitingCTAButton(
            'Explore Opportunities',
            Icons.rocket_launch_outlined,
                () => context.go('/register'),
            true,
            _hoverJobSeeker,
                (hover) => setState(() => _hoverJobSeeker = hover),
          ),
          const SizedBox(width: 20),
          _buildExcitingCTAButton(
            'Hire Talent',
            Icons.people_alt_outlined,
                () => context.go('/recruiter-signup'),
            false,
            _hoverRecruiter,
                (hover) => setState(() => _hoverRecruiter = hover),
          ),
          const SizedBox(width: 20),

_buildWatchDemoButton()
        ],

      ),

    );
  }

  Widget _buildExcitingCTAButton(String text, IconData icon, VoidCallback onPressed, bool isPrimary, bool isHovered, Function(bool) onHover) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => onHover(true),
      onExit: (_) => onHover(false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        transform: isHovered
            ? Matrix4.translationValues(0, -8, 0)
            : Matrix4.identity(),
        child: Container(
          decoration: BoxDecoration(
            gradient: isPrimary
                ? LinearGradient(
              colors: isHovered
                  ? [Colors.indigo.shade800, Colors.indigo.shade600]
                  : [Colors.indigo.shade900, Colors.indigo.shade700],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
                : null,
            color: isPrimary ? null : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: isPrimary
                ? null
                : Border.all(
                color: isHovered
                    ? Colors.indigo.shade900.withOpacity(0.4)
                    : Colors.indigo.shade900.withOpacity(0.2),
                width: 2
            ),
            boxShadow: [
              BoxShadow(
                color: isPrimary
                    ? Colors.indigo.withOpacity(isHovered ? 0.5 : 0.3)
                    : Colors.black.withOpacity(isHovered ? 0.15 : 0.05),
                blurRadius: isHovered ? 35 : 20,
                offset: Offset(0, isHovered ? 15 : 8),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, size: 20),
            label: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: isPrimary ? pureWhite : Colors.indigo.shade900,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWatchDemoButton() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1 + (_pulseAnimation.value * 0.2),
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade900.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  },
                ),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.indigo.shade900, Colors.indigo.shade700],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.indigo.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Experience TaaS',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: charcoalGray.withOpacity(0.9),
                    letterSpacing: 0.3,
                  ),
                ),
                Text(
                  '3 min demo',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: charcoalGray.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMinimalTrustIndicators() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.indigo.shade900.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            'Trusted by Industry Leaders',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: charcoalGray.withOpacity(0.6),
              fontWeight: FontWeight.w500,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(width: 40),
          ...['Google', 'Microsoft', 'Meta', 'Netflix'].map(
                (company) => Padding(
              padding: const EdgeInsets.only(right: 32),
              child: Text(
                company,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.indigo.shade900.withOpacity(0.8),
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }






  Widget _buildExcitingHeroVisual() {
    return AnimatedBuilder(
      animation: _floatingController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatingAnimation.value * 0.5),
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Stack(
              children: [
                // Main floating dashboard
                _buildFloatingDashboard(),
                // Exciting floating elements
                ..._buildExcitingFloatingElements(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingDashboard() {
    return Container(
      height: 1000,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
            color: Colors.indigo.shade900.withOpacity(0.12), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.shade900.withOpacity(0.06),
            blurRadius: 60,
            offset: const Offset(0, 30),
          ),
          BoxShadow(
            color: Colors.indigo.shade900.withOpacity(0.08),
            blurRadius: 120,
            offset: const Offset(0, 60),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDashboardHeader(),
            const SizedBox(height: 20),
            _buildDashboardMetrics(),
            const SizedBox(height: 20),
            _buildDashboardChart(),
            const SizedBox(height: 20),
            _buildDashboardActivity(),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardHeader() {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.indigo.shade900.withOpacity(0.18)),
            boxShadow: [
              BoxShadow(
                color: Colors.indigo.shade900.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(Icons.dashboard_outlined,
              color: Colors.indigo.shade900, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recruiting Overview',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.indigo.shade900,
                ),
              ),
              Text(
                'Real-time insights',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  color: Colors.indigo.shade900.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.indigo.shade900, // mahroon status indicator
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }

  Widget _buildDashboardMetrics() {
    return Row(
      children: [
        _buildMetricCard('2.4K', 'Applications', 0),
        const SizedBox(width: 20),
        _buildMetricCard('847', 'Matches', 1),
        const SizedBox(width: 20),
        _buildMetricCard('23', 'Interviews', 2),
      ],
    );
  }

  Widget _buildMetricCard(String value, String label, int index) {
    // stat-specific accent colours (mahroon / indigo / mahroon-alt)
    final Color accentBorder = index == 0
        ? Colors.indigo.shade900.withOpacity(0.18)
        : index == 1
        ? Colors.indigo.shade900.withOpacity(0.18)
        : Colors.indigo.shade900.withOpacity(0.12);

    final Color valueColor = index == 0
        ? Colors.indigo.shade900
        : index == 1
        ? Colors.indigo.shade900
        : Colors.indigo.shade900;

    final Color cardBg = Colors.white;

    return Expanded(
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 +
                (math.sin(_pulseController.value * 2 * math.pi + index) * 0.02),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: accentBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.indigo.shade900.withOpacity(0.06),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: valueColor,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.indigo.shade900.withOpacity(0.6),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDashboardChart() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.indigo.shade900.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.shade900.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Activity',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.indigo
                    .shade900, // switched heading to mahroon for emphasis
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(7, (index) {
                  final heights = [0.3, 0.7, 0.5, 0.9, 0.4, 0.8, 0.6];

                  // palette cycling through mahroon + indigo variants
                  final List<Color> barColors = [
                    Colors.indigo.shade800, // mahroon (primary)
                    Colors.indigo.shade900, // indigo (accent)
                    Colors.indigo.shade700, // darker mahroon
                    Colors.indigo.shade600, // lighter indigo
                    Colors.indigo.shade900, // warm mahroon tint
                    Colors.indigo.shade400, // pale indigo
                    Colors.indigo.shade600, // mahroon slightly faded
                  ];

                  final baseColor = barColors[index % barColors.length];
                  final barOpacity = 0.12 + (heights[index] * 0.6);

                  return AnimatedBuilder(
                    animation: _morphController,
                    builder: (context, child) {
                      return AnimatedContainer(
                        duration: Duration(milliseconds: 300 + index * 100),
                        width: 20,
                        height: (heights[index] * 120) *
                            (1 +
                                math.sin(_morphController.value * 2 * math.pi +
                                    index) *
                                    0.1),
                        decoration: BoxDecoration(
                          color: baseColor.withOpacity(barOpacity),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      );
                    },
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardActivity() {
    return Column(
      children: List.generate(4, (index) {
        final activities = [
          {'icon': Icons.person_add_outlined, 'text': 'New candidate applied'},
          {'icon': Icons.message_outlined, 'text': 'Interview scheduled'},
          {'icon': Icons.check_circle_outline, 'text': 'Profile reviewed'},
          {'icon': Icons.star_border, 'text': 'Match found'},
        ];

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: AnimatedBuilder(
            animation: _floatingController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(
                    math.sin(_floatingController.value * 2 * math.pi + index) *
                        2,
                    0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: index % 2 == 0
                        ? Colors.white
                        : Colors.indigo.shade50.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.indigo.shade900.withOpacity(0.08)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: Colors.indigo.shade900.withOpacity(0.12)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.indigo.shade900.withOpacity(0.06),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          activities[index]['icon'] as IconData,
                          size: 16,
                          color: Colors.indigo.shade900.withOpacity(0.75),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          activities[index]['text'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.indigo.shade900.withOpacity(0.85),
                          ),
                        ),
                      ),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade900.withOpacity(0.35),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  List<Widget> _buildExcitingFloatingElements() {
    return [
      // Floating notification card
      Positioned(
        top: 60,
        right: -40,
        child: AnimatedBuilder(
          animation: _floatingController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(_floatingAnimation.value * 0.3,
                  math.sin(_floatingController.value * 2 * math.pi) * 15),
              child: Transform.rotate(
                angle: math.sin(_floatingController.value * 2 * math.pi) * 0.05,
                child: _buildFloatingNotificationCard(),
              ),
            );
          },
        ),
      ),
      // Floating profile cards
      Positioned(
        bottom: 80,
        left: -60,
        child: AnimatedBuilder(
          animation: _floatingController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, -_floatingAnimation.value * 0.4),
              child: _buildFloatingProfileStack(),
            );
          },
        ),
      ),
      // Floating search bar
      Positioned(
        top: 200,
        right: 50,
        child: AnimatedBuilder(
          animation: _breatheController,
          builder: (context, child) {
            return Transform.scale(
              scale: _breatheAnimation.value * 0.95,
              child: _buildFloatingSearchBar(),
            );
          },
        ),
      ),
    ];
  }

  Widget _buildFloatingNotificationCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.indigo.shade900.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.shade200,
            blurRadius: 25,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.indigo.shade900,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.indigo.shade900.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.notifications_none,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Perfect Match!',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.indigo.shade900,
                ),
              ),
              Text(
                'Senior Developer • Google',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w300,
                  color: Colors.indigo.shade900.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingProfileStack() {
    return Stack(
      children: List.generate(3, (index) {
        return Transform.translate(
          offset: Offset(index * 20.0, index * 15.0),
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 +
                    (math.sin(_pulseController.value * 2 * math.pi + index) *
                        0.05),
                child: Container(
                  width: 80,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: Colors.indigo.shade900.withOpacity(0.12)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.indigo.shade900.withOpacity(0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: index == 0
                              ? Colors.white
                              : index == 1
                              ? Colors.indigo.shade50
                              : Colors.indigo.shade100,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.indigo.shade900.withOpacity(0.12)),
                        ),
                        child: Icon(
                          [
                            Icons.person_outline,
                            Icons.work_outline,
                            Icons.star_border
                          ][index],
                          size: 20,
                          color: Colors.indigo.shade900.withOpacity(0.75),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 50,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade900.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildFloatingSearchBar() {
    return Container(
      width: 280,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.indigo.shade900.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.shade100,
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 20),
          Icon(Icons.search,
              color: Colors.indigo.shade900.withOpacity(0.5), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Search for dream jobs...',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w300,
                color: Colors.indigo.shade900.withOpacity(0.5),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 4),
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.indigo.shade900,
              shape: BoxShape.circle,
            ),
            child:
            const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }







  Widget _buildProfessionalFeaturesSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey.shade50,
            Colors.white,
            Colors.grey.shade50,
          ],
        ),
      ),
      child: Column(
        children: [
          _buildProfessionalSectionHeader(
            'Elite Talent Solutions',
            'Advanced AI-powered recruitment platform connecting world-class professionals with Fortune 500 companies',
          ),
          const SizedBox(height: 60),
          _buildProfessionalFeatureGrid(),
        ],
      ),
    );
  }

  Widget _buildProfessionalSectionHeader(String title, String subtitle) {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) =>
              LinearGradient(
                colors: [Colors.indigo.shade900, Colors.indigo.shade600],
              ).createShader(bounds),
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 48,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: -1.2,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: 80,
          height: 6,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo.shade900, Colors.indigo.shade600],
            ),
            borderRadius: BorderRadius.circular(3),
            boxShadow: [
              BoxShadow(
                color: Colors.indigo.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfessionalFeatureGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxis = constraints.maxWidth > 1200
            ? 3
            : constraints.maxWidth > 800
            ? 2
            : 1;

        // responsive fixed tile height (lower values = less vertical space)
        final double tileHeight = constraints.maxWidth > 1200
            ? 240.0
            : constraints.maxWidth > 800
            ? 220.0
            : 180.0;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxis,
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
            mainAxisExtent: tileHeight,
          ),
          itemCount: 6,
          itemBuilder: (context, index) =>
              _buildProfessionalFeatureCard(index),
        );
      },
    );
  }


  Widget _buildProfessionalFeatureCard(int index) {
    final features = [
      {
        'icon': Icons.public,
        'title': 'Global Network',
        'desc': 'Access premium opportunities across 50+ countries with verified multinational corporations',
        'color': Colors.blue.shade700,
      },
      {
        'icon': Icons.verified_outlined,
        'title': 'Executive Screening',
        'desc': 'Military-grade background verification with psychological profiling and competency analysis',
        'color': Colors.green.shade700,
      },
      {
        'icon': Icons.psychology_alt_outlined,
        'title': 'AI Matching',
        'desc': 'Advanced machine learning algorithms for precise skill-role compatibility scoring',
        'color': Colors.purple.shade700,
      },
      {
        'icon': Icons.timeline,
        'title': 'White-Glove Service',
        'desc': 'Dedicated relationship managers handling complete recruitment lifecycle management',
        'color': Colors.orange.shade700,
      },
      {
        'icon': Icons.group_work,
        'title': 'Elite Recruiters',
        'desc': 'Exclusive network of C-level recruiters from top-tier executive search firms',
        'color': Colors.teal.shade700,
      },
      {
        'icon': Icons.insights,
        'title': 'Predictive Analytics',
        'desc': 'Real-time market intelligence with salary benchmarking and career trajectory mapping',
        'color': Colors.red.shade700,
      },
    ];

    final feature = features[index];

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 800 + (index * 200)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 25,
                    offset: const Offset(0, 10),
                    spreadRadius: -5,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          feature['color'] as Color,
                          (feature['color'] as Color).withOpacity(0.7)
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: (feature['color'] as Color).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      feature['icon'] as IconData,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    feature['title'] as String,
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    feature['desc'] as String,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey.shade600,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfessionalStatsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 60, horizontal: 40),
      padding: const EdgeInsets.all(50),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.indigo.shade900,
            Colors.indigo.shade800,
            Colors.indigo.shade900,
          ],
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        children: [
          ShaderMask(
            shaderCallback: (bounds) =>
                const LinearGradient(
                  colors: [Colors.white, Colors.white70],
                ).createShader(bounds),
            child: Text(
              'Performance Excellence',
              style: GoogleFonts.poppins(
                fontSize: 42,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.8,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Industry-leading metrics driving executive career success',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 50),
          Wrap(
            spacing: 40,
            runSpacing: 30,
            alignment: WrapAlignment.center,
            children: [
              _buildProfessionalStatItem(
                  '50K+', 'Executive Positions', Icons.work_outline,
                  Colors.amber.shade400),
              _buildProfessionalStatItem(
                  '250K+', 'Verified Executives', Icons.people_outline,
                  Colors.cyan.shade400),
              _buildProfessionalStatItem(
                  '8K+', 'Elite Headhunters', Icons.business_outlined,
                  Colors.green.shade400),
              _buildProfessionalStatItem(
                  '97%', 'Success Rate', Icons.trending_up_outlined,
                  Colors.pink.shade400),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalStatItem(String number, String label, IconData icon,
      Color accentColor) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1500),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Container(
          width: 220,
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(icon, size: 36, color: accentColor),
              ),
              const SizedBox(height: 20),
              ShaderMask(
                shaderCallback: (bounds) =>
                    LinearGradient(
                      colors: [Colors.white, accentColor],
                    ).createShader(bounds),
                child: Text(
                  number,
                  style: GoogleFonts.poppins(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -1,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTestimonialsSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white,
            Colors.grey.shade50,
          ],
        ),
      ),
      child: Column(
        children: [
          _buildProfessionalSectionHeader(
            'Executive Testimonials',
            'Transformative career experiences from C-suite executives and Fortune 500 talent leaders',
          ),
          const SizedBox(height: 60),
          _buildTestimonialGrid(),
        ],
      ),
    );
  }

  Widget _buildTestimonialGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildProfessionalTestimonialCard(0),
              const SizedBox(width: 24),
              _buildProfessionalTestimonialCard(1),
              const SizedBox(width: 24),
              _buildProfessionalTestimonialCard(2),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfessionalTestimonialCard(int index) {
    final testimonials = [
      {
        'name': 'Alexandra Sterling',
        'role': 'Chief Technology Officer • Meta',
        'content': 'Revolutionary platform that transformed our executive hiring strategy. Reduced time-to-hire by 75% while dramatically improving candidate quality and cultural fit.',
        'type': 'CTO',
        'company': 'Meta',
        'avatar': 'AS'
      },
      {
        'name': 'Marcus Chen',
        'role': 'Managing Director • JPMorgan Chase',
        'content': 'Exceptional white-glove service with unparalleled access to C-suite opportunities. Secured my dream executive role with comprehensive support throughout the entire process.',
        'type': 'Executive',
        'company': 'JPMorgan',
        'avatar': 'MC'
      },
      {
        'name': 'Dr. Elena Rodriguez',
        'role': 'Global Head of Talent • McKinsey',
        'content': 'Game-changing recruitment intelligence with predictive analytics that consistently delivers top-tier executive talent. Our strategic partnership has been transformational.',
        'type': 'Talent Lead',
        'company': 'McKinsey',
        'avatar': 'ER'
      },
    ];

    final testimonial = testimonials[index];
    final colors = [
      Colors.indigo.shade700,
      Colors.teal.shade700,
      Colors.purple.shade700
    ];

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 1000 + (index * 300)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: Opacity(
            opacity: value,
            child: Container(
              width: 400,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                    color: colors[index].withOpacity(0.1), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: colors[index].withOpacity(0.1),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                    spreadRadius: -5,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              colors[index],
                              colors[index].withOpacity(0.7)
                            ],
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: colors[index].withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            testimonial['avatar']!,
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              testimonial['name']!,
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey.shade900,
                              ),
                            ),
                            Text(
                              testimonial['role']!,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: colors[index],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              colors[index].withOpacity(0.1),
                              colors[index].withOpacity(0.05)
                            ],
                          ),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                              color: colors[index].withOpacity(0.2)),
                        ),
                        child: Text(
                          testimonial['type']!,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colors[index],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Text(
                      '"${testimonial['content']}"',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey.shade700,
                        height: 1.6,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfessionalFooter() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.indigo.shade900,
            Colors.indigo.shade800,
            Colors.indigo.shade900,
          ],
        ),
      ),
      child: Column(
        children: [
          _buildFooterCTA(),
          _buildFooterContent(),
        ],
      ),
    );
  }

  Widget _buildFooterCTA() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 40),
      child: Container(
        padding: const EdgeInsets.all(50),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) =>
                        LinearGradient(
                          colors: [
                            Colors.indigo.shade900,
                            Colors.indigo.shade600
                          ],
                        ).createShader(bounds),
                    child: Text(
                      'Ready to Elevate Your\nCareer to Executive Level?',
                      style: GoogleFonts.poppins(
                        fontSize: 38,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.2,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Join the exclusive network of C-suite executives and Fortune 500 leaders.',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 40),
            Column(
              children: [
                _buildProfessionalCTAButton(
                    'Executive Access', () {}, Colors.indigo.shade800),
                const SizedBox(height: 12),
                _buildProfessionalCTAButton(
                    'Recruiter Portal', () {}, Colors.teal.shade700),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfessionalCTAButton(String text, VoidCallback onPressed,
      Color color) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 8,
        shadowColor: color.withOpacity(0.4),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.arrow_forward, size: 20),
        ],
      ),
    );
  }

  Widget _buildFooterContent() {
    return Container(
      padding: const EdgeInsets.all(50),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) =>
                          const LinearGradient(
                            colors: [Colors.white, Colors.white70],
                          ).createShader(bounds),
                      child: Text(
                        'Maha Services Executive',
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Premier executive recruitment platform connecting world-class C-suite talent with Fortune 500 opportunities through advanced AI-powered matching.',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withOpacity(0.8),
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 50),
              _buildFooterColumn('Executive Services', [
                'C-Suite Opportunities',
                'Executive Coaching',
                'Leadership Assessment',
                'Career Transformation'
              ]),
              const SizedBox(width: 30),
              _buildFooterColumn('For Recruiters', [
                'Premium Listings',
                'Executive Search',
                'Talent Intelligence',
                'White-Label Solutions'
              ]),
              const SizedBox(width: 30),
              _buildFooterColumn('Company', [
                'About Excellence',
                'Partner Network',
                'Privacy & Security',
                'Terms & Conditions'
              ]),
            ],
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.white.withOpacity(0.15)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '© 2025 Maha Services Executive. All rights reserved. | Elite Recruitment Solutions',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                Row(
                  children: [
                    _buildSocialIcon(Icons.dialer_sip, Colors.blue.shade600),
                    const SizedBox(width: 12),
                    _buildSocialIcon(Icons.facebook, Colors.indigo.shade600),
                    const SizedBox(width: 12),
                    _buildSocialIcon(Icons.language, Colors.teal.shade600),
                  ],
                ),
              ],
            ),
          ),
        ],
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
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        ...items.map((item) =>
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                item,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildSocialIcon(IconData icon, Color accentColor) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05)
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Icon(icon, size: 20, color: accentColor),
    );
  }
}


// Custom painter for subtle geometric background pattern
class _GeometricPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.indigo.shade900.withOpacity(0.02)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final spacing = 80.0;

    // Draw subtle grid pattern
    for (double x = 0; x <= size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y <= size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Add some geometric shapes
    for (int i = 0; i < 5; i++) {
      final center = Offset(
        (i * spacing * 3) % size.width,
        (i * spacing * 2) % size.height,
      );
      canvas.drawCircle(center, 20, paint..color = Colors.indigo.shade900.withOpacity(0.01));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
