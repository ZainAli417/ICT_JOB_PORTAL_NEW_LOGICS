import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const SplashScreen());
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TalentBridge - Smart Hiring Platform',
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
  const LandingPage({Key? key}) : super(key: key);

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with TickerProviderStateMixin { // <- changed from SingleTickerProviderStateMixin
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;


  bool isDarkMode = false;

  late AnimationController _workflowController;
  late Animation<double> _workflowAnimation;

  int _activeStage = 0;
  Timer? _stageTimer;

  @override
  void initState() {
    super.initState();

    // workflow controller
    _workflowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _workflowAnimation = CurvedAnimation(
      parent: _workflowController,
      curve: Curves.easeInOut,
    );
    _workflowController.forward();

    // Auto-cycle through stages
    _stageTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      setState(() {
        _activeStage = (_activeStage + 1) % 5;
      });
    });

    // main fade controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

  }

  @override
  void dispose() {
    _stageTimer?.cancel();          // cancel timer
    _workflowController.dispose();  // dispose all controllers you created
    _animationController.dispose();
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
      backgroundColor: isDarkMode ? const Color(0xFF0F172A) : Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildTopBar(),
            _buildHeroSection2(),
            _buildEnhancedWorkflowSection(),
            _buildFeaturesSection(),
            _buildStatsSection(),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  // ==================== TOP BAR ====================
  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 20),
      decoration: BoxDecoration(
        color: isDarkMode
            ? const Color(0xFF1E293B).withOpacity(0.95)
            : Colors.white.withOpacity(0.95),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border(
          bottom: BorderSide(
            color: isDarkMode
                ? const Color(0xFF334155)
                : const Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.4),
                      blurRadius: 15,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.work_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'TalentBridge',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          // Navigation Menu
          Row(
            children: [
              _buildNavItem('Features', Icons.stars_rounded),
              const SizedBox(width: 32),
              _buildNavItem('Workflow', Icons.account_tree_rounded),
              const SizedBox(width: 32),
              _buildNavItem('Pricing', Icons.payments_rounded),
              const SizedBox(width: 32),
              _buildNavItem('About', Icons.info_rounded),
              const SizedBox(width: 40),
              // Theme Toggle
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: toggleTheme,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? const Color(0xFF334155)
                          : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDarkMode
                            ? const Color(0xFF475569)
                            : const Color(0xFFE5E7EB),
                      ),
                    ),
                    child: Icon(
                      isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                      color: isDarkMode
                          ? const Color(0xFFFBBF24)
                          : const Color(0xFF6366F1),
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Sign In
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
                    color: isDarkMode
                        ? const Color(0xFFA5B4FC)
                        : const Color(0xFF6366F1),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Get Started Button
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
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
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
              color: isDarkMode
                  ? const Color(0xFF94A3B8)
                  : const Color(0xFF6B7280),
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDarkMode
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
















// ==================== HERO2 LEFT SIDE SECTION ====================

  Widget _buildHeroSection2() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 60, vertical: 60),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF9FAFB),
            Color(0xFFEEF2FF),
            Color(0xFFF9FAFB),
          ],
        ),
      ),
      child: Stack(
        children: [
          // MORE PROMINENT Geometric background patterns
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 4,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFEDE9FE), Color(0xFFDDD6FE)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Color(0xFF6366F1).withOpacity(0.2)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.auto_awesome,
                                color: Color(0xFF6366F1), size: 16),
                            SizedBox(width: 8),
                            Text(
                              'AI-Powered 5-Stage Hiring System',
                              style: GoogleFonts.poppins(
                                  color: Color(0xFF6366F1),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 30),
                      Text(
                        'Smart Hiring\nMade Simple',
                        style: GoogleFonts.poppins(
                          fontSize: 56,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F2937),
                          height: 1.15,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Connect job seekers with recruiters through an intelligent\n3-tier system: Candidates create profiles, Recruiters select talent,\nand Admins manage the complete hiring lifecycle.',
                        style: GoogleFonts.poppins(
                          fontSize: 17,
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w400,
                          height: 1.7,
                        ),
                      ),
                      SizedBox(height: 40),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: Icon(Icons.person_add_rounded, size: 20),
                            label: Text('Join as Candidate',
                                style: GoogleFonts.poppins(
                                    fontSize: 15, fontWeight: FontWeight.w600)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF6366F1),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 20),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 3,
                            ),
                          ),
                          SizedBox(width: 20),
                          OutlinedButton.icon(
                            onPressed: () {},
                            icon: Icon(Icons.business_center,
                                color: Color(0xFF10B981)),
                            label: Text('I\'m a Recruiter',
                                style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    color: Color(0xFF10B981),
                                    fontWeight: FontWeight.w600)),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 20),
                              side: BorderSide(
                                  color: Color(0xFF10B981), width: 2),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 50),
                      Row(
                        children: [
                          _buildStat('8K+', 'Active Candidates',
                              Icons.people_alt_rounded, Color(0xFF6366F1)),
                          SizedBox(width: 60),
                          _buildStat('500+', 'Recruiters',
                              Icons.business_rounded, Color(0xFF10B981)),
                          SizedBox(width: 60),
                          _buildStat('95%', 'Success Rate',
                              Icons.verified_rounded, Color(0xFFF59E0B)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 40),
              Expanded(
                flex: 6,
                child: _buildCircularWorkflow(),
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildStat(String number, String label, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              number,
              style: GoogleFonts.poppins(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(label,
                style: GoogleFonts.poppins(
                    color: Color(0xFF6B7280),
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }





// ==================== HERO2 SECTION  RIGHT SIDE ====================

  Widget _buildCircularWorkflow() {
    final stages = [
      {
        'step': 'Step 1',
        'title': 'Candidate\nRegister',
        'icon': Icons.person_add_rounded,
        'color': const Color(0xFF080B87),
      },
      {
        'step': 'Step 2',
        'title': 'Create\nProfile',
        'icon': Icons.description_rounded,
        'color': const Color(0xFF05A06D),
      },
      {
        'step': 'Step 3',
        'title': 'Recruiter\nSelects',
        'icon': Icons.how_to_reg_rounded,
        'color': const Color(0xFFF59E0B),
      },
      {
        'step': 'Step 4',
        'title': 'Admin\nProcesses',
        'icon': Icons.admin_panel_settings_rounded,
        'color': const Color(0xFFEC4899),
      },
      {
        'step': 'Step 5',
        'title': 'Handover to\nRecruiter',
        'icon': Icons.verified_rounded,
        'color': const Color(0xFF8B5CF6),
      },
    ];

    return Container(
      width: 550,
      height: 550,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Animated Circular Progress
          SizedBox(
            width: 450,
            height: 450,
            child: CustomPaint(
              painter: CircularWorkflowPainter(
                activeStage: _activeStage,
                isDarkMode: isDarkMode,
                stages: stages.length,
              ),
            ),
          ),

          // Central Hub
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF6366F1),
                  const Color(0xFF8B5CF6),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withOpacity(0.5),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 36,
                ),
                const SizedBox(height: 8),
                Text(
                  'Maha Services',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Stage Cards positioned in circle
          ...List.generate(stages.length, (index) {
            final angle = (index * 2 * math.pi / stages.length) - (math.pi / 2);
            final radius = 225.0;
            final x = radius *math. cos(angle);
            final y = radius *math. sin(angle);

            return Transform.translate(
              offset: Offset(x, y),
              child: _buildCircularStageCard(
                stages[index]['step'] as String,
                stages[index]['title'] as String,
                stages[index]['icon'] as IconData,
                stages[index]['color'] as Color,
                index,
              ),
            );
          }),
        ],
      ),
    );
  }
  Widget _buildCircularStageCard(
      String step,
      String title,
      IconData icon,
      Color color,
      int index,
      ) {
    final isActive = _activeStage == index;
    final isPassed = _activeStage > index || (_activeStage == 0 && index == 4);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      width: 110,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon Circle
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            width: isActive ? 70 : 60,
            height: isActive ? 70 : 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isActive || isPassed
                  ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color, color.withOpacity(0.7)],
              )
                  : null,
              color: isActive || isPassed
                  ? null
                  : isDarkMode
                  ? const Color(0xFF334155)
                  : const Color(0xFFE5E7EB),
              border: Border.all(
                color: isActive
                    ? color
                    : isPassed
                    ? color.withOpacity(0.5)
                    : isDarkMode
                    ? const Color(0xFF475569)
                    : const Color(0xFFD1D5DB),
                width: isActive ? 3 : 2,
              ),
              boxShadow: isActive
                  ? [
                BoxShadow(
                  color: color.withOpacity(0.6),
                  blurRadius: 25,
                  spreadRadius: 5,
                ),
              ]
                  : [],
            ),
            child: Center(
              child: Icon(
                isPassed ? Icons.check_rounded : icon,
                color: isActive || isPassed
                    ? Colors.white
                    : isDarkMode
                    ? const Color(0xFF64748B)
                    : const Color(0xFF9CA3AF),
                size: isActive ? 32 : 26,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Step Badge
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              gradient: isActive
                  ? LinearGradient(
                colors: [color.withOpacity(0.3), color.withOpacity(0.2)],
              )
                  : null,
              color: isActive
                  ? null
                  : isDarkMode
                  ? const Color(0xFF1E293B)
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isActive
                    ? color
                    : isDarkMode
                    ? const Color(0xFF334155)
                    : const Color(0xFFE5E7EB),
                width: isActive ? 2 : 1,
              ),
              boxShadow: isActive
                  ? [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 15,
                ),
              ]
                  : [],
            ),
            child: Text(
              step,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: isActive
                    ? color
                    : isDarkMode
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF6B7280),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isActive
                  ? (isDarkMode ? Colors.white : const Color(0xFF1F2937))
                  : isDarkMode
                  ? const Color(0xFF64748B)
                  : const Color(0xFF9CA3AF),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }





