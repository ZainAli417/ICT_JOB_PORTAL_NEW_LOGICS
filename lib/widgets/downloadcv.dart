// lib/utils/downloadcv.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:http/http.dart' as http;

import '../Screens/Recruiter/LIst_of_Applicants_provider.dart';

// Import your ApplicantRecord class path

/// Generate and download/share a professional A4 CV for the given applicant.
/// If [applicant] is null, this will try to read profile from Firestore using [userId].
Future<void> downloadCvForUser(BuildContext context, String userId, {ApplicantRecord? applicant}) async {
  final firestore = FirebaseFirestore.instance;

  try {
    // If no applicant object passed, fetch job_seeker/{uid} and user_profile
    Map<String, dynamic> acct = {};
    Map<String, dynamic> prof = {};
    if (applicant == null) {
      final doc = await firestore.collection('job_seeker').doc(userId).get();
      if (!doc.exists) throw Exception('User profile not found for $userId');
      final data = doc.data()!;

      // Your mapping (adjust if your doc structure differs)
      acct = Map<String, dynamic>.from(data['user_data'] ?? {});
      prof = Map<String, dynamic>.from(data['user_profile'] ?? {});
    } else {
      acct = Map<String, dynamic>.from(applicant.profileSnapshot['user_account_data'] ?? {});
      prof = Map<String, dynamic>.from(applicant.profileSnapshot['user_profile_section'] ?? {});
    }

    final name = (acct['name'] ?? 'Candidate').toString();
    final email = (acct['email'] ?? '').toString();
    final phone = (acct['phone'] ?? '').toString();
    final nationality = (acct['nationality'] ?? '').toString();
    final pictureUrl = (acct['picture_url'] ?? prof['picture_url'] ?? '').toString();

    // Helper getters for sections
    final summary = (prof['bio'] ?? '').toString();
    final education = prof['education'];
    final experiences = prof['experiences'] is List ? List.from(prof['experiences']) : <dynamic>[];
    final skills = prof['skills'] is List ? (prof['skills'] as List).map((e) => e.toString()).toList() : <String>[];
    final certifications = prof['certifications'] is List ? (prof['certifications'] as List).map((e) => e.toString()).toList() : <String>[];
    final references = prof['references'] is List ? List.from(prof['references']) : <dynamic>[];
    final cvUrl = prof['cv_url']?.toString() ?? '';

    // Build PDF document
    final doc = pw.Document();

    // Load fonts (Poppins via pdf_google_fonts - fallback to built-in)
    final ttfRegular = await PdfGoogleFonts.poppinsRegular();
    final ttfBold = await PdfGoogleFonts.poppinsBold();

    // Optionally fetch profile image
    pw.MemoryImage? profileImage;
    if (pictureUrl.isNotEmpty) {
      try {
        final resp = await http.get(Uri.parse(pictureUrl));
        if (resp.statusCode == 200) profileImage = pw.MemoryImage(resp.bodyBytes);
      } catch (_) {
        profileImage = null;
      }
    }

    // A4 layout
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  // Left: Name & contact
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(name,
                            style: pw.TextStyle(font: ttfBold, fontSize: 22, color: PdfColors.blue900)),
                        pw.SizedBox(height: 6),
                        pw.Row(
                          children: [
                            if (email.isNotEmpty) pw.Text(email, style: pw.TextStyle(font: ttfRegular, fontSize: 10)),
                            if (email.isNotEmpty) pw.SizedBox(width: 12),
                            if (phone.isNotEmpty) pw.Text(phone, style: pw.TextStyle(font: ttfRegular, fontSize: 10)),
                            if (phone.isNotEmpty) pw.SizedBox(width: 12),
                            if (nationality.isNotEmpty) pw.Text(nationality, style: pw.TextStyle(font: ttfRegular, fontSize: 10)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Right: Profile image
                  if (profileImage != null)
                    pw.Container(
                      width: 72,
                      height: 72,
                      decoration: pw.BoxDecoration(borderRadius: pw.BorderRadius.circular(8)),
                      child: pw.ClipRRect(
                        horizontalRadius: 8,
                        verticalRadius: 8,
                        child: pw.Image(profileImage, fit: pw.BoxFit.cover),
                      ),
                    ),
                ],
              ),

              pw.SizedBox(height: 18),

              // Two-column main content: left (summary, experiences) right (education, skills)
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Left column - Summary & Experience
                  pw.Expanded(
                    flex: 2,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Summary
                        if (summary.isNotEmpty) ...[
                          pw.Text('Summary', style: pw.TextStyle(font: ttfBold, fontSize: 14, color: PdfColors.blue800)),
                          pw.SizedBox(height: 6),
                          pw.Text(summary, style: pw.TextStyle(font: ttfRegular, fontSize: 11, height: 1.3)),
                          pw.SizedBox(height: 10),
                        ],

                        // Experiences
                        pw.Text('Experience', style: pw.TextStyle(font: ttfBold, fontSize: 14, color: PdfColors.blue800)),
                        pw.SizedBox(height: 6),
                        if (experiences.isNotEmpty)
                          pw.Column(
                            children: experiences.map<pw.Widget>((exp) {
                              final item = exp is Map ? Map<String, dynamic>.from(exp) : <String, dynamic>{};
                              final role = item['role'] ?? item['title'] ?? '';
                              final company = item['company'] ?? item['employer'] ?? '';
                              final from = item['from'] ?? '';
                              final to = item['to'] ?? 'Present';
                              final desc = item['description'] ?? item['summary'] ?? '';
                              return pw.Container(
                                margin: const pw.EdgeInsets.only(bottom: 8),
                                child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                                  pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                                    pw.Expanded(child: pw.Text('${role.toString()}  •  ${company.toString()}', style: pw.TextStyle(font: ttfBold, fontSize: 11))),
                                    pw.Text('$from - $to', style: pw.TextStyle(font: ttfRegular, fontSize: 9, color: PdfColors.grey600)),
                                  ]),
                                  if (desc.toString().isNotEmpty) pw.SizedBox(height: 4),
                                  if (desc.toString().isNotEmpty) pw.Text(desc.toString(), style: pw.TextStyle(font: ttfRegular, fontSize: 10, color: PdfColors.grey900)),
                                ]),
                              );
                            }).toList(),
                          )
                        else
                          pw.Text('No experience listed', style: pw.TextStyle(font: ttfRegular, fontSize: 11, color: PdfColors.grey700)),
                      ],
                    ),
                  ),

                  pw.SizedBox(width: 16),

                  // Right column - Education, Skills, Certifications, References
                  pw.Expanded(
                    flex: 1,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Education
                        pw.Text('Education', style: pw.TextStyle(font: ttfBold, fontSize: 14, color: PdfColors.blue800)),
                        pw.SizedBox(height: 6),
                        if (education != null)
                          if (education is Map)
                            pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                              pw.Text(education['degree']?.toString() ?? '-', style: pw.TextStyle(font: ttfRegular, fontSize: 11)),
                              pw.SizedBox(height: 4),
                              pw.Text(education['university']?.toString() ?? '-', style: pw.TextStyle(font: ttfRegular, fontSize: 10, color: PdfColors.grey700)),
                            ])
                          else
                            pw.Text(education.toString(), style: pw.TextStyle(font: ttfRegular, fontSize: 11))
                        else
                          pw.Text('Not specified', style: pw.TextStyle(font: ttfRegular, fontSize: 11, color: PdfColors.grey700)),

                        pw.SizedBox(height: 12),

                        // Skills
                        pw.Text('Skills', style: pw.TextStyle(font: ttfBold, fontSize: 14, color: PdfColors.blue800)),
                        pw.SizedBox(height: 6),
                        if (skills.isNotEmpty)
                          pw.Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: skills.map((s) => pw.Container(padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4), decoration: pw.BoxDecoration(color: PdfColors.grey200, borderRadius: pw.BorderRadius.circular(6)), child: pw.Text(s, style: pw.TextStyle(font: ttfRegular, fontSize: 9)))).toList(),
                          )
                        else
                          pw.Text('—', style: pw.TextStyle(font: ttfRegular, fontSize: 11, color: PdfColors.grey700)),

                        pw.SizedBox(height: 12),

                        // Certifications
                        pw.Text('Certifications', style: pw.TextStyle(font: ttfBold, fontSize: 14, color: PdfColors.blue800)),
                        pw.SizedBox(height: 6),
                        if (certifications.isNotEmpty)
                          pw.Column(children: certifications.map((c) => pw.Text('• ${c.toString()}', style: pw.TextStyle(font: ttfRegular, fontSize: 10))).toList())
                        else
                          pw.Text('—', style: pw.TextStyle(font: ttfRegular, fontSize: 11, color: PdfColors.grey700)),

                        pw.SizedBox(height: 12),

                        // References (brief)
                        pw.Text('References', style: pw.TextStyle(font: ttfBold, fontSize: 14, color: PdfColors.blue800)),
                        pw.SizedBox(height: 6),
                        if (references.isNotEmpty)
                          pw.Column(children: references.take(3).map((r) {
                            final m = r is Map ? Map<String, dynamic>.from(r) : {'text': r.toString()};
                            return pw.Text('- ${m['name'] ?? m['text'] ?? ''} ${m['contact'] ?? ''}', style: pw.TextStyle(font: ttfRegular, fontSize: 10));
                          }).toList())
                        else
                          pw.Text('Available on request', style: pw.TextStyle(font: ttfRegular, fontSize: 11, color: PdfColors.grey700)),
                      ],
                    ),
                  ),
                ],
              ),

              pw.Spacer(),

              // Footer small note
              pw.Divider(),
              pw.SizedBox(height: 6),
              pw.Text('Generated by YourApp • ${DateTime.now().toLocal().toString().split(' ').first}', style: pw.TextStyle(font: ttfRegular, fontSize: 9, color: PdfColors.grey600)),
            ],
          );
        },
      ),
    );

    // Get bytes
    final pdfBytes = await doc.save();

    // Give user the PDF via share / download dialog
    final filenameSafe = name.replaceAll(RegExp(r'[^A-Za-z0-9_\-]'), '_');
    final filename = 'CV_${filenameSafe}.pdf';

    // Use Printing.sharePdf, works across mobile/web/desktop: triggers share/save/print UI.
    await Printing.sharePdf(bytes: pdfBytes, filename: filename);
    // Optionally, you can use Printing.layoutPdf(...) if you want to preview print dialog:
    // await Printing.layoutPdf(onLayout: (_) => pdfBytes);
  } catch (e, st) {
    debugPrint('CV generation/download failed: $e\n$st');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to generate CV: $e')));
  }
}
