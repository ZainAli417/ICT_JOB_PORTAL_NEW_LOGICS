import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:job_portal/Screens/Recruiter/recruiter_Sidebar.dart';

import 'Recruiter_provider.dart';


class RecruiterDashboard extends StatefulWidget {
  const RecruiterDashboard({super.key});

  @override
  State<RecruiterDashboard> createState() => _RecruiterDashboardState();
}

class _RecruiterDashboardState extends State<RecruiterDashboard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))
      ..forward();
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
            CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Recruiter_MainLayout(
      activeIndex: 0,
      child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: Scaffold(
            backgroundColor: const Color(0xFFF8FAFC),
            appBar: _buildAppBar(context),
            body: ChangeNotifierProvider(
              create: (_) => RecruiterProvider2(),
              builder: (context, _) {
                final prov = Provider.of<RecruiterProvider2>(context);
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildSearchAndFilters(prov, isMobile),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 20),
                        child: prov.loading
                            ? _buildLoadingState()
                            : _buildCandidatesSection(prov, isMobile),
                      ),
                      _buildBottomActionBar(prov),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext c) => AppBar(
    elevation: 0,
    backgroundColor: Colors.white,
    title: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.people_alt, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 16),
        Text(
          'Candidates',
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
      ],
    ),
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(1),
      child: Container(
        height: 1,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
      ),
    ),
  );

  Widget _buildSearchAndFilters(RecruiterProvider2 prov, bool isMobile) {
    final natList = [
      'All',
      ...prov.nationalityOptions
          .where((s) => s.trim().isNotEmpty)
          .toList()
        ..sort((a, b) => a.compareTo(b))
    ];
    final sortOptions = ['None', 'Name A→Z', 'Name Z→A'];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100, width: 1),
        ),
      ),
      child: isMobile
          ? Column(
        // use SizedBox for spacing instead of non-existent `spacing` param
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSearchField(prov),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildNationalityDropdown(natList, prov)),
              const SizedBox(width: 12),
              Expanded(child: _buildSortDropdown(sortOptions, prov)),
            ],
          ),
          const SizedBox(height: 12),
          Align(alignment: Alignment.centerRight, child: _buildClearButton(prov)),
        ],
      )
          : Row(
        children: [
          Expanded(child: _buildSearchField(prov)),
          const SizedBox(width: 12),
          SizedBox(width: 240, child: _buildNationalityDropdown(natList, prov)),
          const SizedBox(width: 12),
          SizedBox(width: 180, child: _buildSortDropdown(sortOptions, prov)),
          const SizedBox(width: 12),
          _buildClearButton(prov),
        ],
      ),
    );
  }

  Widget _buildSearchField(RecruiterProvider2 prov) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 2,
            offset: const Offset(0, 1),
          )
        ],
      ),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (v) => prov.setSearch(v),
        style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
        decoration: InputDecoration(
          hintText: 'Search by name, email, phone, nationality...',
          hintStyle: GoogleFonts.poppins(color: Colors.grey.shade600),
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search_rounded,
              color: Colors.grey.shade600, size: 20),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildNationalityDropdown(
      List<String> natList, RecruiterProvider2 prov) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 2,
            offset: const Offset(0, 1),
          )
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: prov.selectedNationality == null ||
            (prov.selectedNationality?.isEmpty ?? true)
            ? 'All'
            : prov.selectedNationality,
        items: natList
            .map((n) => DropdownMenuItem(
          value: n,
          child: Text(n, style: GoogleFonts.poppins(fontSize: 13)),
        ))
            .toList(),
        onChanged: (v) {
          if (v == null || v == 'All') {
            prov.setNationalityFilter(null);
          } else {
            prov.setNationalityFilter(v);
          }
        },
        decoration: InputDecoration(
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          filled: true,
          fillColor: Colors.white,
          prefixIcon: Icon(Icons.public, size: 18, color: Colors.grey.shade600),
        ),
      ),
    );
  }

  Widget _buildSortDropdown(List<String> sortOptions, RecruiterProvider2 prov) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 2,
            offset: const Offset(0, 1),
          )
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: prov.sortOption,
        items: sortOptions
            .map((s) => DropdownMenuItem(
          value: s,
          child: Text(s, style: GoogleFonts.poppins(fontSize: 13)),
        ))
            .toList(),
        onChanged: (v) {
          if (v != null) prov.setSortOption(v);
        },
        decoration: InputDecoration(
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          filled: true,
          fillColor: Colors.white,
          prefixIcon:
          Icon(Icons.sort, size: 18, color: Colors.grey.shade600),
        ),
      ),
    );
  }

  Widget _buildClearButton(RecruiterProvider2 prov) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.red.shade100,
            blurRadius: 2,
            offset: const Offset(0, 1),
          )
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () => prov.clearSelection(),
        icon: const Icon(Icons.refresh_rounded, size: 18),
        label: Text('Clear', style: GoogleFonts.poppins(fontSize: 13)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade50,
          foregroundColor: Colors.red.shade700,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withOpacity(0.2),
                  blurRadius: 16,
                  spreadRadius: 4,
                )
              ],
            ),
            child: const CircularProgressIndicator(
              valueColor:
              AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading candidates...',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCandidatesSection(RecruiterProvider2 prov, bool isMobile) {
    final list = prov.searchQuery.isEmpty ? prov.candidates : prov.filtered;

    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person_search,
                  size: 48, color: Colors.blue.shade400),
            ),
            const SizedBox(height: 16),
            Text(
              'No candidates found',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        if (!isMobile) _buildTableHeader(),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, idx) => _buildCandidateCard(
            context,
            list[idx],
            prov,
            isMobile,
          ),
        ),
      ],
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      alignment: Alignment.centerLeft, // <-- ensure header content is left-aligned
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min, // <-- size to children so it sits at the left
          children: [
            SizedBox(width: 50, child: _headerText('Avatar')),
            const SizedBox(width: 12),
            SizedBox(width: 140, child: _headerText('Name')),
            const SizedBox(width: 12),
            SizedBox(width: 120, child: _headerText('Email')),
            const SizedBox(width: 12),
            SizedBox(width: 100, child: _headerText('Phone')),
            const SizedBox(width: 12),
            SizedBox(width: 100, child: _headerText('Nationality')),
            const SizedBox(width: 12),
            SizedBox(width: 100, child: _headerText('Actions')),
            const SizedBox(width: 12),
            SizedBox(width: 50, child: _headerText('Select')),
          ],
        ),
      ),
    );
  }

  Widget _headerText(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontWeight: FontWeight.w600,
        fontSize: 12,
        color: Colors.grey.shade700,
      ),
    );
  }
  Widget _buildCandidateCard(BuildContext context, Candidate candidate,
      RecruiterProvider2 prov, bool isMobile) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade100,
              blurRadius: 4,
              offset: const Offset(0, 1),
            )
          ],
        ),
        child: isMobile
            ? _buildMobileCandidateCard(context, candidate, prov)
            : SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: MediaQuery.of(context).size.width - 48,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: candidate.pictureUrl.isNotEmpty
                      ? NetworkImage(candidate.pictureUrl)
                  as ImageProvider
                      : null,
                  backgroundColor: const Color(0xFF6366F1).withOpacity(0.1),
                  child: candidate.pictureUrl.isEmpty
                      ? const Icon(Icons.person,
                      color: Color(0xFF6366F1), size: 20)
                      : null,
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 150,
                  child: _buildHighlightText(
                      candidate.name, prov.searchQuery),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 120,
                  child: _buildHighlightText(
                      candidate.email, prov.searchQuery),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 100,
                  child: _buildHighlightText(
                      candidate.phone, prov.searchQuery),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 100,
                  child: _buildHighlightText(
                      candidate.nationality, prov.searchQuery),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 100,
                  child: _buildViewDetailsButton(context, candidate, prov),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 50,
                  child: Checkbox(
                    value: prov.selectedUids.contains(candidate.uid),
                    onChanged: (v) =>
                        prov.toggleSelection(candidate.uid, value: v),
                    activeColor: const Color(0xFF6366F1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildMobileCandidateCard(BuildContext context, Candidate candidate,
      RecruiterProvider2 prov) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage:
              candidate.pictureUrl.isNotEmpty
                  ? NetworkImage(candidate.pictureUrl)
              as ImageProvider
                  : null,
              backgroundColor: const Color(0xFF6366F1).withOpacity(0.1),
              child: candidate.pictureUrl.isEmpty
                  ? const Icon(Icons.person,
                  color: Color(0xFF6366F1), size: 20)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHighlightText(candidate.name, prov.searchQuery),
                  const SizedBox(height: 4),
                  _buildHighlightText(candidate.email, prov.searchQuery),
                ],
              ),
            ),
            Checkbox(
              value: prov.selectedUids.contains(candidate.uid),
              onChanged: (v) =>
                  prov.toggleSelection(candidate.uid, value: v),
              activeColor: const Color(0xFF6366F1),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildMobileInfoChip(Icons.phone, candidate.phone),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMobileInfoChip(Icons.public, candidate.nationality),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _buildViewDetailsButton(context, candidate, prov),
      ],
    );
  }

  Widget _buildMobileInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade600),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewDetailsButton(BuildContext context, Candidate candidate,
      RecruiterProvider2 prov) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: TextButton.icon(
        onPressed: () async {
          final profile = await prov.fetchProfile(candidate.uid);
          if (context.mounted) {
            showDialog(
              context: context,
              builder: (_) => CandidateDetailsDialog(
                candidate: candidate,
                profile: profile,
              ),
            );
          }
        },
        icon: const Icon(Icons.visibility_outlined, size: 16),
        label: Text('View', style: GoogleFonts.poppins(fontSize: 12)),
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF6366F1),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
    );
  }

  Widget _buildHighlightText(String text, String query) {
    if (query.isEmpty) {
      return Text(
        text,
        style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    final lcText = text.toLowerCase();
    final lcQuery = query.toLowerCase();
    final spans = <TextSpan>[];
    int start = 0;

    while (true) {
      final idx = lcText.indexOf(lcQuery, start);
      if (idx < 0) {
        spans.add(TextSpan(text: text.substring(start)));
        break;
      }
      if (idx > start) spans.add(TextSpan(text: text.substring(start, idx)));
      spans.add(TextSpan(
        text: text.substring(idx, idx + lcQuery.length),
        style: const TextStyle(
          backgroundColor: Color(0xFFFCD34D),
          fontWeight: FontWeight.w700,
        ),
      ));
      start = idx + lcQuery.length;
    }

    return RichText(
      text: TextSpan(
        style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87),
        children: spans,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildBottomActionBar(RecruiterProvider2 prov) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF6366F1).withOpacity(0.3),
              ),
            ),
            child: Text(
              '${prov.selectedUids.length} selected',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6366F1),
              ),
            ),
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: prov.selectedUids.isEmpty ? null : () => _handleSendRequest(prov),
            icon: const Icon(Icons.send_rounded, size: 18),
            label: Text(
              'Send Request to Admin',
              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade300,
              padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 2,
            ),
          )
        ],
      ),
    );
  }

  Future<void> _handleSendRequest(RecruiterProvider2 prov) async {
    final requestId = await prov.sendSelectedCandidatesToAdmin(
        notes: 'Sent from dashboard');

    if (mounted) {
      if (requestId != null) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check_circle_outline,
                      color: Colors.green.shade700, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'Request Sent',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            content: Text(
              'Recruiter request created: $requestId',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Close',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF6366F1),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            ],
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.error_outline,
                      color: Colors.red.shade700, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'Error',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            content: Text(
              'Failed to send request or no candidates selected.',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Close',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF6366F1),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            ],
          ),
        );
      }
    }
  }
}