// ==================== LANDING PAGE SECTION2 ANIMATED ====================
  Widget _buildEnhancedWorkflowSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 100),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDarkMode
              ? [
            const Color(0xFF0F172A),
            const Color(0xFF1E293B),
          ]
              : [
            const Color(0xFFFAFAFA),
            const Color(0xFFFFFFFF),
          ],
        ),
      ),
      child: Column(
        children: [
          // Section Header
          FadeTransition(
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
                      const Icon(Icons.account_tree_rounded,
                          color: Color(0xFF818CF8), size: 18),
                      const SizedBox(width: 10),
                      Text(
                        'Workflow Process',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFFA5B4FC),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  '5-Stage Hiring Journey',
                  style: GoogleFonts.poppins(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'From profile creation to final placement - automated and intelligent',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: isDarkMode
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF6B7280),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 80),
          // Animated Workflow
          _buildAnimatedWorkflow(),
        ],
      ),
    );
  }
  Widget _buildAnimatedWorkflow() {
    final stages = [
      {
        'step': 'Step 1',
        'title': 'Candidate Register',
        'subtitle': 'Create profile and showcase skills',
        'icon': Icons.person_add_rounded,
        'color': const Color(0xFF6366F1),
      },
      {
        'step': 'Step 2',
        'title': 'Create Profile',
        'subtitle': 'Build CV and add experience',
        'icon': Icons.description_rounded,
        'color': const Color(0xFF10B981),
      },
      {
        'step': 'Step 3',
        'title': 'Recruiter Selects',
        'subtitle': 'Shortlist and submit request',
        'icon': Icons.how_to_reg_rounded,
        'color': const Color(0xFFF59E0B),
      },
      {
        'step': 'Step 4',
        'title': 'Admin Processes',
        'subtitle': 'Review, train & evaluate',
        'icon': Icons.admin_panel_settings_rounded,
        'color': const Color(0xFFEC4899),
      },
      {
        'step': 'Step 5',
        'title': 'Handover to Recruiter',
        'subtitle': 'Deliver trained candidates',
        'icon': Icons.verified_rounded,
        'color': const Color(0xFF8B5CF6),
      },
    ];

    return SizedBox(
      height: 500,
      child: Stack(
        children: [
          // Connecting Lines
          Positioned.fill(
            child: CustomPaint(
              painter: WorkflowLinePainter(
                activeStage: _activeStage,
                isDarkMode: isDarkMode,
              ),
            ),
          ),
          // Stage Cards
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(
              stages.length,
                  (index) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: _buildStageCard2(
                    stages[index]['step'] as String,
                    stages[index]['title'] as String,
                    stages[index]['subtitle'] as String,
                    stages[index]['icon'] as IconData,
                    stages[index]['color'] as Color,
                    index,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildStageCard2(
      String step,
      String title,
      String subtitle,
      IconData icon,
      Color color,
      int index,
      ) {
    final isActive = _activeStage == index;
    final isPassed = _activeStage > index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      child: Column(
        children: [
          // Step Circle
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
                colors: [color, color.withOpacity(0.7)],
              )
                  : null,
              color: isActive || isPassed
                  ? null
                  : isDarkMode
                  ? const Color(0xFF334155)
                  : const Color(0xFFE5E7EB),
              border: Border.all(
                color: isActive
                    ? color
                    : isPassed
                    ? color.withOpacity(0.5)
                    : isDarkMode
                    ? const Color(0xFF475569)
                    : const Color(0xFFD1D5DB),
                width: isActive ? 3 : 2,
              ),
              boxShadow: isActive
                  ? [
                BoxShadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ]
                  : [],
            ),
            child: Center(
              child: Icon(
                isPassed ? Icons.check_rounded : icon,
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
          // Card
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: isActive
                  ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDarkMode
                    ? [
                  color.withOpacity(0.2),
                  color.withOpacity(0.1),
                ]
                    : [
                  color.withOpacity(0.15),
                  color.withOpacity(0.05),
                ],
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
                    ? color
                    : isDarkMode
                    ? const Color(0xFF334155)
                    : const Color(0xFFE5E7EB),
                width: isActive ? 2 : 1,
              ),
              boxShadow: isActive
                  ? [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 25,
                  spreadRadius: 2,
                ),
              ]
                  : [
                BoxShadow(
                  color: isDarkMode
                      ? Colors.black.withOpacity(0.3)
                      : Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              children: [
                // Step Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isActive
                        ? color.withOpacity(0.2)
                        : isDarkMode
                        ? const Color(0xFF334155)
                        : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isActive
                          ? color.withOpacity(0.5)
                          : isDarkMode
                          ? const Color(0xFF475569)
                          : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: Text(
                    step,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isActive
                          ? color
                          : isDarkMode
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF6B7280),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Title
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isActive
                        ? (isDarkMode ? Colors.white : const Color(0xFF1F2937))
                        : isDarkMode
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 8),
                // Subtitle
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: isActive
                        ? (isDarkMode
                        ? const Color(0xFFCBD5E1)
                        : const Color(0xFF6B7280))
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





// ==================== LANDIGNG PAGE SECTION ====================
  Widget _buildFeaturesSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 80, vertical: 100),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF8FAFC),
            Color(0xFFEFF6FF),
            Color(0xFFFAF5FF),
          ],
        ),
      ),
      child: Column(
        children: [
          // Header with stats
          Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  '🚀 COMPLETE ECOSYSTEM',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Complete Hiring Ecosystem',
                style: GoogleFonts.poppins(
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F2937),
                  height: 1.2,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Three powerful portals, one seamless journey',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 50),
              // Quick stats
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStatCard('12K+', 'Active Users', Color(0xFF6366F1)),
                  SizedBox(width: 30),
                  _buildStatCard('95%', 'Success Rate', Color(0xFF10B981)),
                  SizedBox(width: 30),
                  _buildStatCard('24/7', 'Support', Color(0xFFF59E0B)),
                ],
              ),
            ],
          ),
          SizedBox(height: 80),
          // Feature cards with process flow
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildModernFeatureCard(
                  '01',
                  'Candidate Portal',
                  'Your Career, Your Control',
                  Color(0xFF6366F1),
                  [
                    _Feature('Profile Builder', 'Create comprehensive professional profiles',
                        Icons.account_circle_rounded),
                    _Feature('CV Generator', 'AI-powered resume creation tools',
                        Icons.description_rounded),
                    _Feature('Skill Showcase', 'Highlight expertise and certifications',
                        Icons.workspace_premium_rounded),
                    _Feature('Public Portfolio', 'Share your journey with recruiters',
                        Icons.public_rounded),
                  ],
                ),
              ),
              // Flow arrow
              Padding(
                padding: EdgeInsets.only(top: 100),
                child: Icon(Icons.arrow_forward, color: Color(0xFFD1D5DB), size: 40),
              ),
              Expanded(
                child: _buildModernFeatureCard(
                  '02',
                  'Recruiter Portal',
                  'Find Perfect Candidates Fast',
                  Color(0xFF10B981),
                  [
                    _Feature('Candidate Search', 'Browse qualified talent pool',
                        Icons.search_rounded),
                    _Feature('Bulk Selection', 'Select multiple candidates at once',
                        Icons.checklist_rounded),
                    _Feature('Request Management', 'Submit hiring requests to admin',
                        Icons.send_rounded),
                    _Feature('Direct Handover', 'Receive trained candidates ready to work',
                        Icons.handshake_rounded),
                  ],
                ),
              ),
              // Flow arrow
              Padding(
                padding: EdgeInsets.only(top: 100),
                child: Icon(Icons.arrow_forward, color: Color(0xFFD1D5DB), size: 40),
              ),
              Expanded(
                child: _buildModernFeatureCard(
                  '03',
                  'Admin Portal',
                  'End-to-End Hiring Management',
                  Color(0xFFF59E0B),
                  [
                    _Feature('Request Review', 'Evaluate recruiter requests',
                        Icons.rate_review_rounded),
                    _Feature('Interview Scheduling', 'Organize and conduct interviews',
                        Icons.event_rounded),
                    _Feature('Candidate Training', 'Skill development and preparation',
                        Icons.school_rounded),
                    _Feature('Final Selection', 'Complete hiring and onboarding',
                        Icons.how_to_reg_rounded),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildStatCard(String value, String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 4),
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
                ).createShader(Rect.fromLTWH(0, 0, 200, 70)),
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildModernFeatureCard(
      String number,
      String title,
      String subtitle,
      Color color,
      List<_Feature> features,
      ) {
    return Container(
      padding: EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.2), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 30,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Number badge and icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  number,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  title.contains('Candidate')
                      ? Icons.person_rounded
                      : title.contains('Recruiter')
                      ? Icons.business_rounded
                      : Icons.admin_panel_settings_rounded,
                  color: color,
                  size: 32,
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
            ),
          ),
          SizedBox(height: 8),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
          SizedBox(height: 28),
          // Features list
          ...features.asMap().entries.map((entry) {
            final index = entry.key;
            final f = entry.value;
            return Padding(
              padding: EdgeInsets.only(bottom: index < features.length - 1 ? 16 : 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: color.withOpacity(0.2)),
                    ),
                    child: Icon(f.icon, color: color, size: 22),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          f.title,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          f.description,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Color(0xFF9CA3AF),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }



  // ==================== WORKFLOW SECTION ====================
  Widget _buildStatsSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 80),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [
            const Color(0xFF1F2937),
            const Color(0xFF111827),
            const Color(0xFF1F2937),
          ]
              : [
            const Color(0xFF6366F1),
            const Color(0xFF8B5CF6),
            const Color(0xFF6366F1),
          ],
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Text(
              '⚡ COMPLETE WORKFLOW',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'End-to-End Hiring Journey',
            style: GoogleFonts.poppins(
              fontSize: 42,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'From profile creation to successful placement - visualized',
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: Colors.white.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 70),
          // Workflow visualization
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildWorkflowStage(
                  'STAGE 1',
                  'Candidate Setup',
                  const Color(0xFF6366F1),
                  Icons.person_add_rounded,
                  [
                    'Profile Registration',
                    'Document Upload',
                    'Skills Assessment',
                    'CV Generation',
                    'Portfolio Creation',
                  ],
                ),
              ),
              _buildWorkflowArrow(),
              Expanded(
                child: _buildWorkflowStage(
                  'STAGE 2',
                  'Talent Discovery',
                  const Color(0xFF10B981),
                  Icons.search_rounded,
                  [
                    'Public Profile View',
                    'Search & Filter',
                    'Candidate Matching',
                    'Bulk Selection',
                    'Shortlisting',
                  ],
                ),
              ),
              _buildWorkflowArrow(),
              Expanded(
                child: _buildWorkflowStage(
                  'STAGE 3',
                  'Hiring Request',
                  const Color(0xFFF59E0B),
                  Icons.request_page_rounded,
                  [
                    'Request Submission',
                    'Admin Review',
                    'Requirement Analysis',
                    'Approval Process',
                    'Request Tracking',
                  ],
                ),
              ),
              _buildWorkflowArrow(),
              Expanded(
                child: _buildWorkflowStage(
                  'STAGE 4',
                  'Assessment',
                  const Color(0xFFEC4899),
                  Icons.calendar_today_rounded,
                  [
                    'Interview Scheduling',
                    'Candidate Evaluation',
                    'Skill Testing',
                    'Panel Review',
                    'Feedback Collection',
                  ],
                ),
              ),
              _buildWorkflowArrow(),
              Expanded(
                child: _buildWorkflowStage(
                  'STAGE 5',
                  'Final Placement',
                  const Color(0xFF8B5CF6),
                  Icons.check_circle_rounded,
                  [
                    'Candidate Training',
                    'Skill Development',
                    'Final Preparation',
                    'Handover to Recruiter',
                    'Onboarding Complete',
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 60),
          // Success metrics
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
  Widget _buildWorkflowStage(
      String stageLabel,
      String title,
      Color color,
      IconData icon,
      List<String> steps,
      ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.7)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              stageLabel,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          ...steps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: color.withOpacity(0.5)),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      step,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.8),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
  Widget _buildWorkflowArrow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 80),
      child: Column(
        children: [
          Icon(
            Icons.arrow_forward_ios_outlined,
            color: Colors.white.withOpacity(0.4),
            size: 30,
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
              ? [
            const Color(0xFF111827),
            const Color(0xFF000000),
          ]
              : [
            const Color(0xFF1F2937),
            const Color(0xFF111827),
          ],
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 70),
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
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                  const Color(0xFF6366F1).withOpacity(0.3),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.join_left_outlined,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Maha Services',
                            style: GoogleFonts.poppins(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Revolutionizing recruitment through an intelligent 5-stage hiring ecosystem. Connecting talent with opportunity seamlessly.',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF9CA3AF),
                              fontSize: 14,
                              height: 1.8,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              _buildSocialIcon(
                                  Icons.facebook, const Color(0xFF1877F2)),
                              const SizedBox(width: 12),
                              _buildSocialIcon(Icons.linked_camera,
                                  const Color(0xFF0A66C2)),
                              const SizedBox(width: 12),
                              _buildSocialIcon(
                                  Icons.mail_rounded, const Color(0xFFEA4335)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 80),
                    Expanded(
                      child: _buildFooterColumn('For Candidates', [
                        'Create Profile',
                        'Build CV',
                        'Browse Jobs',
                        'Career Resources',
                      ]),
                    ),
                    const SizedBox(width: 60),
                    Expanded(
                      child: _buildFooterColumn('For Recruiters', [
                        'Find Talent',
                        'Submit Requests',
                        'Pricing Plans',
                        'Success Stories',
                      ]),
                    ),
                    const SizedBox(width: 60),
                    Expanded(
                      child: _buildFooterColumn('Company', [
                        'About Us',
                        'Contact',
                        'Careers',
                        'Privacy Policy',
                      ]),
                    ),
                  ],
                ),
                const SizedBox(height: 60),
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF6366F1).withOpacity(0.1),
                        const Color(0xFF8B5CF6).withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF6366F1).withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.mail_outline_rounded,
                        color: Color(0xFF6366F1),
                        size: 32,
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Stay Updated',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Get the latest hiring insights and platform updates',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: const Color(0xFF9CA3AF),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28, vertical: 14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                          ),
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
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 30),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xFF374151), width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '© 2025 TalentBridge. All rights reserved.',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF6B7280),
                    fontSize: 13,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF6366F1).withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.psychology_rounded,
                            color: Color(0xFF6366F1),
                            size: 16,
                          ),
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
              ],
            ),
          ),
        ],
      ),
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
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        ...items
            .map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Row(
              children: [
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Color(0xFF6366F1),
                  size: 12,
                ),
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
        ))
            .toList(),
      ],
    );
  }
}

