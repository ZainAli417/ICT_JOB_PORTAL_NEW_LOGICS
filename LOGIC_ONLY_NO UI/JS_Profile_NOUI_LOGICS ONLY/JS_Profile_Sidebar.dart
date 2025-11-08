// sidebar_profile.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'JS_Profile_Provider.dart';

class SidebarProfile extends StatelessWidget {
  final ProfileProvider_NEW provider;
  const SidebarProfile({super.key, required this.provider});

  // Weighting (must sum to 100)
  static const int _wPersonal = 25;
  static const int _wEducation = 15;
  static const int _wProfessionalProfile = 15;
  static const int _wExperience = 20;
  static const int _wCertifications = 8;
  static const int _wPublications = 5;
  static const int _wAwards = 4;
  static const int _wReferences = 4;
  static const int _wDocuments = 4;

  int _scorePersonal() {
    // personal total = _wPersonal (25)
    // breakdown: name 8, email 6, contact 5, profilePic 3, skills 2, summary 1 = 25
    var s = 0;
    if (provider.name.trim().isNotEmpty) s += 8;
    if (provider.email.trim().isNotEmpty) s += 6;
    if (provider.contactNumber.trim().isNotEmpty) s += 5;
    if (provider.profilePicUrl.trim().isNotEmpty) s += 3;
    if (provider.skillsList.isNotEmpty) s += 2;
    if (provider.personalSummary.trim().isNotEmpty) s += 1;
    return s.clamp(0, _wPersonal);
  }

  int _scoreEducation() {
    // full points if at least one education entry
    return provider.educationalProfile.isNotEmpty ? _wEducation : 0;
  }

  int _scoreProfessionalProfile() {
    return provider.professionalProfileSummary.trim().isNotEmpty ? _wProfessionalProfile : 0;
  }

  int _scoreExperience() {
    return provider.professionalExperience.isNotEmpty ? _wExperience : 0;
  }

  int _scoreCertifications() {
    return provider.certifications.isNotEmpty ? _wCertifications : 0;
  }

  int _scorePublications() {
    return provider.publications.isNotEmpty ? _wPublications : 0;
  }

  int _scoreAwards() {
    return provider.awards.isNotEmpty ? _wAwards : 0;
  }

  int _scoreReferences() {
    return provider.references.isNotEmpty ? _wReferences : 0;
  }

  int _scoreDocuments() {
    return provider.documents.isNotEmpty ? _wDocuments : 0;
  }

  int computeTotalScore() {
    final s = _scorePersonal() +
        _scoreEducation() +
        _scoreProfessionalProfile() +
        _scoreExperience() +
        _scoreCertifications() +
        _scorePublications() +
        _scoreAwards() +
        _scoreReferences() +
        _scoreDocuments();
    return s.clamp(0, 100);
  }

  String _displayName() {
    if (provider.name.trim().isNotEmpty) return provider.name.trim();
    // fallback to email prefix
    if (provider.email.trim().isNotEmpty) {
      final parts = provider.email.split('@');
      return parts.isNotEmpty ? parts.first : 'Job Seeker';
    }
    return 'Job Seeker';
  }

