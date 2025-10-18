// top_nav_styled.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:job_portal/Screens/Recruiter/R_Initials_provider.dart';
import 'package:provider/provider.dart';

import 'JS_Initials_provider.dart';

class MainLayout extends StatefulWidget {
  final Widget child;
  final int activeIndex;
  @override
  final Key? key;

  const MainLayout({
    this.key,
    required this.child,
    required this.activeIndex,
  }) : super(key: key);

  @override
  State<MainLayout> createState() => MainLayoutState();
}

class MainLayoutState extends State<MainLayout> {
  final Color _textPrimary = Color(0xFF1E293B);
  final Color _textSecondary = Color(0xFF64748B);
  final Color _borderColor = Color(0xFFE2E8F0);
  final Color _hoverColor = Color(0xFFF1F5F9);
  bool _isDarkMode = false;
  int? _activeMenu;

  // local hover state for the Recruiter CTA
  bool _isRecruiterHovered = false;

  Color get _iconColor => _isDarkMode ? Colors.grey.shade400 : _textSecondary;
  Color get _iconHoverBg => _isDarkMode ? Colors.grey.shade800 : _hoverColor;
  Color get _appBarBg => _isDarkMode ? Color(0xFF1E1E1E) : Color(0xFFF4F4F4);
  Color get _appBarBorder => _isDarkMode ? Colors.grey.shade800 : _borderColor;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<R_TopNavProvider>(
      create: (_) => R_TopNavProvider(),
      child: RepaintBoundary(child: _buildScaffold(context)),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final initials = context.watch<JS_TopNavProvider>().initials;

    return Scaffold(
      backgroundColor: Color(0xFFFAFAFA),
      body: Column(
        children: [
          _buildHeaderTopBar(primaryColor, initials),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.0, 0.1),
                      end: Offset.zero,
                    ).animate(animation),
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

  Widget _buildHeaderTopBar(Color primaryColor, String initials) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: _appBarBg,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        border: Border(
          bottom: BorderSide(color: _appBarBorder, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          // MAHA SERVICES block (replicated styling from your HeaderNav)
          _MahaServicesLogo(),

          const Spacer(),

          // Navigation Items
          _buildNavItem(
            icon: Icons.dashboard_outlined,
            label: 'Dashboard',
            isActive: widget.activeIndex == 0,
            onTap: () {
              if (widget.activeIndex != 0) {
                context.go('/dashboard');
              }
            },

          ),
          const SizedBox(width: 16),

          _buildNavItem(
            icon: Icons.person_outline,
            label: 'Profile',
            isActive: widget.activeIndex == 1,
            onTap: () {
              if (widget.activeIndex != 1) {
                context.go('/profile');
              }
            },
          ),
          const SizedBox(width: 16),

          _buildNavItem(

            icon: Icons.work_history_outlined,
            label: 'Job Application',
            isActive: widget.activeIndex == 2,
            onTap: () {
              if (widget.activeIndex != 2) {
                context.go('/saved');
              }
            },
          ),
          const SizedBox(width: 16),

          _buildNavItem(
            icon: Icons.notifications_none,
            label: 'Job Alerts',
            isActive: widget.activeIndex == 3,
            onTap: () {
              if (widget.activeIndex != 3) {
                context.go('/alerts');
              }
            },

          ),




          const SizedBox(width: 16),

          _buildIconButton(
            tooltip: 'Quick Links',
            icon: Icons.apps_rounded,
            onPressed: () => _showQuickLinks(context),
            isActive: _activeMenu == 2,
          ),

          const SizedBox(width: 8),

          _buildIconButton(
            tooltip: 'Notifications',
            icon: Icons.notifications_none_rounded,
            activeIcon: Icons.notifications_rounded,
            onPressed: () => setState(() => _activeMenu = 0),
            badge: 3,
            isActive: _activeMenu == 0,
          ),

          const SizedBox(width: 8),

          _buildIconButton(
            tooltip: 'Messages',
            icon: Icons.chat_bubble_outline_rounded,
            activeIcon: Icons.chat_bubble_rounded,
            onPressed: () => setState(() => _activeMenu = 1),
            isActive: _activeMenu == 1,
          ),

          VerticalDivider(
            color: _appBarBorder,
            width: 24,
            thickness: 1,
            indent: 10,
            endIndent: 10,
          ),

          _buildIconButton(
            tooltip: 'Help & Support',
            icon: Icons.help_outline_rounded,
            onPressed: () => _showHelpCenter(context),
          ),

          const SizedBox(width: 8),

          _buildIconButton(
            tooltip: _isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            icon: _isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            onPressed: () => setState(() => _isDarkMode = !_isDarkMode),
          ),

          const SizedBox(width: 16),

          // MAJOR CTA: For Recruiters (uses amber -> pink subtle gradient styling from your saved prefs)
          _buildRecruiterCTA(),

          const SizedBox(width: 16),

          _buildProfileMenu(primaryColor, initials),
          const SizedBox(width: 16),

          _buildLogoutButton(),


        ],
      ),
    );
  }
  Widget _buildLogoutButton() {
    return _HorizontalLogoutButton(
      onTap: () => _showLogoutDialog(context),
    );
  }



  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final primaryColor = Theme.of(context).primaryColor;
    final unselectedColor = const Color(0xFF5C738A);
    final indigo = const Color(0xFF6366F1);

