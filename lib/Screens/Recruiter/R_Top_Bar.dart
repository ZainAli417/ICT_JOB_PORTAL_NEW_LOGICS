// Modern Glassmorphic Top Navigation - Responsive & Sticky
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:job_portal/Screens/Recruiter/R_Initials_provider.dart';
import 'package:job_portal/Screens/Recruiter/post_a_job_form.dart';
import 'package:provider/provider.dart';

class Recruiter_MainLayout extends StatefulWidget {
  final Widget child;
  final int activeIndex;
  @override
  final Key? key;

  const Recruiter_MainLayout({
    this.key,
    required this.child,
    required this.activeIndex,
  }) : super(key: key);

  @override
  State<Recruiter_MainLayout> createState() => _Recruiter_MainLayoutState();
}

class _Recruiter_MainLayoutState extends State<Recruiter_MainLayout>
    with TickerProviderStateMixin {
  bool _isDarkMode = false;
  int? _activeMenu;
  late AnimationController _shimmerController;
  late AnimationController _particleController;

  void _openPostJobDialog() {
    showDialog(
      context: context,
      builder: (_) => const PostJobDialog(),
    );
  }

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<R_TopNavProvider>(
      create: (_) => R_TopNavProvider(),
      child: RepaintBoundary(child: _buildScaffold(context)),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    final initials = context.watch<R_TopNavProvider>().initials;

    return Scaffold(
      backgroundColor: _isDarkMode
          ? const Color(0xFF0A0E27)
          : const Color(0xFFFFFFFF),
      body: Column(
        children: [
          RepaintBoundary(
            child: _buildModernGlassmorphicHeader(initials),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.0, 0.03),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    )),
                    child: child,
                  ),
                );
              },
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernGlassmorphicHeader(String initials) {
    final primaryColor = Theme.of(context).primaryColor;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      height: screenWidth < 1200 ? 70 : 80,
      margin: const EdgeInsets.symmetric(horizontal: 50),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: _isDarkMode
                ? Colors.black.withOpacity(0.7)
                : const Color(0xFF6366F1).withOpacity(0.5),
            blurRadius: 32,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _isDarkMode
                    ? [
                  Colors.white.withOpacity(0.08),
                  Colors.white.withOpacity(0.04),
                ]
                    : [
                  Colors.white.withOpacity(0.85),
                  Colors.white.withOpacity(0.65),
                ],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              border: Border.all(
                color: _isDarkMode
                    ? Colors.white.withOpacity(0.15)
                    : Colors.white.withOpacity(0.6),
                width: 1.5,
              ),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth < 1200 ? 16 : 24,
              vertical: 12,
            ),
            child: screenWidth < 1400
                ? _buildCompactNavigation(primaryColor, initials, screenWidth)
                : _buildFullNavigation(primaryColor, initials),
          ),
        ),
      ),
    );
  }

  Widget _buildFullNavigation(Color primaryColor, String initials) {
    return Row(
      children: [
        _buildEnhancedLogo(),
        const SizedBox(width: 70),
        Expanded(
          child: Row(
            children: [
              _buildModernNavItem(
                icon: Icons.dashboard_rounded,
                label: 'Dashboard',
                isActive: widget.activeIndex == 0,
                onTap: () {
                  if (widget.activeIndex != 0) {
                    context.go('/recruiter-dashboard');
                  }
                },
              ),
              const SizedBox(width: 15),
              _buildModernNavItem(
                icon: Icons.hub_outlined,
                label: 'Job Listing',
                isActive: widget.activeIndex == 1,
                onTap: () {
                  if (widget.activeIndex != 1) context.go('/recruiter-job-listing');
                },
              ),
              const SizedBox(width: 15),
              _buildModernNavItem(
                icon: Icons.description_rounded,
                label: 'Applications',
                isActive: widget.activeIndex == 2,
                onTap: () {
                  if (widget.activeIndex != 2) {
                    context.go('/view-applications');
                  }
                },
              ),
              const SizedBox(width: 15),
              _buildModernNavItem(
                icon: Icons.video_call_rounded,
                label: 'Interviews',
                isActive: widget.activeIndex == 3,
                onTap: () {
                  if (widget.activeIndex != 3) context.go('/interviews');
                },
              ),
            ],
          ),
        ),
        _buildGlowingActionButton(
          text: 'Post A Job',
          icon: Icons.add_circle_outline_rounded,
          onPressed: _openPostJobDialog,
        ),
        const SizedBox(width: 16),
        _buildGlassmorphicIconButton(
          tooltip: 'Quick Links',
          icon: Icons.apps_rounded,
          onPressed: () => _showQuickLinks(context),
          isActive: _activeMenu == 2,
        ),
        const SizedBox(width: 8),
        _buildGlassmorphicIconButton(
          tooltip: 'Notifications',
          icon: Icons.notifications_none_rounded,
          activeIcon: Icons.notifications_rounded,
          onPressed: () =>
              setState(() => _activeMenu = _activeMenu == 0 ? null : 0),
          badge: 3,
          isActive: _activeMenu == 0,
        ),
        const SizedBox(width: 8),
        _buildGlassmorphicIconButton(
          tooltip: 'Messages',
          icon: Icons.chat_bubble_outline_rounded,
          activeIcon: Icons.chat_bubble_rounded,
          onPressed: () =>
              setState(() => _activeMenu = _activeMenu == 1 ? null : 1),
          isActive: _activeMenu == 1,
        ),
        Container(
          height: 40,
          width: 1,
          margin: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                _isDarkMode
                    ? Colors.white.withOpacity(0.2)
                    : Colors.grey.withOpacity(0.3),
                Colors.transparent,
              ],
            ),
          ),
        ),
        _buildGlassmorphicIconButton(
          tooltip: _isDarkMode ? 'Light Mode' : 'Dark Mode',
          icon: _isDarkMode
              ? Icons.light_mode_rounded
              : Icons.dark_mode_rounded,
          onPressed: () => setState(() => _isDarkMode = !_isDarkMode),
        ),
        const SizedBox(width: 16),
        _buildProfileMenu(primaryColor, initials),
      ],
    );
  }

  Widget _buildCompactNavigation(Color primaryColor, String initials, double screenWidth) {
    return Row(
      children: [
        if (screenWidth >= 900) ...[
          _buildEnhancedLogo(compact: true),
          const SizedBox(width: 20),
        ],
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildModernNavItem(
                  icon: Icons.dashboard_rounded,
                  label: screenWidth < 900 ? '' : 'Dashboard',
                  isActive: widget.activeIndex == 0,
                  onTap: () {
                    if (widget.activeIndex != 0) {
                      context.go('/recruiter-dashboard');
                    }
                  },
                  compact: screenWidth < 900,
                ),
                const SizedBox(width: 8),
                _buildModernNavItem(
                  icon: Icons.hub_outlined,
                  label: screenWidth < 900 ? '' : 'Job Listing',
                  isActive: widget.activeIndex == 1,
                  onTap: () {
                    if (widget.activeIndex != 1) context.go('/recruiter-job-listing');
                  },
                  compact: screenWidth < 900,
                ),
                const SizedBox(width: 8),
                _buildModernNavItem(
                  icon: Icons.description_rounded,
                  label: screenWidth < 900 ? '' : 'Applications',
                  isActive: widget.activeIndex == 2,
                  onTap: () {
                    if (widget.activeIndex != 2) {
                      context.go('/view-applications');
                    }
                  },
                  compact: screenWidth < 900,
                ),
                const SizedBox(width: 8),
                _buildModernNavItem(
                  icon: Icons.video_call_rounded,
                  label: screenWidth < 900 ? '' : 'Interviews',
                  isActive: widget.activeIndex == 3,
                  onTap: () {
                    if (widget.activeIndex != 3) context.go('/interviews');
                  },
                  compact: screenWidth < 900,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        _buildGlassmorphicIconButton(
          tooltip: 'Post A Job',
          icon: Icons.add_circle_outline_rounded,
          onPressed: _openPostJobDialog,
          isActive: false,
        ),
        const SizedBox(width: 8),
        _buildGlassmorphicIconButton(
          tooltip: 'Notifications',
          icon: Icons.notifications_none_rounded,
          activeIcon: Icons.notifications_rounded,
          onPressed: () =>
              setState(() => _activeMenu = _activeMenu == 0 ? null : 0),
          badge: 3,
          isActive: _activeMenu == 0,
        ),
        const SizedBox(width: 8),
        _buildProfileMenu(primaryColor, initials),
      ],
    );
  }

  Widget _buildEnhancedLogo({bool compact = false}) {
    return Row(
      children: [
        Image.asset(
          'images/logo.png',
          width: compact ? 120 : 180,
          height: compact ? 40 : 60,
          fit: BoxFit.fill,
        ),
        const SizedBox(width: 14),
      ],
    );
  }

  Widget _buildModernNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    bool compact = false,
  }) {
    return _ModernHoverNavItem(
      icon: icon,
      label: label,
      isActive: isActive,
      onTap: onTap,
      isDarkMode: _isDarkMode,
      compact: compact,
    );
  }

  Widget _buildGlowingActionButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return RepaintBoundary(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onPressed,
          child: AnimatedBuilder(
            animation: _shimmerController,
            builder: (context, child) {
              return Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF6366F1),
                      Color(0xFF8B5CF6),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                      spreadRadius: -2,
                    ),
                    BoxShadow(
                      color: const Color(0xFF8B5CF6).withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 18, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      text,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildGlassmorphicIconButton({
    required String tooltip,
    required IconData icon,
    IconData? activeIcon,
    required VoidCallback onPressed,
    int? badge,
    bool isActive = false,
  }) {
    final hoverProvider = ValueNotifier<bool>(false);

    return ValueListenableBuilder<bool>(
      valueListenable: hoverProvider,
      builder: (context, isHovering, child) {
        final isHighlighted = isHovering || isActive;
        return Tooltip(
          message: tooltip,
          waitDuration: const Duration(milliseconds: 500),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              InkWell(
                onTap: onPressed,
                onHover: (value) => hoverProvider.value = value,
                borderRadius: BorderRadius.circular(14),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    gradient: isHighlighted
                        ? LinearGradient(
                      colors: _isDarkMode
                          ? [
                        Colors.white.withOpacity(0.15),
                        Colors.white.withOpacity(0.08),
                      ]
                          : [
                        const Color(0xFF6366F1).withOpacity(0.12),
                        const Color(0xFF8B5CF6).withOpacity(0.06),
                      ],
                    )
                        : null,
                    borderRadius: BorderRadius.circular(14),
                    border: isHighlighted
                        ? Border.all(
                      color: _isDarkMode
                          ? Colors.white.withOpacity(0.2)
                          : const Color(0xFF6366F1).withOpacity(0.3),
                      width: 1.5,
                    )
                        : null,
                  ),
                  child: Icon(
                    isActive ? (activeIcon ?? icon) : icon,
                    color: isActive
                        ? const Color(0xFF6366F1)
                        : (_isDarkMode
                        ? Colors.white.withOpacity(0.7)
                        : const Color(0xFF64748B)),
                    size: 22,
                  ),
                ),
              ),
              if (badge != null && badge > 0)
                Positioned(
                  right: 2,
                  top: 2,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF6B6B), Color(0xFFEE5A6F)],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _isDarkMode ? Color(0xFF1A1F3A) : Colors.white,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.5),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    constraints:
                    const BoxConstraints(minWidth: 20, minHeight: 20),
                    child: Center(
                      child: Text(
                        badge > 99 ? '99+' : badge.toString(),
                        style: GoogleFonts.poppins(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          height: 1,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileMenu(Color primaryColor, String initials) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Color(0xFFE2E8F0), width: 2),
        ),
        child: CircleAvatar(
          radius: 18,
          backgroundColor: primaryColor,
          child: Text(
            initials.isNotEmpty ? initials : 'RC',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
      itemBuilder: (context) => [
        _buildPopupMenuItem(
            'Profile', Icons.person_outline_rounded, () => context.go('/NA')),
        _buildPopupMenuItem(
            'Settings', Icons.settings_outlined, () => context.go('/NA')),
        _buildPopupMenuItem('Help', Icons.help_outline_rounded, () {}),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'logout',
          onTap: () => _showModernLogoutDialog(context),
          child: Row(
            children: [
              Icon(Icons.logout_rounded, size: 18, color: Colors.red.shade500),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  'Logout',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem(
      String title, IconData icon, VoidCallback onTap,
      {bool isDestructive = false}) {
    return PopupMenuItem<String>(
      value: title.toLowerCase(),
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon,
              size: 18,
              color: isDestructive ? Colors.red.shade500 : Color(0xFF64748B)),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDestructive ? Colors.red.shade500 : Color(0xFF1E293B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showQuickLinks(BuildContext context) =>
      print('Showing Quick Links menu');

  void _showModernLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(32),
          constraints: const BoxConstraints(maxWidth: 420),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _isDarkMode
                  ? [
                const Color(0xFF1E293B),
                const Color(0xFF0F172A),
              ]
                  : [
                Colors.white,
                Colors.grey.shade50,
              ],
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.red.shade400,
                      Colors.red.shade600,
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(Icons.logout_rounded,
                    size: 36, color: Colors.white),
              ),
              const SizedBox(height: 24),
              Text(
                'Confirm Logout',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: _isDarkMode ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to logout from your account?',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: _isDarkMode
                      ? Colors.white.withOpacity(0.7)
                      : const Color(0xFF64748B),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(
                          color: _isDarkMode
                              ? Colors.white.withOpacity(0.2)
                              : Colors.grey.shade300,
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: _isDarkMode
                              ? Colors.white
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        context.pushReplacement('/');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                        shadowColor: Colors.red.withOpacity(0.4),
                      ),
                      child: Text(
                        'Logout',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModernHoverNavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final bool isDarkMode;
  final bool compact;

  const _ModernHoverNavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.isDarkMode,
    this.compact = false,
  });

  @override
  State<_ModernHoverNavItem> createState() => _ModernHoverNavItemState();
}

class _ModernHoverNavItemState extends State<_ModernHoverNavItem>
    with AutomaticKeepAliveClientMixin {
  bool _isHovering = false;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isHighlighted = widget.isActive || _isHovering;

    return RepaintBoundary(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) {
          if (!_isHovering) setState(() => _isHovering = true);
        },
        onExit: (_) {
          if (_isHovering) setState(() => _isHovering = false);
        },
        child: GestureDetector(
          onTap: widget.onTap,
          behavior: HitTestBehavior.translucent,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            height: 48,
            padding: widget.compact
                ? const EdgeInsets.all(12)
                : const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              gradient: isHighlighted
                  ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: widget.isDarkMode
                    ? [
                  Colors.white.withOpacity(0.15),
                  Colors.white.withOpacity(0.08),
                ]
                    : [
                  const Color(0xFF6366F1).withOpacity(0.15),
                  const Color(0xFF8B5CF6).withOpacity(0.08),
                ],
              )
                  : null,
              borderRadius: BorderRadius.circular(14),
              border: isHighlighted
                  ? Border.all(
                color: widget.isDarkMode
                    ? Colors.white.withOpacity(0.25)
                    : const Color(0xFF6366F1).withOpacity(0.35),
                width: 1.5,
              )
                  : null,
            ),
            child: widget.compact
                ? Icon(
              widget.icon,
              color: isHighlighted
                  ? const Color(0xFF6366F1)
                  : (widget.isDarkMode
                  ? Colors.white.withOpacity(0.7)
                  : const Color(0xFF64748B)),
              size: 20,
            )
                : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.icon,
                  color: isHighlighted
                      ? const Color(0xFF6366F1)
                      : (widget.isDarkMode
                      ? Colors.white.withOpacity(0.7)
                      : const Color(0xFF64748B)),
                  size: 20,
                ),
                if (widget.label.isNotEmpty) ...[
                  const SizedBox(width: 10),
                  Text(
                    widget.label,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight:
                      isHighlighted ? FontWeight.w600 : FontWeight.w500,
                      color: isHighlighted
                          ? const Color(0xFF6366F1)
                          : (widget.isDarkMode
                          ? Colors.white.withOpacity(0.7)
                          : const Color(0xFF64748B)),
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}