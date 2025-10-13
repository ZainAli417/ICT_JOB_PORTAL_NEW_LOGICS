// top_nav.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:job_portal/Screens/Recruiter/sidebar_provider.dart';
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

class _Recruiter_MainLayoutState extends State<Recruiter_MainLayout> {
  final Color _textPrimary = Color(0xFF1E293B);
  final Color _textSecondary = Color(0xFF64748B);
  final Color _borderColor = Color(0xFFE2E8F0);
  final Color _hoverColor = Color(0xFFF1F5F9);
  bool _isDarkMode = false;
  int? _activeMenu;

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
    final initials = context.watch<R_TopNavProvider>().initials;

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
          // Logo
          Image.asset(
            'images/logo_main.png',
            height:60, // was fontSize: 20, so roughly similar visual height
            fit: BoxFit.cover,
          ),
          const Spacer(),

          // Navigation Items
          _buildNavItem(
            icon: Icons.dashboard_outlined,
            label: 'Dashboard',
            isActive: widget.activeIndex == 0,
            onTap: () {
              if (widget.activeIndex != 0) context.go('/recruiter-dashboard');
            },
          ),
  _buildNavItem(
            icon: Icons.post_add_rounded,
            label: 'Post A Job',
            isActive: widget.activeIndex == 1,
            onTap: () {
              if (widget.activeIndex != 1) context.go('/job-posting');
            },
          ),


          const SizedBox(width: 16),

          _buildNavItem(
            icon: Icons.file_copy,
            label: 'View Applications',
            isActive: widget.activeIndex == 2,
            onTap: () {
              if (widget.activeIndex != 2) context.go('/view-applications');
            },
          ),
          const SizedBox(width: 16),

          _buildNavItem(
            icon: Icons.broadcast_on_home_rounded,
            label: 'Interviews',
            isActive: widget.activeIndex == 3,
            onTap: () {
              if (widget.activeIndex != 3) context.go('/interviews');
            },
          ),
          const SizedBox(width: 16),

          _buildNavItem(
            icon: Icons.notifications_none,
            label: 'Settings',
            isActive: widget.activeIndex == 4,
            onTap: () {
              if (widget.activeIndex != 4) context.go('/settings');
            },
          ),

          const SizedBox(width: 32),

          // Action Buttons
          _buildPrimaryActionButton(
            text: 'Post a Job',
            icon: Icons.add_circle_outline_rounded,
            onPressed: () => print('Navigate to Post Job page'),
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

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          height: 35,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isActive ? primaryColor.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isActive ? primaryColor : unselectedColor,
                size: 25,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isActive ? primaryColor : unselectedColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryActionButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
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
                      style: GoogleFonts.inter(
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
            initials.isNotEmpty ? initials : 'RC',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
      itemBuilder: (context) => [
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
                  style: GoogleFonts.inter(
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
              style: GoogleFonts.inter(
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

  void _showQuickLinks(BuildContext context) => print('Showing Quick Links menu');
  void _showHelpCenter(BuildContext context) => print('Showing Help Center');

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Confirm Logout', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        content: Text('Are you sure you want to logout?', style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
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