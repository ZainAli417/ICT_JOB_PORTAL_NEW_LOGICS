import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:job_portal/Screens/Recruiter/R_Top_Bar.dart';

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
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _fade = CurvedAnimation(
      parent: _ctrl,
      curve: Curves.easeOutCubic,
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
     return Recruiter_MainLayout(
      activeIndex: 0,
      child: Stack(
          children: [
            FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: _buildDashboardContent(context),
        ),
      ),
      ]
          ),
    );
  }
  Widget _buildDashboardContent(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final screenWidth = MediaQuery.of(context).size.width;

    return        Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: ChangeNotifierProvider(
        create: (_) => RecruiterProvider2(),
        builder: (context, _) {
          final prov = Provider.of<RecruiterProvider2>(context);
          if (isMobile) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  _buildSearchAndFilters(prov, isMobile, screenWidth),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: prov.loading
                        ? _buildLoadingState()
                        : _buildCandidatesSection(prov, isMobile),
                  ),
                  if (prov.candidates.isNotEmpty)
                    _buildBottomActionBar(prov, isMobile),
                ],
              ),
            );
          }

          // Desktop Layout - Side by Side
          return Container(
            color: Colors.white,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Sidebar - Filters
                Container(
                  width: 320,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      right: BorderSide(
                        color: Colors.grey.shade200,
                        width: 1,
                      ),
                    ),
                  ),
                  child: _buildSearchAndFilters(prov, isMobile, screenWidth),
                ),
                // Right Content Area
                Expanded(
                  child: Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: prov.loading
                                  ? _buildLoadingState()
                                  : _buildCandidatesSection(prov, isMobile),
                            ),
                          ),
                        ),
                        if (prov.candidates.isNotEmpty)
                          _buildBottomActionBar(prov, isMobile),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext c) => AppBar(
    elevation: 0,
    backgroundColor: Colors.white,
    title: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.people_alt_rounded,
              color: Colors.white, size: 24),
        ),
        const SizedBox(width: 16),
        Text(
          'Candidates',
          style: GoogleFonts.poppins(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
            letterSpacing: -0.5,
          ),
        ),
      ],
    ),
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(1),
      child: Container(
        height: 1,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.grey.shade100,
              Colors.grey.shade200,
              Colors.grey.shade100,
            ],
          ),
        ),
      ),
    ),
  );

  Widget _buildSearchAndFilters(RecruiterProvider2 prov, bool isMobile, double screenWidth) {
    final natList = [
      'All',
      ...prov.nationalityOptions.where((s) => s.trim().isNotEmpty).toList()
        ..sort((a, b) => a.compareTo(b))
    ];
    final sortOptions = ['None', 'Name A→Z', 'Name Z→A'];

    if (isMobile) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
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
            Align(
              alignment: Alignment.centerRight,
              child: _buildClearButton(prov),
            ),
          ],
        ),
      );
    }

    // Desktop Sidebar Layout
    return SingleChildScrollView(
      child: Padding(

        padding: const EdgeInsets.all(24),
        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.filter_list_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Filters',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Search Section
            Text(
              'Search',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            _buildSearchField(prov),
            const SizedBox(height: 24),

            // Nationality Filter
            Text(
              'Nationality',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            _buildNationalityDropdown(natList, prov),
            const SizedBox(height: 24),

            // Sort Section
            Text(
              'Sort By',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            _buildSortDropdown(sortOptions, prov),
            const SizedBox(height: 24),

            // Divider
            Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.grey.shade200,
                    Colors.grey.shade100,
                    Colors.grey.shade200,
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Clear Button
            _buildClearButtonFull(prov),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField(RecruiterProvider2 prov) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (v) => prov.setSearch(v),
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF0F172A),
        ),
        decoration: InputDecoration(
          hintText: 'Search by name, email, phone, nationality...',
          hintStyle: GoogleFonts.poppins(
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w400,
          ),
          filled: false,
          border: InputBorder.none,
          prefixIcon: Container(
            padding: const EdgeInsets.all(12),
            child: Icon(
              Icons.search_rounded,
              color: const Color(0xFF6366F1),
              size: 22,
            ),
          ),
          suffixIcon: prov.searchQuery.isNotEmpty
              ? IconButton(
            icon: Icon(Icons.clear_rounded,
                color: Colors.grey.shade400, size: 20),
            onPressed: () {
              _searchCtrl.clear();
              prov.setSearch('');
            },
          )
              : null,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildNationalityDropdown(
      List<String> natList, RecruiterProvider2 prov) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
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
          child: Text(
            n,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),

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
          filled: false,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: InputBorder.none,
          prefixIcon: Icon(
            Icons.public_rounded,
            size: 20,
            color: const Color(0xFF6366F1),
          ),
        ),
        icon: Icon(Icons.keyboard_arrow_down_rounded,
            color: Colors.grey.shade600),
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildSortDropdown(List<String> sortOptions, RecruiterProvider2 prov) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: prov.sortOption,
        items: sortOptions
            .map((s) => DropdownMenuItem(
          value: s,
          child: Text(
            s,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ))
            .toList(),
        onChanged: (v) {
          if (v != null) prov.setSortOption(v);
        },
        decoration: InputDecoration(
          filled: false,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: InputBorder.none,
          prefixIcon: Icon(
            Icons.sort_rounded,
            size: 20,
            color: const Color(0xFF6366F1),
          ),
        ),
        icon: Icon(Icons.keyboard_arrow_down_rounded,
            color: Colors.grey.shade600),
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildClearButton(RecruiterProvider2 prov) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [Colors.red.shade400, Colors.red.shade500],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.red.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => prov.clearSelection(),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.refresh_rounded, size: 18, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'Clear',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClearButtonFull(RecruiterProvider2 prov) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [Colors.red.shade400, Colors.red.shade500],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.red.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => prov.clearSelection(),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.refresh_rounded, size: 20, color: Colors.white),
                const SizedBox(width: 10),
                Text(
                  'Clear All Filters',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF6366F1).withOpacity(0.1),
                  const Color(0xFF8B5CF6).withOpacity(0.1),
                ],
              ),
            ),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
              strokeWidth: 5,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Loading candidates...',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 60),
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
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.shade50,
                    Colors.purple.shade50,
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.shade100,
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Icon(
                Icons.person_search_rounded,
                size: 56,
                color: const Color(0xFF6366F1),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No candidates found',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF6366F1).withOpacity(0.1),
                const Color(0xFF8B5CF6).withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF6366F1).withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.people_alt_rounded,
                  size: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${list.length} ${list.length == 1 ? 'Candidate' : 'Candidates'}',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  'Active',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (!isMobile) _buildTableHeader(),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, idx) => TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 300 + (idx * 50)),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: _buildCandidateCard(
              context,
              list[idx],
              prov,
              isMobile,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTableHeader() {
    // matching min widths for: Avatar, Name, Email, Phone, Nationality, Actions, Select
    final minWidths = <double>[100, 160, 140, 110, 110, 110, 60];
    final cells = <Widget>[
      _headerText('Avatar'),
      _headerText('Name'),
      _headerText('Email'),
      _headerText('Phone'),
      _headerText('Nationality'),
      _headerText('Actions'),
      _headerText('Select'),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6366F1).withOpacity(0.08),
            const Color(0xFF8B5CF6).withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.2)),
      ),
      child: _responsiveRow(
        cells: cells,
        minWidths: minWidths,
        gap: 16,
        cellPadding: const EdgeInsets.symmetric(vertical: 8),
      ),
    );
  }

  Widget _headerText(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontWeight: FontWeight.w700,
        fontSize: 13,
        color: const Color(0xFF6366F1),
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildCandidateCard(BuildContext context, Candidate candidate,
      RecruiterProvider2 prov, bool isMobile) {
    final isSelected = prov.selectedUids.contains(candidate.uid);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF6366F1)
                : Colors.grey.shade200,
            width: isSelected ? 2 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFF6366F1).withOpacity(0.15)
                  : Colors.grey.shade100,
              blurRadius: isSelected ? 12 : 8,
              offset: Offset(0, isSelected ? 4 : 2),
            ),
          ],
        ),
        // inside your existing _buildCandidateCard, replace the non-mobile child with:
        child: isMobile
            ? _buildMobileCandidateCard(context, candidate, prov)
            : _responsiveRow(
          // columns must match header order and min widths
          cells: <Widget>[
            _buildAvatar(candidate),
            _buildHighlightText(candidate.name, prov.searchQuery),
            _buildHighlightText(candidate.email, prov.searchQuery),
            _buildHighlightText(candidate.phone, prov.searchQuery),
            _buildNationalityChip(candidate.nationality, prov.searchQuery),
            _buildViewDetailsButton(context, candidate, prov),
            // last is checkbox (Select)
            Transform.scale(
              scale: 1.1,
              child: Checkbox(
                value: isSelected,
                onChanged: (v) => prov.toggleSelection(candidate.uid, value: v),
                activeColor: const Color(0xFF6366F1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ],
          minWidths: <double>[100, 160, 140, 110, 110, 110, 60],
          gap: 16,
          cellPadding: const EdgeInsets.symmetric(vertical: 6),
        ),

      ),
    );
  }
  /// Helper: builds a responsive row of columns that:
  /// - uses horizontal scrolling if available width < sum of minWidths
  /// - otherwise converts columns into Expanded widgets and fills the available space
  Widget _responsiveRow({
    required List<Widget> cells,
    required List<double> minWidths,
    double gap = 16,
    EdgeInsets cellPadding = const EdgeInsets.symmetric(vertical: 6),
  }) {
    assert(cells.length == minWidths.length);
    return LayoutBuilder(builder: (context, constraints) {
      final available = constraints.maxWidth.isFinite ? constraints.maxWidth : MediaQuery.of(context).size.width;
      final totalMin = minWidths.reduce((a, b) => a + b) + gap * (minWidths.length - 1);

      // If not enough space, keep fixed widths and enable horizontal scroll
      if (available < totalMin) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List<Widget>.generate(cells.length, (i) {
              return Padding(
                padding: EdgeInsets.only(right: i == cells.length - 1 ? 0 : gap),
                child: SizedBox(
                  width: minWidths[i],
                  child: Padding(
                    padding: cellPadding,
                    child: cells[i],
                  ),
                ),
              );
            }),
          ),
        );
      }

      // Enough space: distribute remaining space by converting to Expanded with proportional flex
      final totalWeight = minWidths.reduce((a, b) => a + b);
      // convert weights into integer flex values (at least 1)
      final flexes = minWidths.map((w) => (w / totalWeight * 1000).round().clamp(1, 10000)).toList();

      return Row(
        children: List<Widget>.generate(cells.length, (i) {
          final flex = flexes[i];
          return Expanded(
            flex: flex,
            child: Padding(
              padding: EdgeInsets.only(right: i == cells.length - 1 ? 0 : gap),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: cellPadding,
                  child: cells[i],
                ),
              ),
            ),
          );
        }),
      );
    });
  }

  Widget _buildAvatar(Candidate candidate) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: candidate.pictureUrl.isEmpty
            ? const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        )
            : null,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 24,
        backgroundImage: candidate.pictureUrl.isNotEmpty
            ? NetworkImage(candidate.pictureUrl) as ImageProvider
            : null,
        backgroundColor:
        candidate.pictureUrl.isEmpty ? Colors.transparent : Colors.white,
        child: candidate.pictureUrl.isEmpty
            ? const Icon(Icons.person_rounded, color: Colors.white, size: 24)
            : null,
      ),
    );
  }

  Widget _buildMobileCandidateCard(
      BuildContext context, Candidate candidate, RecruiterProvider2 prov) {
    final isSelected = prov.selectedUids.contains(candidate.uid);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildAvatar(candidate),
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
            Transform.scale(
              scale: 1.1,
              child: Checkbox(
                value: isSelected,
                onChanged: (v) =>
                    prov.toggleSelection(candidate.uid, value: v),
                activeColor: const Color(0xFF6366F1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMobileInfoChip(Icons.phone_rounded, candidate.phone),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMobileInfoChip(
                  Icons.public_rounded, candidate.nationality),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildViewDetailsButton(context, candidate, prov),
      ],
    );
  }

  Widget _buildMobileInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey.shade50,
            Colors.grey.shade100,
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF6366F1)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNationalityChip(String nationality, String query) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6366F1).withOpacity(0.1),
            const Color(0xFF8B5CF6).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF6366F1).withOpacity(0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.public_rounded,
            size: 14,
            color: const Color(0xFF6366F1),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _buildHighlightText(nationality, query),
          ),
        ],
      ),
    );
  }

  Widget _buildViewDetailsButton(
      BuildContext context, Candidate candidate, RecruiterProvider2 prov) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
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
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.visibility_rounded,
                    size: 16, color: Colors.white),
                const SizedBox(width: 6),
                Text(
                  'View',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHighlightText(String text, String query) {
    if (query.isEmpty) {
      return Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF0F172A),
        ),
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
        style: TextStyle(
          backgroundColor: const Color(0xFFFCD34D),
          fontWeight: FontWeight.w700,
          color: const Color(0xFF0F172A),
        ),
      ));
      start = idx + lcQuery.length;
    }

    return RichText(
      text: TextSpan(
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF0F172A),
        ),
        children: spans,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildBottomActionBar(RecruiterProvider2 prov, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: isMobile ? 12 : 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: isMobile
          ? Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF6366F1).withOpacity(0.1),
                  const Color(0xFF8B5CF6).withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFF6366F1).withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  size: 18,
                  color: const Color(0xFF6366F1),
                ),
                const SizedBox(width: 8),
                Text(
                  '${prov.selectedUids.length} selected',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF6366F1),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildSendButton(prov),
        ],
      )
          : Row(
        children: [
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF6366F1).withOpacity(0.1),
                  const Color(0xFF8B5CF6).withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFF6366F1).withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  size: 18,
                  color: const Color(0xFF6366F1),
                ),
                const SizedBox(width: 8),
                Text(
                  '${prov.selectedUids.length} selected',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF6366F1),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          _buildSendButton(prov),
        ],
      ),
    );
  }

  Widget _buildSendButton(RecruiterProvider2 prov) {
    final isEnabled = prov.selectedUids.isNotEmpty;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        gradient: isEnabled
            ? const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        )
            : null,
        color: isEnabled ? null : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(12),
        boxShadow: isEnabled
            ? [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? () => _handleSendRequest(prov) : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.send_rounded,
                  size: 18,
                  color: isEnabled ? Colors.white : Colors.grey.shade500,
                ),
                const SizedBox(width: 10),
                Text(
                  'Send Request to Admin',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isEnabled ? Colors.white : Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSendRequest(RecruiterProvider2 prov) async {
    final requestId = await prov.sendSelectedCandidatesToAdmin(
      notes: 'Sent from dashboard',
    );

    if (mounted) {
      if (requestId != null) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    Colors.green.shade50,
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green.shade400, Colors.green.shade600],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.shade200,
                          blurRadius: 16,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Request Sent Successfully!',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Request ID: $requestId',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 14,
                          ),
                          child: Text(
                            'Close',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      } else {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    Colors.red.shade50,
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.red.shade400, Colors.red.shade600],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.shade200,
                          blurRadius: 16,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.error_outline_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Request Failed',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Failed to send request or no candidates selected.',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 14,
                          ),
                          child: Text(
                            'Close',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }
  }
}


















