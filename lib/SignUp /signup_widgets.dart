// lib/screens/signup_widgets.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignupWidgets {
  // ========== LEFT PANEL ==========
  static Widget leftPanel(BuildContext context) {
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
              const Color(0xFF667eea),
              const Color(0xFF764ba2),
              const Color(0xFF5b5a97),
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
                      Colors.black.withOpacity(0.55),
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
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      const Color(0xFF6366F1).withOpacity(0.75),
                      const Color(0xFF8B5CF6).withOpacity(0.65),
                      const Color(0xFFEC4899).withOpacity(0.55),
                    ],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topRight,
                    radius: 1.5,
                    colors: [
                      Colors.indigo.withOpacity(0.35),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.bottomLeft,
                    radius: 1.2,
                    colors: [Colors.blue.withOpacity(0.3), Colors.transparent],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.8,
                    colors: [
                      Colors.white.withOpacity(0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: CustomPaint(painter: EnhancedBackgroundPatternPainter()),
            ),
            _buildAnimatedBlobs(),
            _buildEnhancedFloatingParticles(),
            Positioned(
              top: -150,
              right: -80,
              child: Transform.rotate(
                angle: 0.3,
                child: Container(
                  width: 350,
                  height: 900,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.06),
                        Colors.transparent,
                        Colors.white.withOpacity(0.06),
                        Colors.transparent,
                        Colors.white.withOpacity(0.04),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -100,
              left: -60,
              child: Transform.rotate(
                angle: -0.2,
                child: Container(
                  width: 300,
                  height: 700,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue.withOpacity(0.05),
                        Colors.transparent,
                        Colors.indigo.withOpacity(0.05),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 45,
                  vertical: 20,
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final contentHeight = panelHeight - 32;

                    return SingleChildScrollView(
                      child: SizedBox(
                        height: contentHeight,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 30),
                            _buildLogoTitleCard(),
                            const SizedBox(height: 20),
                            _buildSecurityCard(),
                            const SizedBox(height: 25),
                            _buildStatsGrid(),
                            const SizedBox(height: 20),
                            _buildFeaturesSection(),
                            const SizedBox(height: 15),
                          ],
                        ),
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

  static Widget _buildLogoTitleCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.12),
            Colors.white.withOpacity(0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.05),
            blurRadius: 15,
            spreadRadius: -2,
            offset: const Offset(-3, -3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.25),
                  Colors.white.withOpacity(0.12),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [
                  Colors.white,
                  Colors.blue.shade100,
                  Colors.indigo.shade100,
                ],
              ).createShader(bounds),
              child: const Icon(
                Icons.work_outline_rounded,
                size: 38,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      Colors.white,
                      Colors.blue.shade50,
                      Colors.indigo.shade50,
                    ],
                  ).createShader(bounds),
                  child: Text(
                    'Maha Services',
                    style: GoogleFonts.poppins(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -1.2,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 15,
                          offset: const Offset(2, 2),
                        ),
                        Shadow(
                          color: Colors.blue.withOpacity(0.5),
                          blurRadius: 25,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 4,
                  width: 90,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue.shade300,
                        Colors.indigo.shade300,
                        Colors.pink.shade300,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.6),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildSecurityCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.18),
            Colors.white.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.28),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 18,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.green.withOpacity(0.15),
            blurRadius: 20,
            spreadRadius: -2,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Colors.green.shade300.withOpacity(0.6),
                  Colors.blue.shade300.withOpacity(0.6),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.4),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.verified_user_outlined,
              size: 22,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enterprise Grade Security',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Data encrypted & secure',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.92),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.green.withOpacity(0.3),
                  Colors.teal.withOpacity(0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  size: 14,
                  color: Colors.white.withOpacity(0.9),
                ),
                const SizedBox(width: 4),
                Text(
                  'Active',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.95),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 3,
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: 2.4,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(10),
      shrinkWrap: true,
      children: [
        _buildEnhancedStatCardSmall(
          icon: Icons.work_outline_rounded,
          label: 'Jobs Posted',
          value: '1,230',
          subtitle: '+12% this month',
          color: Colors.blue,
        ),
        _buildEnhancedStatCardSmall(
          icon: Icons.people_outline_rounded,
          label: 'Active Recruiters',
          value: '342',
          subtitle: 'Online now',
          color: Colors.green,
        ),
        _buildEnhancedStatCardSmall(
          icon: Icons.trending_up_rounded,
          label: 'Successful Hires',
          value: '5,410',
          subtitle: '+28% growth',
          color: Colors.orange,
        ),
      ],
    );
  }

  static Widget _buildEnhancedStatCardSmall({
    required IconData icon,
    required String label,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.12),
            Colors.white.withOpacity(0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.22), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 15,
            spreadRadius: -2,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color.withOpacity(0.4), color.withOpacity(0.2)],
              ),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.3), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Icon(icon, size: 22, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color.withOpacity(0.8),
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.5),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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

  static Widget _buildFeaturesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.amber.withOpacity(0.4),
                      Colors.orange.withOpacity(0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.auto_awesome,
                  size: 16,
                  color: Colors.white.withOpacity(0.95),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Platform Features',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withOpacity(0.95),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildFeatureRow(
            icon: Icons.speed_rounded,
            text: 'Lightning-fast profile creation',
          ),
          const SizedBox(height: 10),
          _buildFeatureRow(
            icon: Icons.psychology_rounded,
            text: 'AI-powered job matching',
          ),
          const SizedBox(height: 10),
          _buildFeatureRow(
            icon: Icons.workspace_premium_rounded,
            text: 'Premium employer connections',
          ),
        ],
      ),
    );
  }

  static Widget _buildFeatureRow({
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.08),
            Colors.white.withOpacity(0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.2),
                  Colors.white.withOpacity(0.1),
                ],
              ),
            ),
            child: Icon(icon, color: Colors.white.withOpacity(0.95), size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.95),
                fontSize: 13,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2,
              ),
            ),
          ),
          Icon(
            Icons.check_circle,
            size: 16,
            color: Colors.green.withOpacity(0.7),
          ),
        ],
      ),
    );
  }

  static Widget _buildAnimatedBlobs() {
    return Stack(
      children: [
        Positioned(
          top: -180,
          left: -120,
          child: Container(
            width: 450,
            height: 450,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.indigo.withOpacity(0.35),
                  Colors.indigo.withOpacity(0.15),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -120,
          right: -100,
          child: Container(
            width: 350,
            height: 350,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.blue.withOpacity(0.3),
                  Colors.blue.withOpacity(0.12),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 350,
          left: 30,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.pink.withOpacity(0.25),
                  Colors.pink.withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 100,
          right: 80,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Colors.cyan.withOpacity(0.2), Colors.transparent],
              ),
            ),
          ),
        ),
      ],
    );
  }

  static Widget _buildEnhancedFloatingParticles() {
    return Positioned.fill(
      child: Stack(
        children: List.generate(20, (index) {
          final random = Random();
          final size = random.nextDouble() * 8 + 2;
          final opacity = random.nextDouble() * 0.5 + 0.2;
          final isGlowing = random.nextBool();

          return Positioned(
            left: random.nextDouble() * 450,
            top: random.nextDouble() * 800,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isGlowing
                    ? RadialGradient(
                  colors: [
                    Colors.white.withOpacity(opacity),
                    Colors.white.withOpacity(opacity * 0.3),
                  ],
                )
                    : null,
                color: isGlowing ? null : Colors.white.withOpacity(opacity),
                boxShadow: isGlowing
                    ? [
                  BoxShadow(
                    color: Colors.white.withOpacity(opacity * 0.6),
                    blurRadius: 6,
                    spreadRadius: 2,
                  ),
                ]
                    : null,
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ========== CUSTOM PAINTER FOR BACKGROUND PATTERN ==========
class EnhancedBackgroundPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    for (var i = 0; i < size.width; i += 90) {
      for (var j = 0; j < size.height; j += 90) {
        paint.color = Colors.white.withOpacity(0.06);
        canvas.drawCircle(Offset(i.toDouble(), j.toDouble()), 35, paint);

        paint.color = Colors.white.withOpacity(0.03);
        canvas.drawCircle(Offset(i.toDouble(), j.toDouble()), 20, paint);
      }
    }

    for (var i = -size.height; i < size.width; i += 120) {
      paint.color = Colors.white.withOpacity(0.04);
      paint.strokeWidth = 1.5;
      canvas.drawLine(
        Offset(i.toDouble(), 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }

    paint.style = PaintingStyle.fill;
    for (var i = 0; i < size.width; i += 150) {
      for (var j = 0; j < size.height; j += 150) {
        paint.color = Colors.white.withOpacity(0.08);
        canvas.drawCircle(Offset(i.toDouble(), j.toDouble()), 2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class FieldWrapper extends StatelessWidget {
  final int flex;
  final Widget child;

  const FieldWrapper({required this.flex, required this.child});

  @override
  Widget build(BuildContext context) => child;
}