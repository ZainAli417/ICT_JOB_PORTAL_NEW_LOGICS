// lib/screens/signup_panels.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:job_portal/SignUp%20/signup_provider.dart';
import 'package:provider/provider.dart';
import '../extractor_CV/cv_extraction_UI.dart';
import '../extractor_CV/cv_extractor.dart';
import 'signup_widgets.dart';

class SignupPanels {
  final dynamic state;
  final GlobalKey<FormState> formKeyAccount;
  final GlobalKey<FormState> personalFormKey;
  final GlobalKey<FormState> educationFormKey;
  final TextEditingController editInstitution;
  final TextEditingController editDuration;
  final TextEditingController editMajor;
  final TextEditingController editMarks;
  final GlobalKey cvSectionKey;
  final CvExtractor extractor;
  final _educationFormKey = GlobalKey<FormState>();

  final _editInstitution = TextEditingController();
  final _editDuration = TextEditingController();
  final _editMajor = TextEditingController();
  final _editMarks = TextEditingController();

  SignupPanels({
    required this.state,
    required this.formKeyAccount,
    required this.personalFormKey,
    required this.educationFormKey,
    required this.editInstitution,
    required this.editDuration,
    required this.editMajor,
    required this.editMarks,
    required this.cvSectionKey,
    required this.extractor,
  });
  void _showSnackBar(BuildContext context, String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isError
                    ? Icons.error_outline_rounded
                    : Icons.check_circle_outline_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
        margin: const EdgeInsets.all(16),
        duration: Duration(milliseconds: isError ? 3500 : 2500),
      ),
    );
  }


  Widget _buildEnhancedTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? errorText,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLines: maxLines,
          onChanged: onChanged,
          validator: validator,
          style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
              color: Colors.grey.shade400,
              fontSize: 14,
            ),
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF6366F1).withOpacity(0.15),
                    const Color(0xFF8B5CF6).withOpacity(0.15),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF6366F1), size: 20),
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.red.shade300, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.red.shade400, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
            errorText: errorText,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required bool isPrimary,
    required VoidCallback onPressed,
  }) {
    if (isPrimary) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 18),
          label: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      );
    }
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(
        label,
        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        side: BorderSide(color: Colors.grey.shade400, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        foregroundColor: Colors.grey.shade700,
      ),
    );
  }

  Widget _buildFieldWrapper({required int flex, required Widget child}) {
    return _FieldWrapper(flex: flex, child: child);
  }

  Widget _buildFieldRow({
    required bool isNarrow,
    required List<Widget> children,
  }) {
    if (isNarrow) {
      return Column(
        children: children.map((child) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: child,
          );
        }).toList(),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children.map((child) {
        final isLast = children.indexOf(child) == children.length - 1;
        return Expanded(
          flex: (child as _FieldWrapper).flex,
          child: Padding(
            padding: EdgeInsets.only(right: isLast ? 0 : 12),
            child: child.child,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAvatarCompact(SignupProvider p) {
    Widget avatarPreview() {
      if (p.profilePicBytes != null) {
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withOpacity(0.2),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 56,
            backgroundColor: Colors.grey.shade100,
            backgroundImage: MemoryImage(p.profilePicBytes!),
          ),
        );
      }

      if (p.imageDataUrl != null) {
        try {
          final bytes = base64Decode(p.imageDataUrl!.split(',').last);
          return Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withOpacity(0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 56,
              backgroundColor: Colors.grey.shade100,
              backgroundImage: MemoryImage(bytes),
            ),
          );
        } catch (_) {
          // fallthrough to placeholder if decode fails
        }
      }

      // placeholder avatar
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Colors.indigo.shade50, Colors.indigo.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.indigo.shade100,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: CircleAvatar(
          radius: 56,
          backgroundColor: Colors.transparent,
          child: Icon(
            Icons.person_outline_rounded,
            size: 48,
            color: Colors.indigo.shade400,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        border: Border.all(color: Colors.indigo.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          avatarPreview(),
          const SizedBox(height: 16),
          Text(
            'Profile Photo',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _buildActionButton(
                label: p.profilePicBytes == null && p.imageDataUrl == null
                    ? 'Upload'
                    : 'Change',
                icon: Icons.upload_file_rounded,
                isPrimary: true,
                onPressed: () async {
                  await p.pickProfilePicture();
                  if (p.personalVisibleIndex == 4) p.revealNextPersonalField();
                },
              ),
              if (p.profilePicBytes != null || p.imageDataUrl != null)
                _buildActionButton(
                  label: 'Remove',
                  icon: Icons.delete_outline_rounded,
                  isPrimary: false,
                  onPressed: () => p.removeProfilePicture(),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsCompact(SignupProvider p) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        border: Border.all(color: Colors.indigo.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.indigo.shade400, Colors.indigo.shade600],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.lightbulb_outline_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Skills',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${p.skills.length} added',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.indigo.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (p.skills.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: p.skills.asMap().entries.map((e) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.indigo.shade50,
                        Colors.indigo.shade100.withOpacity(0.5),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.indigo.shade200, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        e.value,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.indigo.shade900,
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => p.removeSkillAt(e.key),
                        child: Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: Colors.indigo.shade600,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.indigo.shade100),
            ),
            child: TextField(
              controller: p.skillInputController,
              textInputAction: TextInputAction.done,
              style: GoogleFonts.poppins(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Type skill and press Enter',
                hintStyle: GoogleFonts.poppins(
                  color: Colors.grey.shade400,
                  fontSize: 13,
                ),
                prefixIcon: Icon(
                  Icons.add_circle_outline_rounded,
                  color: Colors.indigo.shade600,
                  size: 22,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              onChanged: (v) => p.onFieldTypedAutoReveal(5, v),
              onSubmitted: (v) {
                if (v.trim().isNotEmpty) {
                  p.addSkill(v);
                  p.skillInputController.clear();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDobCompact(BuildContext context, SignupProvider p) {
    return Container(
      height: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        border: Border.all(color: Colors.orange.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange.shade400, Colors.orange.shade600],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.cake_outlined,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Date of Birth',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            p.dob == null ? 'Not selected' : DateFormat.yMMMMd().format(p.dob!),
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: p.dob == null
                  ? Colors.grey.shade500
                  : const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () async {
                final now = DateTime.now();
                final initial = DateTime(now.year - 22);
                final picked = await showDatePicker(
                  context: context,
                  initialDate: initial,
                  firstDate: DateTime(1900),
                  lastDate: DateTime(now.year - 13),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.light(
                          primary: const Color(0xFF6366F1),
                          onPrimary: Colors.white,
                          surface: Colors.white,
                          onSurface: Colors.black,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) p.setDob(picked);
              },
              icon: Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: Colors.orange.shade700,
              ),
              label: Text(
                'Select Date',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange.shade700,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                backgroundColor: Colors.orange.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF3949AB)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3949AB).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(icon, color: Colors.white, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDialogTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      style: GoogleFonts.poppins(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(fontSize: 13),
        prefixIcon: Icon(icon, size: 20, color: const Color(0xFF6366F1)),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3949AB), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  void _showAddEducationDialog(BuildContext context, SignupProvider p) {
    final inst = TextEditingController();
    final dur = TextEditingController();
    final major = TextEditingController();
    final marks = TextEditingController();

    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF3949AB)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.school, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'Add Education',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Form(
            key: _educationFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDialogTextField(
                  controller: inst,
                  label: 'Institution / University',
                  icon: Icons.account_balance,
                ),
                const SizedBox(height: 16),
                _buildDialogTextField(
                  controller: dur,
                  label: 'Duration (e.g. 2017-2021)',
                  icon: Icons.calendar_today,
                ),
                const SizedBox(height: 16),
                _buildDialogTextField(
                  controller: major,
                  label: 'Major Subjects',
                  icon: Icons.book,
                ),
                const SizedBox(height: 16),
                _buildDialogTextField(
                  controller: marks,
                  label: 'Marks / CGPA',
                  icon: Icons.grade,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(c).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (inst.text.trim().isEmpty ||
                  dur.text.trim().isEmpty ||
                  major.text.trim().isEmpty ||
                  marks.text.trim().isEmpty) {
                _showSnackBar(
                  context,
                  'Please fill all education fields',
                  isError: true,
                );
                return;
              }
              p.addEducation(
                institutionName: inst.text,
                duration: dur.text,
                majorSubjects: major.text,
                marksOrCgpa: marks.text,
              );
              Navigator.of(c).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              'Add',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // ========== NAVIGATION BUTTONS ==========
  Widget _buildNavigationButtons({
    required BuildContext context,
    VoidCallback? onBack,
    VoidCallback? onNext,
    String nextLabel = 'Continue',
  }) {
    return Row(
      children: [
        if (onBack != null) ...[
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded),
              label: Text(
                'Back',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                side: BorderSide(color: Colors.grey.shade300, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                foregroundColor: Colors.grey.shade700,
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          flex: onBack != null ? 2 : 1,
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF3949AB)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3949AB).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onNext,
                borderRadius: BorderRadius.circular(12),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        nextLabel,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ========== ACCOUNT PANEL ==========
  Widget accountPanel(BuildContext context, SignupProvider p) {
    final provider = context.watch<SignupProvider>();

    return Form(
      key: formKeyAccount,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderSection(
            title: 'Create Account',
            subtitle: 'Start your journey to find the perfect opportunity',
            icon: Icons.account_circle_outlined,
          ),
          const SizedBox(height: 28),
          _buildRoleSelector(p),
          const SizedBox(height: 28),
          if (provider.role == 'recruiter')
            ..._buildRecruiterFlow(context, provider)
          else
            ..._buildJobSeekerFlow(context, p),
        ],
      ),
    );
  }

  List<Widget> _buildRecruiterFlow(BuildContext context, SignupProvider p) {
    return [
      _buildEnhancedTextField(
        controller: p.nameController,
        label: 'Full Name',
        hint: 'Enter your full name',
        icon: Icons.person_outline_rounded,
        validator: (v) =>
        (v == null || v.trim().isEmpty) ? 'Name required' : null,
      ),
      const SizedBox(height: 18),
      _buildEnhancedTextField(
        controller: p.emailController,
        label: 'Email Address',
        hint: 'your.email@company.com',
        icon: Icons.email_outlined,
        keyboardType: TextInputType.emailAddress,
        errorText: p.emailError,
        validator: (v) {
          if (v == null || v.trim().isEmpty) return 'Email required';
          final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
          if (!emailRegex.hasMatch(v.trim())) return 'Enter valid email';
          return null;
        },
      ),
      const SizedBox(height: 18),
      _buildEnhancedTextField(
        controller: p.passwordController,
        label: 'Password',
        hint: 'Create a strong password (min. 8 characters)',
        icon: Icons.lock_outline_rounded,
        obscureText: true,
        errorText: p.passwordError,
        validator: (v) {
          if (v == null || v.isEmpty) return 'Password required';
          if (v.length < 8) return 'Minimum 8 characters';
          return null;
        },
      ),
      const SizedBox(height: 18),
      _buildEnhancedTextField(
        controller: p.confirmPasswordController,
        label: 'Confirm Password',
        hint: 'Re-enter your password',
        icon: Icons.lock_outline_rounded,
        obscureText: true,
        errorText: p.passwordError,
        validator: (v) {
          if (v == null || v.isEmpty) return 'Confirm your password';
          if (v != p.passwordController.text) return 'Passwords must match';
          return null;
        },
      ),
      const SizedBox(height: 32),
      Center(
        child: Container(
          width: 280,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: () => p.registerRecruiter(),
            icon: const Icon(Icons.person_add_rounded, size: 20),
            label: Text(
              'Create Recruiter Account',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.white,
                fontSize: 15,
              ),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ),
      const SizedBox(height: 20),
    ];
  }

  List<Widget> _buildJobSeekerFlow(BuildContext context, SignupProvider p) {
    return [
      _buildEnhancedTextField(
        controller: p.emailController,
        label: 'Email Address',
        hint: 'your.email@example.com',
        icon: Icons.email_outlined,
        keyboardType: TextInputType.emailAddress,
        errorText: p.emailError,
        validator: (v) {
          if (v == null || v.trim().isEmpty) return 'Email required';
          final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
          if (!emailRegex.hasMatch(v.trim())) return 'Enter valid email';
          return null;
        },
      ),
      const SizedBox(height: 18),
      _buildEnhancedTextField(
        controller: p.passwordController,
        label: 'Password',
        hint: 'Create a strong password (min. 8 characters)',
        icon: Icons.lock_outline_rounded,
        obscureText: true,
        errorText: p.passwordError,
        validator: (v) {
          if (v == null || v.isEmpty) return 'Password required';
          if (v.length < 8) return 'Minimum 8 characters';
          return null;
        },
      ),
      const SizedBox(height: 18),
      _buildEnhancedTextField(
        controller: p.confirmPasswordController,
        label: 'Confirm Password',
        hint: 'Re-enter your password',
        icon: Icons.lock_outline_rounded,
        obscureText: true,
        errorText: p.passwordError,
        validator: (v) {
          if (v == null || v.isEmpty) return 'Confirm your password';
          if (v != p.passwordController.text) return 'Passwords must match';
          return null;
        },
      ),
      const SizedBox(height: 28),
      _buildCvUploadSection(context, p),
    ];
  }

  Widget _buildCvUploadSection(BuildContext context, SignupProvider p) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.indigo.shade50,
            Colors.purple.shade50.withOpacity(0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.indigo.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.indigo.shade500, Colors.purple.shade500],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.description_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Do you have a CV/Resume?',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Upload for faster registration',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  label: 'Upload CV',
                  icon: Icons.upload_file_rounded,
                  isPrimary: false,
                  onPressed: () {
                    p.revealCvUpload(reveal: true);
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      final ctx = cvSectionKey.currentContext;
                      if (ctx != null) {
                        Scrollable.ensureVisible(
                          ctx,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      }
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  label: 'Continue Manually',
                  icon: Icons.arrow_forward_rounded,
                  isPrimary: true,
                  onPressed: () => p.submitAllAndCreateAccount(),
                ),
              ),
            ],
          ),
          Consumer<SignupProvider>(
            builder: (_, provider, __) {
              if (!provider.showCvUploadSection) return const SizedBox.shrink();

              return Container(
                key: cvSectionKey,
                margin: const EdgeInsets.only(top: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.indigo.shade100),
                ),
                child: CvUploadSection(
                  extractor: extractor,
                  provider: provider,
                  onSuccess: () {
                    context.go('/login');
                  },
                  onManualContinue: () {
                    provider.revealCvUpload(reveal: false);
                    provider.revealNextPersonalField();
                    provider.goToStep(1);
                    state._animateStepChange();
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ========== PERSONAL PANEL ==========
  Widget personalPanel(BuildContext context, SignupProvider p) {
    final progress = p.computeProgress();

    return Form(
      key: personalFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderSection(
            title: 'Personal Profile',
            subtitle: 'Tell us about yourself and showcase your expertise',
            icon: Icons.person_outline_rounded,
            progress: progress,
          ),
          const SizedBox(height: 24),
          _buildPersonalFields(context, p),
          const SizedBox(height: 32),
          _buildNavigationButtons(
            context: context,
            onBack: () {
              p.goToStep(0);
              state._animateStepChange();
            },
            onNext: () => p.revealNextPersonalField(),
            nextLabel: 'Next: Education',
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalFields(BuildContext context, SignupProvider p) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 720;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFieldRow(
                isNarrow: isNarrow,
                children: [
                  if (p.personalVisibleIndex >= 0)
                    _buildFieldWrapper(
                      flex: 2,
                      child: _buildEnhancedTextField(
                        controller: p.nameController,
                        label: 'Full Name',
                        hint: 'Enter your full name',
                        icon: Icons.person_outline_rounded,
                        onChanged: (v) => p.onFieldTypedAutoReveal(0, v),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Name required'
                            : null,
                      ),
                    ),
                  if (p.personalVisibleIndex >= 1)
                    _buildFieldWrapper(
                      flex: 2,
                      child: _buildEnhancedTextField(
                        controller: p.contactNumberController,
                        label: 'Contact Number',
                        hint: '+92 300 1234567',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        onChanged: (v) => p.onFieldTypedAutoReveal(1, v),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty)
                            return 'Contact required';
                            final phoneRegex = RegExp(
                          r'^[\d\+\-\s]{5,20}$',
                          );
                              if (!phoneRegex.hasMatch(v.trim()))
                          return 'Enter valid number';
                          return null;
                          },
                      ),
                    ),
                  if (p.personalVisibleIndex >= 2)
                    _buildFieldWrapper(
                      flex: 2,
                      child: _buildEnhancedTextField(
                        controller: p.nationalityController,
                        label: 'Nationality',
                        hint: 'e.g., Pakistani',
                        icon: Icons.flag_outlined,
                        onChanged: (v) => p.onFieldTypedAutoReveal(2, v),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Nationality required'
                            : null,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              if (p.personalVisibleIndex >= 3)
                _buildEnhancedTextField(
                  controller: p.summaryController,
                  label: 'Professional Summary',
                  hint: 'Brief description of your background and expertise',
                  icon: Icons.article_outlined,
                  maxLines: 3,
                  onChanged: (v) => p.onFieldTypedAutoReveal(3, v),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Summary required'
                      : null,
                ),
              const SizedBox(height: 16),
              if (p.personalVisibleIndex >= 4)
                _buildFieldRow(
                  isNarrow: isNarrow,
                  children: [
                    _buildFieldWrapper(flex: 3, child: _buildAvatarCompact(p)),
                    _buildFieldWrapper(flex: 4, child: _buildSkillsCompact(p)),
                  ],
                ),
              const SizedBox(height: 16),
              if (p.personalVisibleIndex >= 5)
                _buildFieldRow(
                  isNarrow: isNarrow,
                  children: [
                    _buildFieldWrapper(
                      flex: 6,
                      child: _buildEnhancedTextField(
                        controller: p.objectivesController,
                        label: 'Career Objectives',
                        hint: 'What are your career goals?',
                        icon: Icons.flag_circle_rounded,
                        maxLines: 3,
                        onChanged: (v) => p.onFieldTypedAutoReveal(5, v),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Objectives required'
                            : null,
                      ),
                    ),
                    _buildFieldWrapper(flex: 2, child: _buildDobCompact(context, p)),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  // ========== EDUCATION PANEL ==========
  Widget educationPanel(BuildContext context, SignupProvider p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Educational Background',
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF6366F1),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Add your academic qualifications',
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 24),
        if (p.educationalProfile.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.indigo.shade50, Colors.indigo.shade50],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.indigo.shade100, width: 2),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.school_outlined,
                  size: 48,
                  color: Colors.indigo.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  'No education added yet',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.indigo.shade900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add at least one education entry to continue',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        if (p.educationalProfile.isNotEmpty)
          ...p.educationalProfile.asMap().entries.map((entry) {
            final idx = entry.key;
            final data = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, Colors.indigo.shade50],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.indigo.shade100),
                boxShadow: [
                  BoxShadow(
                    color: Colors.indigo.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF3949AB)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                title: Text(
                  data['institutionName'] ?? '',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['majorSubjects'] ?? '',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 12,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            data['duration'] ?? '',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.grade,
                            size: 12,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            data['marksOrCgpa'] ?? '',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => _showEditEducationDialog( p, idx, data),
                      icon: Icon(
                        Icons.edit_outlined,
                        color: Colors.indigo.shade700,
                      ),
                      tooltip: 'Edit',
                    ),
                    IconButton(
                      onPressed: () => p.removeEducation(idx),
                      icon: Icon(
                        Icons.delete_outline,
                        color: Colors.red.shade400,
                      ),
                      tooltip: 'Delete',
                    ),
                  ],
                ),
              ),
            );
          }),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: _buildGradientButton(
            label: 'Add Education',
            icon: Icons.add_rounded,
            onPressed: () => _showAddEducationDialog(context, p),
          ),
        ),
        const SizedBox(height: 32),
        _buildNavigationButtons(
          context: context,
          onBack: () {
            p.goToStep(1);
            state._animateStepChange();
          },
          onNext: () {
            if (!p.educationSectionIsComplete()) {
              _showSnackBar(
                context,
                'Please add at least one education entry',
                isError: true,
              );
              return;
            }
            p.goToStep(3);
            state._animateStepChange();
          },
          nextLabel: 'Review & Submit',
        ),
      ],
    );
  }

  // ========== REVIEW PANEL ==========
  Widget reviewPanel(BuildContext context, SignupProvider p) {
    Widget avatarCard() {
      if (p.profilePicBytes != null) {
        return CircleAvatar(
          radius: 70,
          backgroundColor: Colors.grey.shade100,
          backgroundImage: MemoryImage(p.profilePicBytes!),
        );
      }
      if (p.imageDataUrl != null) {
        try {
          final bytes = base64Decode(p.imageDataUrl!.split(',').last);
          return CircleAvatar(
            radius: 70,
            backgroundColor: Colors.grey.shade100,
            backgroundImage: MemoryImage(bytes),
          );
        } catch (_) {}
      }
      return CircleAvatar(
        radius: 70,
        backgroundColor: Colors.indigo.shade50,
        child: Icon(
          Icons.person_outline_rounded,
          size: 60,
          color: Colors.indigo.shade300,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Review & Submit',
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF6366F1),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Review your information before submitting',
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade600),
        ),

        const SizedBox(height: 24),

        // Profile Overview Card
        RepaintBoundary(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Colors.indigo.shade50],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.indigo.shade100, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.indigo.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Avatar and Name Section
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.indigo.withOpacity(0.2),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: avatarCard(),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6366F1), Color(0xFF3949AB)],
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  p.role == 'job_seeker'
                                      ? Icons.person_search_rounded
                                      : Icons.business_center_rounded,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  p.role == 'job_seeker'
                                      ? 'Job Seeker'
                                      : 'Recruiter',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    p.nameController.text.trim(),
                                    style: GoogleFonts.poppins(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF6366F1),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    p.goToStep(1);
                                  },
                                  icon: Icon(
                                    Icons.edit_outlined,
                                    color: Colors.indigo.shade600,
                                  ),
                                  tooltip: 'Edit Personal Info',
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              p.summaryController.text.trim(),
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildInfoRow(
                              Icons.email_outlined,
                              p.emailController.text.trim(),
                            ),
                            const SizedBox(height: 8),
                            _buildInfoRow(
                              Icons.phone_outlined,
                              p.contactNumberController.text.trim(),
                            ),
                            const SizedBox(height: 8),
                            _buildInfoRow(
                              Icons.flag_outlined,
                              p.nationalityController.text.trim(),
                            ),
                            const SizedBox(height: 8),
                            _buildInfoRow(
                              Icons.cake_outlined,
                              p.dob == null
                                  ? 'Not set'
                                  : DateFormat.yMMMMd().format(p.dob!),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),

                  // Skills Section
                  _buildReviewSection(
                    title: 'Skills',
                    icon: Icons.lightbulb_outlined,
                    onEdit: () {
                      p.goToStep(1);
                    },
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: p.skills.map((skill) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.indigo.shade100,
                                Colors.indigo.shade100,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.indigo.shade200),
                          ),
                          child: Text(
                            skill,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.indigo.shade900,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Objectives Section
                  _buildReviewSection(
                    title: 'Career Objectives',
                    icon: Icons.flag_circle_rounded,
                    onEdit: () {
                      p.goToStep(1);
                    },
                    child: Text(
                      p.objectivesController.text.trim(),
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                        height: 1.6,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Education Section
                  _buildReviewSection(
                    title: 'Education',
                    icon: Icons.school_outlined,
                    onEdit: () {
                      p.goToStep(2);
                    },
                    child: Column(
                      children: p.educationalProfile.map((edu) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.indigo.shade100),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF6366F1),
                                          Color(0xFF3949AB),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.school,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      edu['institutionName'] ?? '',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF6366F1),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                edu['majorSubjects'] ?? '',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 12,
                                    color: Colors.grey.shade500,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    edu['duration'] ?? '',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Icon(
                                    Icons.grade,
                                    size: 12,
                                    color: Colors.grey.shade500,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    edu['marksOrCgpa'] ?? '',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 32),

        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  p.goToStep(2);
                },
                icon: const Icon(Icons.arrow_back_rounded),
                label: Text(
                  'Back',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  side: BorderSide(color: Colors.grey.shade300, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF3949AB)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3949AB).withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: p.isLoading
                        ? null
                        : () async {
                      final ok = await p.submitAllAndCreateAccount();
                      if (ok) {
                        if (!mounted) return;
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (c) => WillPopScope(
                            onWillPop: () async => false,
                            child: AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              title: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF6366F1),
                                          Color(0xFF3949AB),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        10,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.check_circle_outline,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Finalizing Setup',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Finishing account setup...',
                                    style: GoogleFonts.poppins(),
                                  ),
                                  const SizedBox(height: 24),
                                  const CircularProgressIndicator(
                                    valueColor:
                                    AlwaysStoppedAnimation<Color>(
                                      Color(0xFF6366F1),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );

                        await Future.delayed(const Duration(seconds: 2));

                        if (Navigator.canPop(context)) {
                          Navigator.of(context).pop();
                        }

                        p.clearAll();
                        _showSnackBar(
                          context,
                          'Account created & data saved successfully',
                          isError: true,
                        );


                        // Navigate to home or login
                        // Navigator.of(context).pushReplacementNamed('/home');
                      } else {
                        if (!mounted) return;
                        _showSnackBar(
                          context,
                          p.generalError ?? 'Failed to sign up',
                          isError: true,
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Center(
                      child: p.isLoading
                          ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                          : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            color: Colors.white,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Submit & Create Account',
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
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReviewSection({
    required String title,
    required IconData icon,
    required VoidCallback onEdit,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: const Color(0xFF6366F1)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF6366F1),
                  ),
                ),
              ],
            ),
            IconButton(
              onPressed: onEdit,
              icon: Icon(Icons.edit_outlined, color: Colors.indigo.shade600),
              tooltip: 'Edit',
            ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }



  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.indigo.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: Colors.indigo.shade600),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }

  void _showEditEducationDialog(
      BuildContext context,   // ✅ ADD THIS
      SignupProvider p,
      int idx,
      Map<String, dynamic> data,
      ) {
    _editInstitution.text = data['institutionName'] ?? '';
    _editDuration.text = data['duration'] ?? '';
    _editMajor.text = data['majorSubjects'] ?? '';
    _editMarks.text = data['marksOrCgpa'] ?? '';

    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF3949AB)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.edit, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'Edit Education',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogTextField(
                controller: _editInstitution,
                label: 'Institution',
                icon: Icons.account_balance,
              ),
              const SizedBox(height: 16),
              _buildDialogTextField(
                controller: _editDuration,
                label: 'Duration',
                icon: Icons.calendar_today,
              ),
              const SizedBox(height: 16),
              _buildDialogTextField(
                controller: _editMajor,
                label: 'Major Subjects',
                icon: Icons.book,
              ),
              const SizedBox(height: 16),
              _buildDialogTextField(
                controller: _editMarks,
                label: 'Marks / CGPA',
                icon: Icons.grade,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(c).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final newEntry = {
                'institutionName': _editInstitution.text.trim(),
                'duration': _editDuration.text.trim(),
                'majorSubjects': _editMajor.text.trim(),
                'marksOrCgpa': _editMarks.text.trim(),
              };
              p.updateEducation(idx, newEntry);
              Navigator.of(c).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              'Save',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }




  // ========== HELPER WIDGETS ==========
  Widget _buildHeaderSection({
    required String title,
    required String subtitle,
    required IconData icon,
    double? progress,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6366F1).withOpacity(0.1),
            const Color(0xFF8B5CF6).withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF6366F1).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
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
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (progress != null) ...[
            const SizedBox(height: 20),
            _buildProgressIndicator(progress),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(double progress) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.indigo.shade100, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Profile Completion',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.indigo.shade900,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.indigo.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Stack(
            children: [
              Container(
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF6366F1),
                        const Color(0xFF8B5CF6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoleSelector(SignupProvider p) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildRoleChip(
              label: 'Job Seeker',
              icon: Icons.person_search_rounded,
              isSelected: p.role == 'job_seeker',
              onTap: () => p.setRole('job_seeker'),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _buildRoleChip(
              label: 'Recruiter',
              icon: Icons.business_center_rounded,
              isSelected: p.role == 'recruiter',
              onTap: () => p.setRole('recruiter'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: isSelected
            ? LinearGradient(
                colors: [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
              )
            : null,
        borderRadius: BorderRadius.circular(12),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: const Color(0xFF6366F1).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isSelected ? Colors.white : Colors.grey.shade600,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


}

class _FieldWrapper extends StatelessWidget {
  final int flex;
  final Widget child;

  const _FieldWrapper({required this.flex, required this.child});

  @override
  Widget build(BuildContext context) => child;
}
