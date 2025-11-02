// cv_generator.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// <-- Adjust this import path if your provider file is elsewhere -->
import '../Screens/Job_Seeker/JS_Profile/JS_Profile_Provider.dart';

class CVGeneratorButton extends StatelessWidget {
  const CVGeneratorButton({super.key});

  int computeTotalScore(ProfileProvider_NEW p) {
    // Segments: personal, education, experience, certifications, skills
    const int segments = 5;
    int filled = 0;

    final personalComplete = p.name.trim().isNotEmpty && p.personalSummary.trim().isNotEmpty;
    if (personalComplete) filled++;

    if (p.educationalProfile.isNotEmpty) filled++;
    if (p.professionalExperience.isNotEmpty) filled++;
    if (p.certifications.isNotEmpty) filled++;
    if (p.skillsList.isNotEmpty) filled++;

    final percent = (filled / segments * 100).round();
    return percent;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider_NEW>(
      builder: (context, provider, _) {
        final totalScore = computeTotalScore(provider);

        return SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor:
              totalScore >= 65 ? const Color(0xFF1E3A8A) : const Color(0xFF9CA3AF),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: totalScore >= 65
                ? () => showDialog(
              context: context,
              builder: (_) => CVPreviewDialog(provider: provider),
            )
                : null,
            icon: const FaIcon(FontAwesomeIcons.download, size: 18, color: Colors.white),
            label: Text(
              'Download CV',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  }
}

class CVPreviewDialog extends StatelessWidget {
  final ProfileProvider_NEW provider;
  const CVPreviewDialog({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900, maxHeight: 700),
        child: Column(
          children: [
            // Header with avatar & name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  // Circular avatar preview (in-app)
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: provider.profilePicUrl.isNotEmpty
                        ? NetworkImage(provider.profilePicUrl)
                        : null,
                    child: provider.profilePicUrl.isEmpty
                        ? Text(
                      _initials(provider.fullName),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          provider.fullName.isNotEmpty ? provider.fullName : 'Unnamed',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          // show first role or fallback to professionalProfileSummary preview
                          provider.professionalExperience.isNotEmpty
                              ? (provider.professionalExperience.first['role'] ?? '')
                              : (provider.professionalProfileSummary.isNotEmpty
                              ? provider.professionalProfileSummary
                              : ''),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // PDF preview area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: PdfPreview(
                  allowPrinting: true,
                  allowSharing: true,
                  maxPageWidth: 700,
                  canChangePageFormat: false,
                  build: (format) => _generatePdf(provider),
                ),
              ),
            ),

            // Footer with date and explicit download instruction (PdfPreview already has actions)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Text(
                    'Generated on ${DateFormat('yyyy-MM-dd').format(DateTime.now())}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // small helper
  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  /// Builds professional PDF. IMPORTANT: hides contact details in the contact area,
  /// replacing them with "Contact admin for this information".
  Future<Uint8List> _generatePdf(ProfileProvider_NEW p) async {
    final doc = pw.Document();

    // Load fonts (ensure pdf_google_fonts is in pubspec)
    final pw.Font regular = await PdfGoogleFonts.openSansRegular();
    final pw.Font bold = await PdfGoogleFonts.openSansBold();

    // Fetch avatar as pw.ImageProvider for PDF usage
    pw.ImageProvider? avatarImage;
    if (p.profilePicUrl.isNotEmpty) {
      try {
        // networkImage (from printing) returns a pw.ImageProvider suitable for pw.Image
        avatarImage = await networkImage(p.profilePicUrl);
      } catch (_) {
        avatarImage = null;
      }
    }

    // Helper to render education entries with flexible fields
    List<pw.Widget> _buildEducation() {
      final List<pw.Widget> widgets = [];
      for (final e in p.educationalProfile) {
        final school = (e['institutionName'] ?? e['school'] ?? '').toString();
        final degree = (e['marksOrCgpa'] ?? e['degree'] ?? '').toString();
        final field = (e['majorSubjects'] ?? e['fieldOfStudy'] ?? '').toString();
        final start = (e['eduStart'] ?? '').toString();
        final end = (e['eduEnd'] ?? e['duration'] ?? '').toString();

        widgets.add(pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                pw.Text('$degree${field.isNotEmpty ? ' — $field' : ''}',
                    style: pw.TextStyle(font: bold, fontSize: 12)),
                pw.Text(
                    start.isNotEmpty || end.isNotEmpty
                        ? '$start${start.isNotEmpty && end.isNotEmpty ? ' - ' : ''}$end'
                        : '',
                    style: pw.TextStyle(font: regular, fontSize: 10)),
              ]),
              if (school.isNotEmpty)
                pw.Text(school, style: pw.TextStyle(font: regular, fontSize: 11)),
              pw.SizedBox(height: 6),
            ]));
      }
      if (widgets.isEmpty) {
      widgets.add(pw.Text('No education entries provided', style: pw.TextStyle(font: regular, fontSize: 11)));
      }
      return widgets;
    }

    List<pw.Widget> _buildExperience() {
      final List<pw.Widget> widgets = [];
      for (final exp in p.professionalExperience) {
        final role = (exp['role'] ?? exp['title'] ?? '').toString();
        final company = (exp['company'] ?? '').toString();
        final start = (exp['expStart'] ?? '').toString();
        final end = (exp['expEnd'] ?? '').toString();
        final text = (exp['text'] ?? exp['expDescription'] ?? '').toString();

        widgets.add(pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Text('$role at $company', style: pw.TextStyle(font: bold, fontSize: 12)),
          pw.Text(
              (start.isNotEmpty || end.isNotEmpty)
                  ? '($start${start.isNotEmpty && end.isNotEmpty ? ' – ' : ''}$end)'
                  : '',
              style: pw.TextStyle(font: regular, fontSize: 10)),
          if (text.isNotEmpty)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 4, bottom: 6),
              child: pw.Text(text, style: pw.TextStyle(font: regular, fontSize: 11), textAlign: pw.TextAlign.justify),
            )
        ]));
      }
      if (widgets.isEmpty) {
        widgets.add(pw.Text('No professional experience listed', style: pw.TextStyle(font: regular, fontSize: 11)));
      }
      return widgets;
    }

    // Build the PDF page(s)
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 34, vertical: 26),
        build: (context) {
          return <pw.Widget>[
            // Header
            pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              // Left: name & title
              pw.Expanded(
                flex: 7,
                child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                  pw.Text(p.fullName.isNotEmpty ? p.fullName : 'Unnamed',
                      style: pw.TextStyle(font: bold, fontSize: 22)),
                  pw.SizedBox(height: 6),
                  pw.Text(
                    // prefer current role or professionalProfileSummary snippet
                    p.professionalExperience.isNotEmpty
                        ? (p.professionalExperience.first['role'] ?? '')
                        : (p.professionalProfileSummary.isNotEmpty ? p.professionalProfileSummary : ''),
                    style: pw.TextStyle(font: regular, fontSize: 11, color: PdfColors.grey700),
                  ),
                ]),
              ),
              // Right: avatar (PDF)
              if (avatarImage != null)
                pw.Container(
                  width: 72,
                  height: 72,
                  decoration: pw.BoxDecoration(shape: pw.BoxShape.circle),
                  child: pw.ClipOval(
                    child: pw.Image(avatarImage, fit: pw.BoxFit.cover),
                  ),
                )
              else
                pw.Container(
                  width: 72,
                  height: 72,
                  alignment: pw.Alignment.center,
                  decoration: pw.BoxDecoration(
                    shape: pw.BoxShape.circle,
                    color: PdfColors.grey300,
                  ),
                  child: pw.Text(_initialsForPdf(p.fullName), style: pw.TextStyle(font: bold, fontSize: 18)),
                ),
            ]),
            pw.SizedBox(height: 12),

            // Contact row: HIDDEN contact details, show admin message
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(vertical: 8),
              child: pw.Row(children: [
                pw.Text('Contact admin for this information', style: pw.TextStyle(font: regular, fontSize: 11)),
              ]),
            ),

            pw.SizedBox(height: 8),

            // Two-column layout: Left main content, Right sidebar
            pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              // Left column (main): Summary, Experience, Education
              pw.Expanded(
                flex: 7,
                child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                  // Summary
                  pw.Text('Professional Summary', style: pw.TextStyle(font: bold, fontSize: 14)),
                  pw.Divider(),
                  pw.SizedBox(height: 6),
                  pw.Text(
                      p.personalSummary.isNotEmpty
                          ? p.personalSummary
                          : (p.professionalProfileSummary.isNotEmpty ? p.professionalProfileSummary : 'No summary provided.'),
                      style: pw.TextStyle(font: regular, fontSize: 11),
                      textAlign: pw.TextAlign.justify),
                  pw.SizedBox(height: 14),

                  // Experience
                  pw.Text('Professional Experience', style: pw.TextStyle(font: bold, fontSize: 14)),
                  pw.Divider(),
                  pw.SizedBox(height: 6),
                  ..._buildExperience(),
                  pw.SizedBox(height: 10),

                  // Education
                  pw.Text('Education', style: pw.TextStyle(font: bold, fontSize: 14)),
                  pw.Divider(),
                  pw.SizedBox(height: 6),
                  ..._buildEducation(),
                ]),
              ),

              pw.SizedBox(width: 18),

              // Right column (sidebar): Skills, Certifications, Publications, Awards, References
              pw.Expanded(
                flex: 4,
                child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                  // Skills
                  pw.Container(
                    decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey300)),
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                      pw.Text('Skills', style: pw.TextStyle(font: bold, fontSize: 12)),
                      pw.SizedBox(height: 6),
                      if (p.skillsList.isNotEmpty)
                        pw.Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: p.skillsList
                              .map((s) => pw.Container(
                            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            decoration: pw.BoxDecoration(borderRadius: pw.BorderRadius.circular(6), color: PdfColors.grey100),
                            child: pw.Text(s, style: pw.TextStyle(font: regular, fontSize: 10)),
                          ))
                              .toList(),
                        )
                      else
                        pw.Text('No skills listed', style: pw.TextStyle(font: regular, fontSize: 10))
                    ]),
                  ),

                  pw.SizedBox(height: 10),

                  // Certifications
                  pw.Text('Certifications', style: pw.TextStyle(font: bold, fontSize: 12)),
                  pw.Divider(),
                  if (p.certifications.isNotEmpty)
                    pw.Column(children: p.certifications.map((c) => pw.Bullet(text: c.toString(), style: pw.TextStyle(font: regular, fontSize: 10))).toList())
                  else
                    pw.Text('No certifications listed', style: pw.TextStyle(font: regular, fontSize: 10)),

                  pw.SizedBox(height: 10),

                  // Publications
                  pw.Text('Publications', style: pw.TextStyle(font: bold, fontSize: 12)),
                  pw.Divider(),
                  if (p.publications.isNotEmpty)
                    pw.Column(children: p.publications.map((c) => pw.Bullet(text: c.toString(), style: pw.TextStyle(font: regular, fontSize: 10))).toList())
                  else
                    pw.Text('No publications listed', style: pw.TextStyle(font: regular, fontSize: 10)),

                  pw.SizedBox(height: 10),

                  // Awards & References
                  pw.Text('Awards', style: pw.TextStyle(font: bold, fontSize: 12)),
                  pw.Divider(),
                  if (p.awards.isNotEmpty)
                    pw.Column(children: p.awards.map((c) => pw.Bullet(text: c.toString(), style: pw.TextStyle(font: regular, fontSize: 10))).toList())
                  else
                    pw.Text('No awards listed', style: pw.TextStyle(font: regular, fontSize: 10)),

                  pw.SizedBox(height: 10),
                  pw.Text('References', style: pw.TextStyle(font: bold, fontSize: 12)),
                  pw.Divider(),
                  if (p.references.isNotEmpty)
                    pw.Column(children: p.references.map((c) => pw.Bullet(text: c.toString(), style: pw.TextStyle(font: regular, fontSize: 10))).toList())
                  else
                    pw.Text('No references listed', style: pw.TextStyle(font: regular, fontSize: 10)),
                ]),
              ),
            ]),

            // Footer - small generation timestamp
            pw.SizedBox(height: 18),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text('Generated on ${DateFormat('yyyy-MM-dd').format(DateTime.now())}',
                  style: pw.TextStyle(font: regular, fontSize: 9, color: PdfColors.grey600)),
            ),
          ];
        },
      ),
    );

    return doc.save();
  }

  // Small initials helper for PDF fallback avatar
  String _initialsForPdf(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
}
