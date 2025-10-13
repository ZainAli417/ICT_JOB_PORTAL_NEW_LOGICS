
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
class ProfessionalDefenseTagline extends StatefulWidget {
  const ProfessionalDefenseTagline({Key? key}) : super(key: key);

  @override
  State<ProfessionalDefenseTagline> createState() => _ProfessionalDefenseTaglineState();
}

class _ProfessionalDefenseTaglineState extends State<ProfessionalDefenseTagline>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final Color charcoalBlack = const Color(0xFF2C2C2C);
  final Color indigoShade900 = Colors.indigo.shade900;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main tagline
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        'WHERE',
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w300,
                          color: charcoalBlack.withOpacity(0.85),
                          letterSpacing: 1.2,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'TALENT',
                        style: GoogleFonts.inter(
                          fontSize: 54,
                          fontWeight: FontWeight.w800,
                          color: indigoShade900,
                          letterSpacing: -0.5,
                          height: 0.95,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        'MEETS',
                        style: GoogleFonts.inter(
                          fontSize: 25,
                          fontWeight: FontWeight.w300,
                          color: charcoalBlack.withOpacity(0.85),
                          letterSpacing: 1.2,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'OPPORTUNITY',
                        style: GoogleFonts.inter(
                          fontSize: 54,
                          fontWeight: FontWeight.w800,
                          color: charcoalBlack,
                          letterSpacing: -0.5,
                          height: 0.95,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Professional subtitle
                  Container(
                    padding: const EdgeInsets.only(left: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 80,
                          height: 3,
                          decoration: BoxDecoration(
                            color: indigoShade900,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'JOIN THE DEFENSE OF TOMORROW',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: charcoalBlack.withOpacity(0.8),
                            letterSpacing: 2.5,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Air Force Defense Systems • Elite Careers • National Security',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: charcoalBlack.withOpacity(0.65),
                            letterSpacing: 0.8,
                            height: 1.3,
                          ),
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
    );
  }
}