// Feature class
class _Feature {
  final String title;
  final String description;
  final IconData icon;

  _Feature(this.title, this.description, this.icon);
}


class ZigzagConnectorPainter extends CustomPainter {
  final List<Offset> centers;
  final List<double> radii;
  final List<Color> colors;
  final int currentStep;

  ZigzagConnectorPainter({
    required this.centers,
    required this.radii,
    required this.colors,
    required this.currentStep,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    const double paddingTrim = 6.0; // extra safe gap so connector doesn't peek under the circle

    for (int i = 0; i < centers.length - 1; i++) {
      final Offset a = centers[i];
      final Offset b = centers[i + 1];

      // Decide color based on progress (tweak as you like)
      final bool isPassed = i < currentStep;
      paint.color = isPassed ? colors[i].withOpacity(0.85) : Colors.grey.withOpacity(0.28);

      final double dx = b.dx - a.dx;
      final double dy = b.dy - a.dy;
      final double dist = math.sqrt(dx * dx + dy * dy);

      final double trim = (radii[i] + radii[i + 1]) + paddingTrim;

      if (dist <= trim + 0.5) {
        // Too close — skip drawing this connector
        continue;
      }

      // Unit direction from a -> b
      final double ux = dx / dist;
      final double uy = dy / dist;

      // Move start and end inward by radius + half padding so line stops at circle edge (not inside)
      final Offset start = Offset(
        a.dx + ux * (radii[i] + (paddingTrim / 2)),
        a.dy + uy * (radii[i] + (paddingTrim / 2)),
      );
      final Offset end = Offset(
        b.dx - ux * (radii[i + 1] + (paddingTrim / 2)),
        b.dy - uy * (radii[i + 1] + (paddingTrim / 2)),
      );

      // Smooth cubic curve (feel free to replace with a straight line)
      final Offset mid = Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2);
      final Offset control1 = Offset(mid.dx, start.dy);
      final Offset control2 = Offset(mid.dx, end.dy);

      final Path path = Path()
        ..moveTo(start.dx, start.dy)
        ..cubicTo(control1.dx, control1.dy, control2.dx, control2.dy, end.dx, end.dy);

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ZigzagConnectorPainter old) {
    return old.centers != centers ||
        old.radii != radii ||
        old.currentStep != currentStep ||
        old.colors != colors;
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
    final centerY = 40.0; // Position of circles

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

      // Draw arrow
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
      const Color(0xFF6366F1),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFFEC4899),
    ];
    return colors[index];
  }

  @override
  bool shouldRepaint(covariant WorkflowLinePainter oldDelegate) {
    return oldDelegate.activeStage != activeStage ||
        oldDelegate.isDarkMode != isDarkMode;
  }
}