class CandidateDetailsDialog extends StatelessWidget {
  final Candidate candidate;
  final Map<String, dynamic>? profile;

  const CandidateDetailsDialog({
    required this.candidate,
    required this.profile,
    super.key,
  });

  Widget _sectionHeader(String title, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(top: 24, bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

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

  Widget _infoCard(IconData icon, String label, String value, Color iconColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6366F1).withOpacity(0.08),
            const Color(0xFF8B5CF6).withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF6366F1).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [iconColor, iconColor.withOpacity(0.7)],
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: iconColor.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _experienceCard(Map<String, dynamic> exp) {
    final role = (exp['role'] ?? exp['title'] ?? exp['position'])?.toString() ?? '';
    final company = (exp['company'] ?? exp['organization'] ?? exp['employer'])?.toString() ?? '';
    final start = (exp['start'] ?? exp['from'])?.toString() ?? '';
    final end = (exp['end'] ?? exp['to'] ?? exp['duration'])?.toString() ?? '';
    final durationText = (start.isNotEmpty || end.isNotEmpty)
        ? '$start${start.isNotEmpty && end.isNotEmpty ? ' - ' : ''}$end'
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFF59E0B).withOpacity(0.12),
            const Color(0xFFEC4899).withOpacity(0.12),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFF59E0B).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF59E0B), Color(0xFFEC4899)],
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF59E0B).withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.work_outline, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (role.isNotEmpty)
                  Text(
                    role,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                if (company.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    company,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
                if (durationText.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      durationText,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFF59E0B),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _educationCard(Map<String, dynamic> edu) {
    final title = (edu['degree'] ?? edu['title'] ?? edu['name'])?.toString() ?? '';
    final institute = (edu['institute'] ?? edu['company'] ?? edu['organization'])?.toString() ?? '';
    final year = (edu['year'] ?? edu['end'] ?? edu['to'])?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF10B981).withOpacity(0.12),
            const Color(0xFF059669).withOpacity(0.12),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF10B981).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF059669)],
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF10B981).withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.school_outlined, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title.isNotEmpty)
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                if (institute.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    institute,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
                if (year.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      year,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _certificationBadge(String cert) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6366F1).withOpacity(0.1),
            const Color(0xFF8B5CF6).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF6366F1).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.verified_outlined, color: Colors.white, size: 14),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              cert,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
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

  Widget _cvButton(dynamic link) {
    if (link == null) return const SizedBox.shrink();
    final s = link.toString();
    if (s.isEmpty) return const SizedBox.shrink();

    return InkWell(
      onTap: () => _openUrl(s),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.picture_as_pdf, color: Colors.white, size: 22),
            const SizedBox(width: 12),
            Text(
              'View Full CV/Resume',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.open_in_new, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = profile ?? {};
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 40,
        vertical: isMobile ? 16 : 24,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 500,  // Set your desired max width here
          ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 30,
              spreadRadius: 5,
            )
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Modern Header with Gradient
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 45,
                            backgroundImage: candidate.pictureUrl.isNotEmpty
                                ? NetworkImage(candidate.pictureUrl) as ImageProvider
                                : null,
                            backgroundColor: Colors.white,
                            child: candidate.pictureUrl.isEmpty
                                ? const Icon(Icons.person, size: 45, color: Color(0xFF6366F1))
                                : null,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                candidate.name,
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildContactBadge(Icons.email_outlined, candidate.email),
                              const SizedBox(height: 8),
                              _buildContactBadge(Icons.phone_outlined, candidate.phone),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Personal Information
                    _sectionHeader('Personal Information', Icons.person_outline),
                    _infoCard(
                      Icons.supervisor_account_outlined,
                      'Father\'s Name',
                      (p['father_name'] ?? p['father'] ?? '-')?.toString() ?? '-',
                      const Color(0xFF6366F1),
                    ),
                    _infoCard(
                      Icons.cake_outlined,
                      'Date of Birth',
                      _formatDob(p['dob'] ?? p['date_of_birth'] ?? p['birthdate']),
                      const Color(0xFFEC4899),
                    ),
                    _infoCard(
                      Icons.flag_outlined,
                      'Nationality',
                      (p['nationality'] ?? candidate.nationality ?? '-')?.toString() ?? '-',
                      const Color(0xFF10B981),
                    ),
                    _infoCard(
                      Icons.wc_outlined,
                      'Gender',
                      (p['gender'] ?? '-')?.toString() ?? '-',
                      const Color(0xFFF59E0B),
                    ),

                    // Education
                    _sectionHeader('Education', Icons.school_outlined),
                    ...((p['educations'] ?? p['education'] ?? p['qualifications']) as List?)
                        ?.whereType<Map<String, dynamic>>()
                        .map((e) => _educationCard(e))
                        .toList() ??
                        [
                          Text(
                            'No education information available',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF64748B),
                            ),
                          )
                        ],

                    // Experience
                    _sectionHeader('Professional Experience', Icons.work_outline),
                    ...((p['experiences'] ?? p['experience'] ?? p['work_experience']) as List?)
                        ?.whereType<Map<String, dynamic>>()
                        .map((e) => _experienceCard(e))
                        .toList() ??
                        [
                          Text(
                            'No experience information available',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF64748B),
                            ),
                          )
                        ],

                    // Skills
                    _sectionHeader('Skills & Expertise', Icons.emoji_objects_outlined),
                    if (p['skills'] is List && (p['skills'] as List).isNotEmpty)
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: (p['skills'] as List)
                            .map<Widget>((s) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6366F1).withOpacity(0.3),
                                blurRadius: 6,
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
                      )
                    else
                      Text(
                        'No skills listed',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
                        ),
                      ),

                    // Certifications
                    _sectionHeader('Certifications', Icons.verified_outlined),
                    ...((p['certiicaitons'] ?? p['certifications'] ?? p['certs']) as List?)
                        ?.map((c) => _certificationBadge(c.toString()))
                        .toList() ??
                        [
                          Text(
                            'No certifications available',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF64748B),
                            ),
                          )
                        ],

                    // CV/Resume
                    _sectionHeader('Documents', Icons.description_outlined),
                    _cvButton(
                      p['Cv/Resume'] ?? p['cv'] ?? p['resume'] ?? p['cv_url'] ?? p['resume_url'],
                    ),

                    const SizedBox(height: 24),
                    // Close Button
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.close, size: 18, color: Color(0xFF64748B)),
                            const SizedBox(width: 8),
                            Text(
                              'Close',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
            ),
    );
  }

  Widget _buildContactBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}