    // local hover notifier so we don't change widget-level state
    final hover = ValueNotifier<bool>(false);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ValueListenableBuilder<bool>(
        valueListenable: hover,
        builder: (context, isHovered, _) {
          final showHighlight = isHovered || isActive;
          return MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => hover.value = true,
            onExit: (_) => hover.value = false,
            child: GestureDetector(
              onTap: onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutSine,
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: showHighlight ? indigo.withOpacity(0.08) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: showHighlight ? indigo.withOpacity(0.18) : Colors.transparent,
                    width: showHighlight ? 1 : 0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      color: showHighlight ? indigo : unselectedColor,
                      size: 25,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        // stronger weight on hover/active like your HeaderNav nav links
                        fontWeight: showHighlight ? FontWeight.w600 : FontWeight.w500,
                        color: showHighlight ? const Color(0xFF1F2937) : unselectedColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }


  Widget _buildIconButton({
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
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isHighlighted ? _iconHoverBg : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isActive ? (activeIcon ?? icon) : icon,
                    color: isActive ? Theme.of(context).primaryColor : _iconColor,
                    size: 24,
                  ),
                ),
              ),
              if (badge != null && badge > 0)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red.shade500,
                      shape: BoxShape.circle,
                      border: Border.all(color: _appBarBg, width: 2),
                    ),
                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                    child: Text(
                      badge.toString(),
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
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
          border: Border.all(color: _borderColor, width: 2),
        ),
        child: CircleAvatar(
          radius: 18,
          backgroundColor: primaryColor,
          child: Text(
            initials.isNotEmpty ? initials : 'JS',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
      itemBuilder: (context) => [
        _buildPopupMenuItem('Profile', Icons.person_outline_rounded, () => context.go('/profile')),
        _buildPopupMenuItem('Settings', Icons.settings_outlined, () => context.go('/')),
        _buildPopupMenuItem('Help', Icons.help_outline_rounded, () {}),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'logout',
          onTap: () => _showLogoutDialog(context),
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

  PopupMenuItem<String> _buildPopupMenuItem(String title, IconData icon, VoidCallback onTap, {bool isDestructive = false}) {
    return PopupMenuItem<String>(
      value: title.toLowerCase(),
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 18, color: isDestructive ? Colors.red.shade500 : _textSecondary),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDestructive ? Colors.red.shade500 : _textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Lightweight recruiter CTA replicating the "For Recruiters" styling you memorized
  Widget _buildRecruiterCTA() {
    return MouseRegion(
      onEnter: (_) => setState(() => _isRecruiterHovered = true),
      onExit: (_) => setState(() => _isRecruiterHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => context.go('/recruiter-signup'),
        child: AnimatedScale(
          scale: _isRecruiterHovered ? 1.03 : 1.0,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              // subtle light overlay + amber->pink icon gradient like your saved style
              color: _isRecruiterHovered ? Color(0xFFFDF7F0) : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFFF59E0B).withOpacity(0.25),
                width: 1.2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF59E0B), Color(0xFFEC4899)],
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.business_center_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'For Recruiters',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: const Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showQuickLinks(BuildContext context) => print('Showing Quick Links menu');
  void _showHelpCenter(BuildContext context) => print('Showing Help Center');

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Confirm Logout', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text('Are you sure you want to logout?', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              context.pushReplacement('/');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
/// Horizontal logout button for the top navigation bar
class _HorizontalLogoutButton extends StatefulWidget {
  final VoidCallback onTap;

  const _HorizontalLogoutButton({
    required this.onTap,
  });

  @override
  State<_HorizontalLogoutButton> createState() => _HorizontalLogoutButtonState();
}

class _HorizontalLogoutButtonState extends State<_HorizontalLogoutButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final unselectedColor = Color(0xFFFAFAFA);

    Color bgColor() {
      if (_isHovered) return Colors.red.shade50;
      return Colors.transparent;
    }

    Color iconColor() {
      if (_isHovered) return Colors.red.shade600;
      return unselectedColor;
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 150),
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: bgColor(),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.logout_rounded,
            color: iconColor(),
            size: 20,
          ),
        ),
      ),
    );
  }
}


// Lightweight MAHA SERVICES logo widget (replicated look from your HeaderNav but static so it fits easily here)
class _MahaServicesLogo extends StatelessWidget {
  const _MahaServicesLogo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.auto_awesome_outlined, color: Colors.white, size: 26),
        ),
        const SizedBox(width: 14),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Maha Services',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
                letterSpacing: 0.4,
              ),
            ),
            Text(
              'Professional Excellence',
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w300,
                color: Color(0xFF1E293B).withOpacity(0.6),
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