// ==================== CUSTOM PAINTER FOR CONNECTING LINES ====================
class CircularWorkflowPainter extends CustomPainter {
  final int activeStage;
  final bool isDarkMode;
  final int stages;

  CircularWorkflowPainter({
    required this.activeStage,
    required this.isDarkMode,
    required this.stages,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;

    // Background circle
    final bgPaint = Paint()
      ..color = isDarkMode
          ? const Color(0xFF334155).withOpacity(0.3)
          : const Color(0xFFE5E7EB).withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(center, radius, bgPaint);

    // Active progress arc
    final progressPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF6366F1),
          const Color(0xFF8B5CF6),
          const Color(0xFF10B981),
          const Color(0xFFF59E0B),
          const Color(0xFFEC4899),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final sweepAngle = (activeStage + 1) * (2 * math.pi / stages);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );

    // Draw connecting lines between stages
    for (int i = 0; i < stages; i++) {
      final angle = (i * 2 * math.pi / stages) - (math.pi / 2);
      final nextAngle = ((i + 1) * 2 * math.pi / stages) - (math.pi / 2);

      final isPassed = activeStage > i;
      final isActive = activeStage == i;

      // Line from center to stage
      final linePaint = Paint()
        ..color = (isPassed || isActive)
            ? _getStageColor(i).withOpacity(0.4)
            : (isDarkMode
            ? const Color(0xFF334155).withOpacity(0.2)
            : const Color(0xFFE5E7EB).withOpacity(0.4))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      final stageX = center.dx + (radius * math.cos(angle));
      final stageY = center.dy + (radius *math. sin(angle));

      // Dashed line from center
      _drawDashedLine(
        canvas,
        center,
        Offset(stageX, stageY),
        linePaint,
      );

      // Draw arrow if active
      if (isPassed || isActive) {
        final arrowPaint = Paint()
          ..color = _getStageColor(i)
          ..style = PaintingStyle.fill;

        final arrowSize = 8.0;
        final arrowX = center.dx + ((radius - 30) * math.cos(angle));
        final arrowY = center.dy + ((radius - 30) *math. sin(angle));

        final arrowPath = Path()
          ..moveTo(arrowX, arrowY)
          ..lineTo(
            arrowX - arrowSize * math.cos(angle -math. pi / 6),
            arrowY - arrowSize *math. sin(angle - math.pi / 6),
          )
          ..lineTo(
            arrowX - arrowSize * math.cos(angle +math. pi / 6),
            arrowY - arrowSize * math.sin(angle + math.pi / 6),
          )
          ..close();

        canvas.drawPath(arrowPath, arrowPaint);
      }
    }

