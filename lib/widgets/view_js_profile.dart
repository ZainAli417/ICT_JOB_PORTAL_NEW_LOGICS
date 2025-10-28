// lib/widgets/view_applicant_details.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Screens/Recruiter/LIst_of_Applicants_provider.dart';

class ViewApplicantDetails extends StatelessWidget {
  final ApplicantRecord applicant;
  const ViewApplicantDetails({Key? key, required this.applicant}) : super(key: key);

  Widget _hTitle(String t, Color color) => Row(children: [
    Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)), child: Icon(Icons.info_outline, size: 16, color: color)),
    const SizedBox(width: 8),
    Text(t, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700)),
  ]);

  Widget _row(String label, String value, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon ?? Icons.circle_outlined, size: 16, color: Colors.grey.shade700),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(value.isNotEmpty ? value : 'Not provided', style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[800])),
        ])),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final acct = Map<String, dynamic>.from(applicant.profileSnapshot['user_account_data'] ?? {});
    final prof = Map<String, dynamic>.from(applicant.profileSnapshot['user_profile_section'] ?? {});

    // missing mandatory check
    final mandatory = {
      'email': (applicant.email.isNotEmpty || acct['email'] != null),
      'phone': (applicant.phone.isNotEmpty || acct['phone'] != null),
      'nationality': (applicant.nationality.isNotEmpty || acct['nationality'] != null),
      'cv': (applicant.cvUrl.isNotEmpty || prof['cv_url'] != null),
      'dob': (applicant.dob.isNotEmpty || prof['dob'] != null),
    };
    final missingCount = mandatory.values.where((v) => !v).length;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 920, maxHeight: 700),
        child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
                children: [
            // Header
            Row(children: [
            CircleAvatar(radius: 30, backgroundColor: const Color(0xFF3B82F6), backgroundImage: applicant.pictureUrl.isNotEmpty ? NetworkImage(applicant.pictureUrl) : null, child: applicant.pictureUrl.isEmpty ? Text(applicant.name.isNotEmpty ? applicant.name[0] : 'U', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)) : null),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(applicant.name, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(applicant.email.isNotEmpty ? applicant.email : (acct['email']?.toString() ?? ''), style: GoogleFonts.poppins(fontSize: 13)),
            ])),
            Column(children: [
              if (missingCount > 0)
                Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(8)), child: Row(children: [Icon(Icons.warning_amber_rounded, size: 14, color: const Color(0xFFB91C1C)), const SizedBox(width: 6), Text('$missingCount missing', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFFB91C1C)))])),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () async {
                  if (applicant.cvUrl.isNotEmpty) {
                    /*try {
                      await downloadCvForUser(context, applicant.userId);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Download failed: $e')));
                    }

                     */
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('CV not available')));
                  }
                },
                icon: const Icon(Icons.download_outlined, size: 16),
                label: const Text('Download CV'),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
              ),
            ]),
            ]),

        const SizedBox(height: 12),

        // Body scroll area
        Expanded(
          child: SingleChildScrollView(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Personal
              _hTitle('Personal', const Color(0xFF334155)),
              const SizedBox(height: 8),
              _row('Full name', applicant.name, icon: Icons.person_outline),
              _row('Email', applicant.email.isNotEmpty ? applicant.email : (acct['email']?.toString() ?? ''), icon: Icons.email_outlined),
              _row('Phone', applicant.phone.isNotEmpty ? applicant.phone : (acct['phone']?.toString() ?? ''), icon: Icons.phone_outlined),
              _row('Nationality', applicant.nationality.isNotEmpty ? applicant.nationality : (acct['nationality']?.toString() ?? ''), icon: Icons.flag_outlined),
              _row('DOB', applicant.dob.isNotEmpty ? applicant.dob : (prof['dob']?.toString() ?? ''), icon: Icons.cake_outlined),
              _row('Father name', applicant.fatherName.isNotEmpty ? applicant.fatherName : (prof['father_name']?.toString() ?? ''), icon: Icons.person_add),
              const SizedBox(height: 12),

              // Education
              _hTitle('Education', const Color(0xFF10B981)),
              const SizedBox(height: 8),
              if (prof['educations'] != null)
                if (prof['educations'] is Map)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Degree: ${prof['educations']['degree'] ?? 'Not provided'}', style: GoogleFonts.poppins(fontSize: 13)),
                      const SizedBox(height: 6),
                      Text('University: ${prof['educations']['university'] ?? 'Not provided'}', style: GoogleFonts.poppins(fontSize: 13)),
                    ],
                  )
                else
                  Text(prof['educations']?.toString() ?? 'Not provided', style: GoogleFonts.poppins(fontSize: 13))
              else
                const Text('Not provided'),

              const SizedBox(height: 12),

              // Experiences (list)
              _hTitle('Experiences', const Color(0xFF0284C7)),
              const SizedBox(height: 8),
              if (applicant.experiences.isNotEmpty)
                Column(children: applicant.experiences.map((e) {
                  final company = e['company']?.toString() ?? e['employer']?.toString() ?? 'Unknown';
                  final role = e['role']?.toString() ?? e['title']?.toString() ?? 'Role';
                  final from = e['from']?.toString() ?? '';
                  final to = e['to']?.toString() ?? '';
                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.work_outline),
                    title: Text('$role @ $company', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
                    subtitle: Text('${from.isNotEmpty ? from : '—'}  •  ${to.isNotEmpty ? to : 'Present'}', style: GoogleFonts.poppins(fontSize: 12)),
                  );
                }).toList())
              else
                const Text('No experiences listed'),

              const SizedBox(height: 12),

              // Certifications
              _hTitle('Certifications', const Color(0xFF7C3AED)),
              const SizedBox(height: 8),
              if (applicant.certifications.isNotEmpty)
                Wrap(spacing: 8, runSpacing: 8, children: applicant.certifications.map((c) => Chip(label: Text(c))).toList())
              else if (prof['certifications'] is List && (prof['certifications'] as List).isNotEmpty)
                Wrap(spacing: 8, runSpacing: 8, children: (prof['certifications'] as List).map((c) => Chip(label: Text(c.toString()))).toList())
              else
                const Text('None listed'),

              const SizedBox(height: 12),

              // Skills
              _hTitle('Skills', const Color(0xFF0284C7)),
              const SizedBox(height: 8),
              if (applicant.skills.isNotEmpty)
                Wrap(spacing: 8, runSpacing: 8, children: applicant.skills.map((s) => Chip(label: Text(s))).toList())
              else if (prof['skills'] is List && (prof['skills'] as List).isNotEmpty)
                Wrap(spacing: 8, runSpacing: 8, children: (prof['skills'] as List).map((s) => Chip(label: Text(s.toString()))).toList())
              else
                const Text('None listed'),

              const SizedBox(height: 12),

              // References
              _hTitle('References', const Color(0xFF059669)),
              const SizedBox(height: 8),
              if (applicant.references.isNotEmpty)
                Column(children: applicant.references.map((r) {
                  final name = r['name']?.toString() ?? 'Name';
                  final contact = r['contact']?.toString() ?? r['phone']?.toString() ?? '';
                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.person_pin),
                    title: Text(name, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
                    subtitle: Text(contact, style: GoogleFonts.poppins(fontSize: 12)),
                  );
                }).toList())
              else if (prof['references'] is List && (prof['references'] as List).isNotEmpty)
                Column(children: (prof['references'] as List).map((r) {
                  final m = r is Map ? r : {'text': r.toString()};
                  final name = m['name']?.toString() ?? m['text']?.toString() ?? 'Reference';
                  final contact = m['contact']?.toString() ?? '';
                  return ListTile(dense: true, contentPadding: EdgeInsets.zero, leading: const Icon(Icons.person_pin), title: Text(name, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)), subtitle: Text(contact));
                }).toList())
              else
                const Text('No references provided'),

              const SizedBox(height: 18),
            ],
            ),

          ),

        )
          ],
        ),
      ),
    ),
    );
  }
}