/// Candidate Details Dialog - Professional & Modern
class CandidateDetailsDialog extends StatelessWidget {
  final Candidate candidate;
  final Map<String, dynamic>? profile;

  const CandidateDetailsDialog({
    required this.candidate,
    required this.profile,
    super.key,
  });

  Widget _sectionTitle(String t) =>
      Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 12),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              t,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      );

  String _formatDob(dynamic dobRaw) {
    try {
      if (dobRaw == null) return '-';
      if (dobRaw is Timestamp) {
        final dt = dobRaw.toDate().toLocal();
        return DateFormat.yMMMMd().format(dt) + ' • ${_calculateAge(dt)}';
      }
      if (dobRaw is Map &&
          (dobRaw.containsKey('seconds') || dobRaw.containsKey('_seconds'))) {
        final seconds = (dobRaw['seconds'] ?? dobRaw['_seconds']) as int;
        final dt = DateTime.fromMillisecondsSinceEpoch(
            seconds * 1000, isUtc: true).toLocal();
        return DateFormat.yMMMMd().format(dt) + ' • ${_calculateAge(dt)}';
      }
      if (dobRaw is String) {
        final parsed = DateTime.tryParse(dobRaw);
        if (parsed != null) {
          final dt = parsed.toLocal();
          return DateFormat.yMMMMd().format(dt) + ' • ${_calculateAge(dt)}';
        }
        return dobRaw;
      }
      if (dobRaw is DateTime) {
        final dt = dobRaw.toLocal();
        return DateFormat.yMMMMd().format(dt) + ' • ${_calculateAge(dt)}';
      }
      return dobRaw.toString();
    } catch (_) {
      return dobRaw?.toString() ?? '-';
    }
  }

  String _calculateAge(DateTime dob) {
    final now = DateTime.now();
    int years = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) years--;
    return '$years yrs';
  }

  Widget _bulletRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.poppins(color: Colors.black87, fontSize: 14),
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bulletTextLine(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _listFrom(dynamic maybeList, {bool isExperience = false}) {
    if (maybeList == null) {
      return [Text('-', style: GoogleFonts.poppins())];
    }

    if (maybeList is Map<String, dynamic>) {
      return maybeList.entries
          .map((e) => _bulletRow(e.key, e.value?.toString() ?? '-'))
          .toList();
    }

    if (maybeList is List) {
      if (maybeList.isEmpty) {
        return [Text('-', style: GoogleFonts.poppins())];
      }
      return maybeList.map<Widget>((e) {
        if (e is Map<String, dynamic>) {
          if (isExperience) {
            final role = (e['role'] ?? e['title'] ?? e['position'])
                ?.toString() ?? '';
            final company = (e['company'] ?? e['organization'] ?? e['employer'])
                ?.toString() ?? '';
            final start = (e['start'] ?? e['from'])?.toString() ?? '';
            final end = (e['end'] ?? e['to'] ?? e['duration'])?.toString() ??
                '';
            final durationText = (start.isNotEmpty || end.isNotEmpty)
                ? '$start${start.isNotEmpty && end.isNotEmpty ? ' → ' : ''}$end'
                : '';
            final display = [
              if (role.isNotEmpty) role,
              if (company.isNotEmpty) 'at $company',
              if (durationText.isNotEmpty) '($durationText)'
            ].join(' ');
            return _bulletTextLine(display.isNotEmpty ? display : e.toString());
          } else {
            final title = (e['degree'] ?? e['title'] ?? e['position'] ??
                e['name'])?.toString();
            final sub = [
              e['institute'] ?? e['company'] ?? e['organization'],
              e['start'] ?? e['from'],
              e['end'] ?? e['to'],
              e['year']
            ].where((x) => x != null).map((x) => x.toString()).toList().join(
                ' • ');
            final display = (title != null && title.isNotEmpty)
                ? '$title${sub.isNotEmpty ? ' — $sub' : ''}'
                : e.toString();
            return _bulletTextLine(display);
          }
        }
        return _bulletTextLine(e.toString());
      }).toList();
    }

    return [Text(maybeList.toString(), style: GoogleFonts.poppins())];
  }

  Future<void> _openUrl(String url) async {
    try {
      final uri = Uri.tryParse(url);
      if (uri == null) return;
      if (!await canLaunchUrl(uri)) return;
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      // ignore
    }
  }

  Widget _linkTile(dynamic link) {
    if (link == null) return Text('-', style: GoogleFonts.poppins());
    final s = link.toString();
    if (s.isEmpty) return Text('-', style: GoogleFonts.poppins());
    return InkWell(
      onTap: () => _openUrl(s),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF6366F1).withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFF6366F1).withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.link, size: 16, color: Color(0xFF6366F1)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                s,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: const Color(0xFF6366F1),
                  decoration: TextDecoration.underline,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = profile ?? {};
    final isMobile = MediaQuery
        .of(context)
        .size
        .width < 600;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 40,
        vertical: isMobile ? 16 : 24,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 5,
            )
          ],
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with profile
              Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: candidate.pictureUrl.isNotEmpty
                        ? NetworkImage(candidate.pictureUrl) as ImageProvider
                        : null,
                    backgroundColor: const Color(0xFF6366F1).withOpacity(0.1),
                    child: candidate.pictureUrl.isEmpty
                        ? const Icon(
                        Icons.person, size: 40, color: Color(0xFF6366F1))
                        : null,
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          candidate.name,
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildContactChip(Icons.email, candidate.email),
                        const SizedBox(height: 6),
                        _buildContactChip(Icons.phone, candidate.phone),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              Divider(color: Colors.grey.shade200, height: 1),

              // Personal Section
              _sectionTitle('Personal Information'),
              _bulletRow('Father',
                  (p['father_name'] ?? p['father'] ?? '-')?.toString() ?? '-'),
              _bulletRow('DOB',
                  _formatDob(p['dob'] ?? p['date_of_birth'] ?? p['birthdate'])),
              _bulletRow('Nationality',
                  (p['nationality'] ?? candidate.nationality ?? '-')
                      ?.toString() ?? '-'),
              _bulletRow('Gender', (p['gender'] ?? '-')?.toString() ?? '-'),

              const SizedBox(height: 4),
              Divider(color: Colors.grey.shade200, height: 1),

              // Education Section
              _sectionTitle('Education'),
              ..._listFrom(
                  p['educations'] ?? p['education'] ?? p['qualifications']),

              const SizedBox(height: 4),
              Divider(color: Colors.grey.shade200, height: 1),

              // Experience Section
              _sectionTitle('Experience'),
              ..._listFrom(
                  p['experiences'] ?? p['experience'] ?? p['work_experience'],
                  isExperience: true),

              const SizedBox(height: 4),
              Divider(color: Colors.grey.shade200, height: 1),

              // Certifications Section
              _sectionTitle('Certifications'),
              ..._listFrom(
                  p['certiicaitons'] ?? p['certifications'] ?? p['certs']),

              const SizedBox(height: 4),
              Divider(color: Colors.grey.shade200, height: 1),

              // Skills Section
              _sectionTitle('Skills'),
              if (p['skills'] is List && (p['skills'] as List).isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (p['skills'] as List)
                        .map<Widget>((s) =>
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6366F1).withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          child: Text(
                            s.toString(),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ))
                        .toList(),
                  ),
                )
              else
                ..._listFrom(p['skills'] ?? '-'),

              const SizedBox(height: 4),
              Divider(color: Colors.grey.shade200, height: 1),

              // CV/Resume Section
              _sectionTitle('CV / Resume'),
              _linkTile(
                  p['Cv/Resume'] ?? p['cv'] ?? p['resume'] ?? p['cv_url'] ??
                      p['resume_url']),

              const SizedBox(height: 4),
              Divider(color: Colors.grey.shade200, height: 1),

              // References Section
              _sectionTitle('References'),
              ..._listFrom(p['refrences'] ?? p['references'] ?? '-'),

              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, size: 18),
                  label: Text(
                      'Close', style: GoogleFonts.poppins(fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 2,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 6),
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}