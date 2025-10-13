// cv_generator.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For rootBundle
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../Screens/Job_Seeker/Profile_Provider.dart';

class CVGeneratorDialog extends StatelessWidget {
  const CVGeneratorDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Consumer<ProfileProvider>(
            builder: (context, provider, _) {
              final bool personalComplete = provider.firstName.isNotEmpty &&
                  provider.lastName.isNotEmpty &&
                  provider.email.isNotEmpty &&
                  provider.phone.isNotEmpty &&
                  provider.summary.isNotEmpty &&
                  provider.current_job.isNotEmpty;
              final bool educationComplete = provider.educationList.isNotEmpty;
              final bool experienceComplete =
                  provider.experienceList.isNotEmpty;
              final bool certificationsComplete =
                  provider.certificationsList.isNotEmpty;
              final bool skillsComplete = provider.skillsList.isNotEmpty;
              final bool isComplete = personalComplete &&
                  educationComplete &&
                  experienceComplete &&
                  certificationsComplete &&
                  skillsComplete;

              double completenessPercent = 0;
              const int segments = 5;
              int filledSegments = 0;
              if (personalComplete) filledSegments++;
              if (educationComplete) filledSegments++;
              if (experienceComplete) filledSegments++;
              if (certificationsComplete) filledSegments++;
              if (skillsComplete) filledSegments++;
              completenessPercent = filledSegments / segments;

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Generate Your CV',
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Profile Completion: ${(completenessPercent * 100).round()}%',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: completenessPercent,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        completenessPercent > 0.7
                            ? Colors.green
                            : (completenessPercent > 0.4
                            ? Colors.orange
                            : Colors.red),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isComplete
                        ? 'Tap below to download your PDF CV.'
                        : 'Complete all sections before generating the CV.',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: isComplete ? Colors.black87 : Colors.redAccent,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: isComplete
                        ? () async {
                      final Uint8List pdfData = await _buildPdf(provider);
                      await Printing.layoutPdf(
                        onLayout: (format) async => pdfData,
                      );
                      Navigator.of(context).pop();
                    }
                        : null,
                    icon: const Icon(Icons.picture_as_pdf, size: 18),
                    label: const Text('Download CV'),
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.resolveWith(
                            (states) {
                          if (!isComplete) return Colors.grey;
                          return Theme.of(context).primaryColor;
                        },
                      ),
                      foregroundColor: WidgetStateProperty.all(Colors.white),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      elevation: WidgetStateProperty.all(4),
                      padding: WidgetStateProperty.all(
                        const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  static Future<Uint8List> _buildPdf(ProfileProvider p) async {
    // Load Open Sans for text (ATS‐friendly, Unicode)
    final pw.Font regular = await PdfGoogleFonts.openSansRegular();
    final pw.Font bold = await PdfGoogleFonts.openSansBold();

    // Load MaterialIcons TTF from assets for icon glyphs
    final fontData =
    await rootBundle.load('images/MaterialIcons-Regular.ttf');
    final pw.Font iconFont = pw.Font.ttf(fontData);

    // MaterialIcons code points
    const emailCode = 0xe0be;      // “email” glyph
    const phoneCode = 0xe0b0;      // “phone” glyph
    const locationCode = 0xe55f;   // “place” glyph

    final pw.Document doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        build: (pw.Context context) {
          return [
            // ------- Header -------
            pw.Center(
              child: pw.Text(
                '${p.firstName} ${p.lastName} (${p.current_job})',
                style: pw.TextStyle(font: bold, fontSize: 24),
              ),
            ),
            pw.SizedBox(height: 8),

            // ------- Contact Info Row with MaterialIcons -------
            pw.Center(
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  // Email icon + address
                  pw.Text(
                    String.fromCharCode(emailCode),
                    style: pw.TextStyle(font: iconFont, fontSize: 12),
                  ),
                  pw.SizedBox(width: 4),
                  pw.Text(p.email,
                      style: pw.TextStyle(font: regular, fontSize: 11)),

                  pw.SizedBox(width: 12),

                  // Phone icon + number
                  pw.Text(
                    String.fromCharCode(phoneCode),
                    style: pw.TextStyle(font: iconFont, fontSize: 12),
                  ),
                  pw.SizedBox(width: 4),
                  pw.Text(p.phone,
                      style: pw.TextStyle(font: regular, fontSize: 11)),

                  pw.SizedBox(width: 12),

                  // Location icon + city/country
                  pw.Text(
                    String.fromCharCode(locationCode),
                    style: pw.TextStyle(font: iconFont, fontSize: 12),
                  ),
                  pw.SizedBox(width: 4),
                  pw.Text(p.location,
                      style: pw.TextStyle(font: regular, fontSize: 11)),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            // ------- Summary -------
            pw.Align(
              alignment: pw.Alignment.centerLeft,
              child: pw.Text(
                'Professional Summary',
                style: pw.TextStyle(font: bold, fontSize: 14),
              ),
            ),
            pw.Divider(),
            pw.SizedBox(height: 6),
            pw.Text(
              p.summary,
              style: pw.TextStyle(font: regular, fontSize: 11),
              textAlign: pw.TextAlign.justify,
            ),

            pw.SizedBox(height: 16),

            // ------- Education -------
            pw.Align(
              alignment: pw.Alignment.centerLeft,
              child: pw.Text(
                'Education',
                style: pw.TextStyle(font: bold, fontSize: 14),
              ),
            ),
            pw.Divider(),
            pw.SizedBox(height: 6),
            ...p.educationList.map((edu) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    '${edu['degree']} in ${edu['fieldOfStudy']}',
                    style: pw.TextStyle(font: bold, fontSize: 12),
                  ),
                  pw.Text(
                    '${edu['school']}   (${edu['eduStart']} – ${edu['eduEnd']})',
                    style: pw.TextStyle(font: regular, fontSize: 12),
                  ),
                  pw.SizedBox(height: 6),
                ],
              );
            }),

            pw.SizedBox(height: 16),

            // ------- Professional Experience -------
            pw.Align(
              alignment: pw.Alignment.centerLeft,
              child: pw.Text(
                'Professional Experience',
                style: pw.TextStyle(font: bold, fontSize: 14),
              ),
            ),
            pw.Divider(),
            pw.SizedBox(height: 6),
            ...p.experienceList.map((exp) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    '${exp['role']} at ${exp['company']}',
                    style: pw.TextStyle(font: bold, fontSize: 12),
                  ),
                  pw.Text(
                    '(${exp['expStart']} – ${exp['expEnd']})',
                    style: pw.TextStyle(font: regular, fontSize: 12),
                  ),
                  pw.Text(
                    exp['expDescription'] ?? '',
                    style: pw.TextStyle(
                      font: regular,
                      fontSize: 11,
                      fontStyle: pw.FontStyle.italic,
                    ),
                    textAlign: pw.TextAlign.justify,
                  ),
                  pw.SizedBox(height: 6),
                ],
              );
            }),

            pw.SizedBox(height: 16),

            // ------- Certifications -------
            pw.Align(
              alignment: pw.Alignment.centerLeft,
              child: pw.Text(
                'Certifications',
                style: pw.TextStyle(font: bold, fontSize: 14),
              ),
            ),
            pw.Divider(),
            pw.SizedBox(height: 6),
            ...p.certificationsList.map((cert) {
              return pw.Bullet(
                text:
                '${cert['certName']} — ${cert['certInstitution']} (${cert['certYear']})',
                style: pw.TextStyle(font: regular, fontSize: 12),
              );
            }),

            pw.SizedBox(height: 16),

            // ------- Skills & Interests (bulleted, inline wrap) -------
            pw.Align(
              alignment: pw.Alignment.centerLeft,
              child: pw.Text(
                'Skills & Interests',
                style: pw.TextStyle(font: bold, fontSize: 14),
              ),
            ),
            pw.Divider(),

            pw.SizedBox(height: 6),
            pw.Wrap(
              spacing: 12,
              runSpacing: 8,
              children: p.skillsList.map((skill) {
                return pw.Text(
                  '• $skill',
                  style: pw.TextStyle(font: regular, fontSize: 12),
                );
              }).toList(),
            ),

            pw.SizedBox(height: 24),

            // ------- Footer with generation date -------
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                'Generated on ${DateFormat('yyyy-MM-dd').format(DateTime.now())}',
                style:
                pw.TextStyle(font: regular, fontSize: 10, color: PdfColors.grey600),
              ),
            ),
          ];
        },
      ),
    );
    return doc.save();
  }
}
