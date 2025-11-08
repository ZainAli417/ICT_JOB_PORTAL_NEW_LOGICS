// lib/screens/admin_login.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'admin_login_provider.dart';

class AdminLoginScreen extends StatelessWidget {
  const AdminLoginScreen({super.key});

  static const Color accent = Color(0xFF0A84FF); // vibrant Apple-like blue
  static const Color bgStart = Color(0xFFF6F7FB);
  static const Color bgEnd = Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgStart,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 980),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Left: Illustration / marketing-like area (optional)
                  Expanded(
                    flex: 4,
                    child: _LeftMarketingColumn(accent: accent),
                  ),

                  const SizedBox(width: 48),

                  // Right: Login card
                  Expanded(
                    flex: 3,
                    child: _LoginCard(accent: accent),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LeftMarketingColumn extends StatelessWidget {
  const _LeftMarketingColumn({required this.accent});
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // subtle logo
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.shield_rounded, color: accent, size: 20),
            ),
            const SizedBox(width: 12),
            Text('Admin Console', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 28),

        Text(
          'Welcome back —\nmanage users, view analytics,\nand keep the platform secure.',
          style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w700, height: 1.05),
        ),
        const SizedBox(height: 18),
        Text(
          'Sign in with your administrator account to access the admin dashboard.',
          style: GoogleFonts.poppins(fontSize: 15, color: Colors.grey.shade700),
        ),

        const SizedBox(height: 30),
        // small stats/cards to mimic Apple-like elegance
        Row(
          children: [
            _MiniStat(title: 'Active Users', value: '12.3k', accent: accent),
            const SizedBox(width: 12),
            _MiniStat(title: 'Jobs', value: '1.2k', accent: Colors.teal),
          ],
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.title, required this.value, required this.accent});
  final String title;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade700)),
        const SizedBox(height: 6),
        Text(value, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

class _LoginCard extends StatelessWidget {
  const _LoginCard({required this.accent});
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AdminAuthProvider>();

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Color(0xff5C738A)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 30, offset: const Offset(0, 12))],
        ),
        child: Form(
          // we use a Form to enable classic validation patterns (but provider has validation too)
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.lock_outline, color: accent, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Administrator Sign In',
                      style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Email field
              _ElegantTextField(
                label: 'Email',
                hint: 'admin@company.com',
                icon: Icons.mail_outline_rounded,
                controller: prov.emailController,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 12),

              // Password field
              _ElegantTextField(
                label: 'Password',
                hint: 'Your secure password',
                icon: Icons.lock_outline_rounded,
                controller: prov.passwordController,
                obscure: prov.obscurePassword,
                suffix: IconButton(
                  icon: Icon(prov.obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: Colors.grey.shade600),
                  onPressed: prov.toggleObscure,
                ),
              ),

              const SizedBox(height: 12),

              // Error message
              if (prov.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Color(0xFFEF4444)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(prov.errorMessage!, style: GoogleFonts.poppins(color: Colors.red.shade700)),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 4),

              // Actions row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: prov.isLoading
                        ? null
                        : () {
                      // TODO: show recover dialog or navigate to forgot pw screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Password recovery not implemented')),
                      );
                    },
                    child: Text('Forgot password?', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  ),

                  // Sign In button
                  ElevatedButton(
                    onPressed: prov.isLoading
                        ? null
                        : () async {
                      final success = await prov.signIn();
                      if (success) {
                        // Navigate to admin dashboard
                        if (context.mounted) context.go('/admin_dashboard');
                      } else {
                        // show snackbar if errorMessage present
                        if (prov.errorMessage != null && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(prov.errorMessage!)),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      if (prov.isLoading) ...[
                        SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white)),
                        const SizedBox(width: 12),
                        Text('Signing in...', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                      ] else ...[
                        Text('Sign in', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, size: 18),
                      ]
                    ]),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Tiny footer
              Row(
                children: [
                  Text('Secure login • Firebase Auth', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Minimal, styled text field for the login card
class _ElegantTextField extends StatelessWidget {
  const _ElegantTextField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    this.obscure = false,
    this.suffix,
    this.keyboardType,
  });

  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final bool obscure;
  final Widget? suffix;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade700, fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.grey.shade600),
          suffixIcon: suffix,
          filled: true,
          fillColor: const Color(0xFFF7F8FB),
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      ),
    ]);
  }
}