  String _initials() {
    final name = provider.name.trim();
    if (name.isEmpty) {
      if (provider.email.isNotEmpty) return provider.email[0].toUpperCase();
      return 'J';
    }
    final parts = name.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final totalScore = computeTotalScore();
    final percent = (totalScore / 100).clamp(0.0, 1.0);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Scrollbar(
            thumbVisibility: true,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header: avatar + name + contact
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 34,
                        backgroundColor: Colors.blue.shade700,
                        backgroundImage: provider.profilePicUrl.isNotEmpty ? NetworkImage(provider.profilePicUrl) as ImageProvider : null,
                        child: provider.profilePicUrl.isEmpty
                            ? Text(_initials(), style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w700))
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_displayName(), style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, fontSize: 16)),
                            const SizedBox(height: 4),
                            Text(provider.email.isNotEmpty ? provider.email : 'No email', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
                            const SizedBox(height: 4),
                            Text(provider.contactNumber.isNotEmpty ? provider.contactNumber : 'No contact', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Score card
                  Card(
                    color: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('CV Completeness', style: GoogleFonts.montserrat(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: percent,
                            minHeight: 10,
                            backgroundColor:                                                     Color(0xff5C738A)
                        ,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              totalScore >= 70 ? Colors.green : (totalScore >= 40 ? Colors.orange : Colors.red),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('$totalScore%', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                              Text(totalScore >= 70 ? 'Good' : (totalScore >= 40 ? 'Partial' : 'Needs work'),
                                  style: GoogleFonts.inter(color: Colors.grey.shade700, fontSize: 12))
                            ],
                          ),
                          const SizedBox(height: 10),
                          // breakdown rows
                          _breakdownRow('Personal', _scorePersonal(), _wPersonal),
                          _breakdownRow('Education', _scoreEducation(), _wEducation),
                          _breakdownRow('Profile summary', _scoreProfessionalProfile(), _wProfessionalProfile),
                          _breakdownRow('Experience', _scoreExperience(), _wExperience),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // small stats (badges)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _statPill(Icons.school, provider.educationalProfile.length.toString(), 'Education'),
                      _statPill(Icons.work, provider.professionalExperience.length.toString(), 'Experience'),
                      _statPill(Icons.badge, provider.certifications.length.toString(), 'Certs'),
                      _statPill(Icons.article, provider.publications.length.toString(), 'Pubs'),
                      _statPill(Icons.emoji_events, provider.awards.length.toString(), 'Awards'),
                      _statPill(Icons.group, provider.references.length.toString(), 'Refs'),
                      _statPill(Icons.upload_file, provider.documents.length.toString(), 'Docs'),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Buttons: Download CV + Reload
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: totalScore >= 10 // allow small threshold, you can change
                              ? () => context.go('/download-cv')
                              : null,
                          icon: const Icon(Icons.picture_as_pdf),
                          label: const Text('Download CV'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        tooltip: 'Reload profile',
                        onPressed: () => provider.forceReload(),
                        icon: const Icon(Icons.refresh),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Tips card
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tips & Tricks', style: GoogleFonts.montserrat(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 8),
                          _tip('Use a professional photo — it improves visibility.'),
                          _tip('Write a short professional summary (2–3 lines).'),
                          _tip('Add at least one education and one experience entry.'),
                          _tip('List 5–10 relevant skills for ATS matching.'),
                          _tip('Upload key documents (certs, transcripts) under Documents.'),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Quick details list
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Quick Details', style: GoogleFonts.montserrat(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 8),
                          _detailRow('Name', _displayName()),
                          _detailRow('Email', provider.email.isNotEmpty ? provider.email : '—'),
                          _detailRow('Contact', provider.contactNumber.isNotEmpty ? provider.contactNumber : '—'),
                          _detailRow('Nationality', provider.nationality.isNotEmpty ? provider.nationality : '—'),
                          _detailRow('DOB', provider.dob.isNotEmpty ? provider.dob : '—'),
                          if (provider.personalSummary.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text('Summary', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            Text(provider.personalSummary, maxLines: 4, overflow: TextOverflow.ellipsis),
                          ]
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Documents quick list (if any)
                  if (provider.documents.isNotEmpty)
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Uploaded Documents', style: GoogleFonts.montserrat(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 8),
                            ...provider.documents.asMap().entries.map((e) {
                              final idx = e.key;
                              final doc = e.value;
                              final name = doc['name']?.toString() ?? 'Document';
                              final url = doc['url']?.toString() ?? '';
                              final contentType = doc['contentType']?.toString() ?? '';
                              return ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(Icons.insert_drive_file, size: 22),
                                title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
                                subtitle: Text(contentType, style: const TextStyle(fontSize: 11)),
                                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                                  IconButton(
                                    icon: const Icon(Icons.open_in_new, size: 18),
                                    onPressed: url.isNotEmpty ? () {
                                      // open in new tab on web - use go_router or url_launcher in real app
                                      // here we'll just call context.go to a placeholder route if you have one
                                      // otherwise nothing to avoid adding url_launcher dependency
                                    } : null,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, size: 18),
                                    onPressed: () {
                                      provider.removeDocumentAt(idx);
                                      provider.saveDocumentsList();
                                    },
                                  ),
                                ]),
                              );
                            })
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _breakdownRow(String label, int got, int max) {
    final pct = max == 0 ? 0.0 : (got / max);
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: GoogleFonts.inter(fontSize: 13))),
          const SizedBox(width: 8),
          SizedBox(
            width: 110,
            child: LinearProgressIndicator(value: pct, minHeight: 6, backgroundColor: Colors.grey.shade200),
          ),
          const SizedBox(width: 8),
          Text('$got/$max', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade700)),
        ],
      ),
    );
  }

  Widget _statPill(IconData icon, String value, String label) {
    return Chip(
      labelPadding: const EdgeInsets.symmetric(horizontal: 8),
      backgroundColor: Colors.grey.shade50,
      avatar: Icon(icon, size: 16, color: Colors.grey.shade700),
      label: Text('$label: $value', style: GoogleFonts.inter(fontSize: 12)),
    );
  }

  Widget _tip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_outline, size: 16, color: Colors.grey.shade700),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade700))),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(children: [
        Expanded(child: Text(label, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade600))),
        const SizedBox(width: 8),
        Flexible(child: Text(value, textAlign: TextAlign.right, style: GoogleFonts.inter(fontSize: 12))),
      ]),
    );
  }
}
