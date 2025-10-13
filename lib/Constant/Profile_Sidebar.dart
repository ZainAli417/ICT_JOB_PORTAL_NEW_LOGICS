// ProfileSidebar.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Screens/Job_Seeker/Profile_Provider.dart';
import 'CV_Generator.dart';

class ProfileSidebar extends StatelessWidget {
  final ProfileProvider provider;

  const ProfileSidebar({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    int filledCount = 0;
    const int totalRequired = 14;

    // Personal (4)
    if (provider.firstName.isNotEmpty) filledCount++;
    if (provider.lastName.isNotEmpty) filledCount++;
    if (provider.email.isNotEmpty) filledCount++;
    if (provider.phone.isNotEmpty) filledCount++;

    // Education: at least one entry
    if (provider.educationList.isNotEmpty) {
      filledCount += 4; // count as the four required fields
    }

    // Experience: at least one entry
    if (provider.experienceList.isNotEmpty) {
      filledCount += 4; // count as the four required fields
    }

    // Certifications: at least one entry
    if (provider.certificationsList.isNotEmpty) {
      filledCount += 2; // count as the two required fields
    }

    final double completeness = filledCount / totalRequired;
    final bool isComplete = completeness >= 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          elevation: 3,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text(
                    provider.firstName.isNotEmpty
                        ? provider.firstName[0].toUpperCase()
                        : 'J',
                    style: const TextStyle(
                        fontSize: 32,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  provider.firstName.trim().isEmpty &&
                      provider.lastName.trim().isEmpty
                      ? 'Job Seeker'
                      : '${provider.firstName} ${provider.lastName}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  provider.email.isNotEmpty ? provider.email : 'No email provided',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                // Disabled iOS-style button until completeness == 100%
                if (!isComplete)
                  CupertinoButton.filled(
                    onPressed: null,
                    borderRadius: BorderRadius.circular(8),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Text(
                      'Complete Profile to Download CV',
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (_) => const CVGeneratorDialog(),
                      );
                    },
                    icon: const Icon(Icons.picture_as_pdf, size: 18),
                    label: const Text(
                      'Download CV',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ButtonStyle(
                      backgroundColor:
                      WidgetStateProperty.all(Theme.of(context).primaryColor),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      elevation: WidgetStateProperty.all(4),
                      padding: WidgetStateProperty.all(
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Card(
          elevation: 2,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CV Completeness',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  borderRadius: BorderRadius.circular(25),
                  value: completeness,
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    completeness > 0.7
                        ? Colors.green
                        : (completeness > 0.4 ? Colors.orange : Colors.red),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${(completeness * 100).round()}% completed',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Card(
          elevation: 2,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Tips',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                _buildTipRow(
                  icon: Icons.check_circle_outline,
                  text: 'Include a professional photo for better recognition.',
                ),
                const SizedBox(height: 8),
                _buildTipRow(
                  icon: Icons.check_circle_outline,
                  text: 'Use strong action verbs in your experience descriptions.',
                ),
                const SizedBox(height: 8),
                _buildTipRow(
                  icon: Icons.check_circle_outline,
                  text: 'Add keywords from job listings to improve ATS compatibility.',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTipRow({required IconData icon, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade700),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.montserrat(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }
}