    // Pulsing glow effect for active stage
    final glowPaint = Paint()
      ..color = _getStageColor(activeStage).withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    final activeAngle = (activeStage * 2 * math.pi / stages) - (math.pi / 2);
    final glowX = center.dx + (radius * math.cos(activeAngle));
    final glowY = center.dy + (radius * math.sin(activeAngle));

    canvas.drawCircle(Offset(glowX, glowY), 35, glowPaint);
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashWidth = 5;
    const dashSpace = 5;
    final distance = (end - start).distance;
    final normalizedDistance = (end - start) / distance;

    var currentDistance = 0.0;
    while (currentDistance < distance) {
      final dashEnd = currentDistance + dashWidth;
      canvas.drawLine(
        start + normalizedDistance * currentDistance,
        start + normalizedDistance * (dashEnd > distance ? distance : dashEnd),
        paint,
      );
      currentDistance += dashWidth + dashSpace;
    }
  }

  Color _getStageColor(int index) {
    final colors = [
      const Color(0xFF6366F1),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFFEC4899),
      const Color(0xFF8B5CF6),
    ];
    return colors[index % colors.length];
  }

  @override
  bool shouldRepaint(covariant CircularWorkflowPainter oldDelegate) {
    return oldDelegate.activeStage != activeStage ||
        oldDelegate.isDarkMode != isDarkMode;
  }
}