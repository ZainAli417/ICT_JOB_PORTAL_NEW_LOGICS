// lib/screens/signup_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:job_portal/SignUp%20/signup_provider.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class SignUp_Screen2 extends StatefulWidget {
  const SignUp_Screen2({super.key});

  @override
  State<SignUp_Screen2> createState() => _SignUp_Screen2State();
}

class _SignUp_Screen2State extends State<SignUp_Screen2> {
  final _formKeyAccount = GlobalKey<FormState>();
  final _personalFormKey = GlobalKey<FormState>();
  final _educationFormKey = GlobalKey<FormState>();

  // edit controllers for education dialog
  final _editInstitution = TextEditingController();
  final _editDuration = TextEditingController();
  final _editMajor = TextEditingController();
  final _editMarks = TextEditingController();

  @override
  void initState() {
    super.initState();
    // clear provider state when entering screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = Provider.of<SignupProvider>(context, listen: false);
      p.clearAll();
    });
  }

  @override
  void dispose() {
    _editInstitution.dispose();
    _editDuration.dispose();
    _editMajor.dispose();
    _editMarks.dispose();
    super.dispose();
  }
  // Called when the Upload/Change button is pressed.
  Future<void> onPickImage() async {
    final p = Provider.of<SignupProvider>(context, listen: false);

    // Clear previous error
    p.generalError = null;

    try {
      await p.pickProfilePicture();

      // Show any provider-reported error to user
      if (p.generalError != null && p.generalError!.isNotEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(p.generalError!), backgroundColor: Colors.redAccent),
        );
      } else {
        // success — optional small toast/snack to confirm (can be removed)
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image selected'), duration: Duration(milliseconds: 900)),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image pick failed: $e'), backgroundColor: Colors.redAccent),
      );
    }
  }


  Widget _imageUploadStep() {
    final p = Provider.of<SignupProvider>(context);
    final imageBytes = p.profilePicBytes;
    final imageDataUrl = p.imageDataUrl;

    ImageProvider? imageProvider;
    if (imageBytes != null) {
      imageProvider = MemoryImage(imageBytes);
    } else if (imageDataUrl != null) {
      try {
        final base64Part = imageDataUrl.split(',').last;
        imageProvider = MemoryImage(base64Decode(base64Part));
      } catch (_) {
        imageProvider = null;
      }
    }

    final primary = Theme.of(context).primaryColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Profile Photo 📸', style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
        const SizedBox(height: 8),
        Text('A professional photo makes a great first impression', style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade600)),
        const SizedBox(height: 32),
        Center(
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: primary.withOpacity(0.18), blurRadius: 30, offset: const Offset(0, 10))],
                ),
                child: CircleAvatar(
                  radius: 70,
                  backgroundColor: Colors.grey.shade100,
                  backgroundImage: imageProvider,
                  child: imageProvider == null ? Icon(Icons.person_outline_rounded, size: 60, color: Colors.grey.shade400) : null,
                ),
              ),
              const SizedBox(height: 24),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: ElevatedButton.icon(
                  onPressed: onPickImage,
                  icon: const Icon(Icons.upload_file_rounded),
                  label: Text(imageProvider == null ? 'Upload Photo' : 'Change Photo', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text('Max size: 2MB • JPG, PNG', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade500)),
              if (p.generalError != null && p.generalError!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(p.generalError!, style: const TextStyle(color: Colors.redAccent)),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // Left decorative panel
  Widget leftPanel(BuildContext context) {
    return Container(
      color: Colors.blueGrey.shade900,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.work_outline, size: 64, color: Colors.white),
          const SizedBox(height: 18),
          Text('TalentForge',
              style: GoogleFonts.poppins(textStyle: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w700))),
          const SizedBox(height: 8),
          Text('Build your profile. Get discovered.',
              style: GoogleFonts.poppins(textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70))),
          const SizedBox(height: 24),
          statRow('Jobs Posted', '1,230'),
          const SizedBox(height: 8),
          statRow('Active Recruiters', '342'),
          const SizedBox(height: 8),
          statRow('Successful Hires', '5,410'),
        ],
      ),
    );
  }

  Widget statRow(String label, String value) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: GoogleFonts.poppins(textStyle: const TextStyle(color: Colors.white70))),
      Text(value, style: GoogleFonts.poppins(textStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
    ]);
  }

  // ---------- Account panel ----------
  Widget accountPanel(BuildContext context, SignupProvider p) {
    return Form(
      key: _formKeyAccount,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        roleSelector(context, p),
        const SizedBox(height: 12),
        TextFormField(
          controller: p.emailController,
          decoration: InputDecoration(labelText: 'Email', errorText: p.emailError),
          keyboardType: TextInputType.emailAddress,
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Email required';
            final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
            if (!emailRegex.hasMatch(v.trim())) return 'Enter valid email';
            return null;
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: p.passwordController,
          decoration: InputDecoration(labelText: 'Password', errorText: p.passwordError),
          obscureText: true,
          validator: (v) {
            if (v == null || v.isEmpty) return 'Password required';
            if (v.length < 8) return 'Min 8 characters';
            return null;
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: p.confirmPasswordController,
          decoration: InputDecoration(labelText: 'Confirm Password', errorText: p.passwordError),
          obscureText: true,
          validator: (v) {
            if (v == null || v.isEmpty) return 'Confirm your password';
            if (v != p.passwordController.text) return 'Passwords must match';
            return null;
          },
        ),
        const SizedBox(height: 12),
        const Text('Do you have a CV?'),
        const SizedBox(height: 6),
        Row(children: [
          OutlinedButton(
            onPressed: () {
              showDialog(context: context, builder: (c) => AlertDialog(title: const Text('CV Upload - Coming soon'), content: const Text('CV upload is coming soon.'), actions: [TextButton(onPressed: () => Navigator.of(c).pop(), child: const Text('OK'))]));
            },
            child: const Text('Yes'),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () {
              // Validate email/password on proceed
              final okForm = _formKeyAccount.currentState?.validate() ?? false;
              final okEmail = p.validateEmail();
              final okPass = p.validatePasswords();
              if (!okForm || !okEmail || !okPass) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fix email/password errors before proceeding')));
                return;
              }
              // reveal first personal field and move to personal step
              p.revealNextPersonalField();
              p.goToStep(1);
            },
            child: const Text('No, proceed'),
          ),
        ])
      ]),
    );
  }

  Widget roleSelector(BuildContext context, SignupProvider p) {
    return Row(children: [
      Expanded(child: ChoiceChip(label: const Text('Job Seeker'), selected: p.role == 'job_seeker', onSelected: (v) => p.setRole('job_seeker'))),
      const SizedBox(width: 12),
      Expanded(child: ChoiceChip(label: const Text('Recruiter'), selected: p.role == 'recruiter', onSelected: (v) => p.setRole('recruiter'))),
    ]);
  }

  // ---------- Personal panel ----------
  Widget personalPanel(BuildContext context, SignupProvider p) {
    final progress = p.computeProgress();

    Widget avatarPreview() {
      // Prefer raw bytes if available (fast). Fallback to data URL if present.
      if (p.profilePicBytes != null) {
        return CircleAvatar(
          radius: 40, // smaller placeholder
          backgroundColor: Colors.grey.shade100,
          backgroundImage: MemoryImage(p.profilePicBytes!),
        );
      }

      if (p.imageDataUrl != null) {
        try {
          final base64Part = p.imageDataUrl!.split(',').last;
          final bytes = base64Decode(base64Part);
          return CircleAvatar(
            radius: 40,
            backgroundColor: Colors.grey.shade100,
            backgroundImage: MemoryImage(bytes),
          );
        } catch (_) {
          // fall through to default icon
        }
      }

      return CircleAvatar(
        radius: 40,
        backgroundColor: Colors.grey.shade100,
        child: Icon(Icons.person_outline_rounded, size: 32, color: Colors.grey.shade400),
      );
    }

    return Form(
      key: _personalFormKey,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Personal Profile', style: GoogleFonts.poppins(textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
        const SizedBox(height: 10),
        LinearProgressIndicator(value: progress),
        const SizedBox(height: 12),

        // Name (index 0)
        if (p.personalVisibleIndex >= 0)
          TextFormField(
            controller: p.nameController,
            decoration: const InputDecoration(labelText: 'Full Name'),
            onChanged: (v) => p.onFieldTypedAutoReveal(0, v),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Name required' : null,
          ),

        const SizedBox(height: 12),

        // Contact (index 1)
        if (p.personalVisibleIndex >= 1)
          TextFormField(
            controller: p.contactNumberController,
            decoration: const InputDecoration(labelText: 'Contact Number'),
            keyboardType: TextInputType.phone,
            onChanged: (v) => p.onFieldTypedAutoReveal(1, v),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Contact required';
              final phoneRegex = RegExp(r'^[\d\+\-\s]{5,20}$');
              if (!phoneRegex.hasMatch(v.trim())) return 'Enter valid number';
              return null;
            },
          ),

        const SizedBox(height: 12),

        // Nationality (index 2)
        if (p.personalVisibleIndex >= 2)
          TextFormField(
            controller: p.nationalityController,
            decoration: const InputDecoration(labelText: 'Nationality'),
            onChanged: (v) => p.onFieldTypedAutoReveal(2, v),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Nationality required' : null,
          ),

        const SizedBox(height: 12),

        // Summary (index 3) NEW
        if (p.personalVisibleIndex >= 3)
          TextFormField(
            controller: p.summaryController,
            decoration: const InputDecoration(labelText: 'Short Summary (1-2 lines)'),
            onChanged: (v) => p.onFieldTypedAutoReveal(3, v),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Summary required' : null,
            maxLines: 2,
          ),

        const SizedBox(height: 12),

        // Avatar pick (optional). revealNext after pick if at index 4 to keep flow natural.
        // Avatar pick (optional). revealNext after pick if at index 4 to keep flow natural.
        if (p.personalVisibleIndex >= 4)
          Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            avatarPreview(),
            const SizedBox(width: 16),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ElevatedButton.icon(
                onPressed: () async {
                  await p.pickProfilePicture();
                  // if we picked and we're still at this index, advance to skills
                  if (p.personalVisibleIndex == 4) p.revealNextPersonalField();
                },
                icon: const Icon(Icons.photo_camera),
                label: const Text('Pick Image'),
              ),
              // show remove when we actually have a preview
              if (p.profilePicBytes != null || p.imageDataUrl != null)
                TextButton(onPressed: () => p.removeProfilePicture(), child: const Text('Remove')),
            ])
          ]),

        const SizedBox(height: 12),

        // Skills (index 5) - chips; enter to add. but auto reveal on first typed character handled below
        if (p.personalVisibleIndex >= 5)
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Skills (press Enter to add)'),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 6, children: [
              // chips
              ...p.skills.asMap().entries.map((e) => Chip(label: Text(e.value), onDeleted: () => p.removeSkillAt(e.key))),
              // input
              SizedBox(
                width: 300,
                child: TextField(
                  controller: p.skillInputController,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(hintText: 'Type skill then press Enter'),
                  onChanged: (v) {
                    // auto reveal next field when user starts typing skills (if at skills index)
                    p.onFieldTypedAutoReveal(5, v);
                  },
                  onSubmitted: (v) {
                    p.addSkill(v);
                    p.skillInputController.clear();
                  },
                ),
              ),
            ])
          ]),

        const SizedBox(height: 12),

        // Objectives (index 6)
        if (p.personalVisibleIndex >= 6)
          TextFormField(
            controller: p.objectivesController,
            decoration: const InputDecoration(labelText: 'Career Objectives'),
            maxLines: 3,
            onChanged: (v) => p.onFieldTypedAutoReveal(6, v),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Objectives required' : null,
          ),

        const SizedBox(height: 12),

        // DOB (index 7)
        if (p.personalVisibleIndex >= 7)
          Row(children: [
            Text(p.dob == null ? 'Select Date of Birth' : DateFormat.yMMMMd().format(p.dob!)),
            const SizedBox(width: 12),
            OutlinedButton(
                onPressed: () async {
                  final now = DateTime.now();
                  final initial = DateTime(now.year - 22);
                  final picked = await showDatePicker(context: context, initialDate: initial, firstDate: DateTime(1900), lastDate: DateTime(now.year - 13));
                  if (picked != null) {
                    p.setDob(picked);
                  }
                },
                child: const Text('Pick DOB')),
          ]),

        const SizedBox(height: 16),
        Row(children: [
          OutlinedButton(onPressed: () => p.goToStep(0), child: const Text('Back')),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () {
              // Validate personal step (on button click)
              final okForm = _personalFormKey.currentState?.validate() ?? false;
              if (!okForm) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please complete all required personal fields')));
                return;
              }
              if (p.skills.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add at least one skill')));
                return;
              }
              if (p.dob == null) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select date of birth')));
                return;
              }
              p.goToStep(2);
            },
            child: const Text('Next: Education'),
          )
        ])
      ]),
    );
  }

  // ---------- Education panel ----------
  Widget educationPanel(BuildContext context, SignupProvider p) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Educational Profile', style: GoogleFonts.poppins(textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
      const SizedBox(height: 12),
      const Text('Add your education entries. At least one entry is required.'),
      const SizedBox(height: 12),
      if (p.educationalProfile.isEmpty) const Text('No education added yet', style: TextStyle(color: Colors.black54)),
      ...p.educationalProfile.asMap().entries.map((entry) {
        final idx = entry.key;
        final data = entry.value;
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            title: Text(data['institutionName'] ?? ''),
            subtitle: Text('${data['majorSubjects'] ?? ''} • ${data['duration'] ?? ''}'),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(
                  onPressed: () {
                    _editInstitution.text = data['institutionName'] ?? '';
                    _editDuration.text = data['duration'] ?? '';
                    _editMajor.text = data['majorSubjects'] ?? '';
                    _editMarks.text = data['marksOrCgpa'] ?? '';
                    showDialog(
                      context: context,
                      builder: (c) => AlertDialog(
                        title: const Text('Edit Education'),
                        content: SingleChildScrollView(
                          child: Column(children: [
                            TextFormField(controller: _editInstitution, decoration: const InputDecoration(labelText: 'Institution')),
                            TextFormField(controller: _editDuration, decoration: const InputDecoration(labelText: 'Duration')),
                            TextFormField(controller: _editMajor, decoration: const InputDecoration(labelText: 'Major Subjects')),
                            TextFormField(controller: _editMarks, decoration: const InputDecoration(labelText: 'Marks / CGPA')),
                          ]),
                        ),
                        actions: [
                          TextButton(onPressed: () => Navigator.of(c).pop(), child: const Text('Cancel')),
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
                            child: const Text('Save'),
                          )
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit)),
              IconButton(onPressed: () => p.removeEducation(idx), icon: const Icon(Icons.delete)),
            ]),
          ),
        );
      }),
      const SizedBox(height: 12),
      ElevatedButton.icon(
        icon: const Icon(Icons.add),
        label: const Text('Add Education'),
        onPressed: () {
          final inst = TextEditingController();
          final dur = TextEditingController();
          final major = TextEditingController();
          final marks = TextEditingController();
          showDialog(
            context: context,
            builder: (c) => AlertDialog(
              title: const Text('Add Education'),
              content: SingleChildScrollView(
                child: Form(
                  key: _educationFormKey,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    TextFormField(controller: inst, decoration: const InputDecoration(labelText: 'Institution / University')),
                    TextFormField(controller: dur, decoration: const InputDecoration(labelText: 'Duration (e.g. 2017-2021)')),
                    TextFormField(controller: major, decoration: const InputDecoration(labelText: 'Major Subjects')),
                    TextFormField(controller: marks, decoration: const InputDecoration(labelText: 'Marks / CGPA')),
                  ]),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(c).pop(), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () {
                    if (inst.text.trim().isEmpty || dur.text.trim().isEmpty || major.text.trim().isEmpty || marks.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all education fields')));
                      return;
                    }
                    p.addEducation(institutionName: inst.text, duration: dur.text, majorSubjects: major.text, marksOrCgpa: marks.text);
                    Navigator.of(c).pop();
                  },
                  child: const Text('Add'),
                )
              ],
            ),
          );
        },
      ),
      const SizedBox(height: 16),
      Row(children: [
        OutlinedButton(onPressed: () => p.goToStep(1), child: const Text('Back')),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: () {
            if (!p.educationSectionIsComplete()) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add at least one education entry and fill all fields')));
              return;
            }
            p.goToStep(3);
          },
          child: const Text('Next: Review'),
        )
      ])
    ]);
  }

  // ---------- Polished review template ----------
  Widget reviewPanel(BuildContext context, SignupProvider p) {
    // Left: avatar + name + summary; Right: details
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
        backgroundColor: Colors.grey.shade100,
        child: Icon(Icons.person_outline_rounded, size: 60, color: Colors.grey.shade400),
      );
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Review & Submit', style: GoogleFonts.poppins(textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800))),
      const SizedBox(height: 12),
      Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // LEFT: avatar & summary
            Expanded(
              flex: 3,
              child: Column(children: [
                avatarCard(),
                const SizedBox(height: 12),
                Text(p.nameController.text.trim(), style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text(p.summaryController.text.trim(), style: GoogleFonts.poppins(color: Colors.black87)),
                const SizedBox(height: 12),
                ElevatedButton.icon(onPressed: () => p.goToStep(1), icon: const Icon(Icons.edit), label: const Text('Edit Personal')),
              ]),
            ),
            const SizedBox(width: 16),
            // RIGHT: two column details
            Expanded(
              flex: 7,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Contact block
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Contact', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
                  subtitle: Text('${p.contactNumberController.text.trim()}\n${p.emailController.text.trim()}', style: GoogleFonts.poppins()),
                  trailing: IconButton(onPressed: () => p.goToStep(1), icon: const Icon(Icons.edit)),
                ),
                const Divider(),
                // Personal details grid
                Wrap(spacing: 12, runSpacing: 12, children: [
                  _detailChip('Nationality', p.nationalityController.text.trim()),
                  _detailChip('DOB', p.dob == null ? '-' : DateFormat.yMMMMd().format(p.dob!)),
                  _detailChip('Skills', p.skills.join(', ')),
                  _detailChip('Objectives', p.objectivesController.text.trim()),
                ]),
                const SizedBox(height: 12),
                // Education card list
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Education', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
                  IconButton(onPressed: () => p.goToStep(2), icon: const Icon(Icons.edit))
                ]),
                Column(children: [
                  ...p.educationalProfile.map((edu) => Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      title: Text(edu['institutionName'] ?? '', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                      subtitle: Text('${edu['majorSubjects'] ?? ''} • ${edu['marksOrCgpa'] ?? ''} • ${edu['duration'] ?? ''}', style: GoogleFonts.poppins()),
                    ),
                  ))
                ])
              ]),
            ),
          ]),
        ),
      ),
      const SizedBox(height: 12),
      Row(children: [
        OutlinedButton(onPressed: () => p.goToStep(2), child: const Text('Back')),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: p.isLoading
                ? null
                : () async {
              final ok = await p.submitAllAndCreateAccount();
              if (ok) {
                if (!mounted) return;
                // show finalizing dialog
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (c) => WillPopScope(
                    onWillPop: () async => false,
                    child: AlertDialog(
                      title: const Text('Finalizing setup'),
                      content: Column(mainAxisSize: MainAxisSize.min, children: const [Text('Finishing account setup...'), SizedBox(height: 12), CircularProgressIndicator()]),
                    ),
                  ),
                );
                await Future.delayed(const Duration(seconds: 2));
                if (Navigator.canPop(context)) Navigator.of(context).pop();
                // Clear state so next time form is empty
                p.clearAll();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account created & data saved')));
                // navigate to home or login
                // Navigator.of(context).pushReplacementNamed('/home');
              } else {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(p.generalError ?? 'Failed to sign up')));
              }
            },
            child: p.isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Submit & Create Account'),
          ),
        ),
      ])
    ]);
  }

  Widget _detailChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.grey.shade100),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black54)),
        const SizedBox(height: 6),
        SizedBox(width: 220, child: Text(value.isEmpty ? '-' : value, style: GoogleFonts.poppins())),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(create: (_) => SignupProvider(), child: const _SignUp_Screen2Inner());
  }
}

class _SignUp_Screen2Inner extends StatelessWidget {
  const _SignUp_Screen2Inner();

  @override
  Widget build(BuildContext context) {
    final p = Provider.of<SignupProvider>(context);
    final isWide = MediaQuery.of(context).size.width > 900;

    Widget bodyForStep() {
      switch (p.currentStep) {
        case 0:
          return (context as Element).findAncestorStateOfType<_SignUp_Screen2State>()!.accountPanel(context, p);
        case 1:
          return (context as Element).findAncestorStateOfType<_SignUp_Screen2State>()!.personalPanel(context, p);
        case 2:
          return (context as Element).findAncestorStateOfType<_SignUp_Screen2State>()!.educationPanel(context, p);
        case 3:
          return (context as Element).findAncestorStateOfType<_SignUp_Screen2State>()!.reviewPanel(context, p);
        default:
          return (context as Element).findAncestorStateOfType<_SignUp_Screen2State>()!.accountPanel(context, p);
      }
    }

    return Scaffold(
      body: SafeArea(
        child: Row(children: [
          if (isWide) Flexible(flex: 4, child: (context as Element).findAncestorStateOfType<_SignUp_Screen2State>()!.leftPanel(context)) else const SizedBox.shrink(),
          Flexible(
            flex: 6,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Sign up', style: GoogleFonts.poppins(textStyle: Theme.of(context).textTheme.headlineSmall)),
                  if (!isWide)
                    IconButton(
                      icon: const Icon(Icons.info_outline),
                      onPressed: () => showDialog(context: context, builder: (c) => AlertDialog(title: const Text('About'), content: const Text('Use role selector to choose job seeker or recruiter.'), actions: [TextButton(onPressed: () => Navigator.of(c).pop(), child: const Text('OK'))])),
                    )
                ]),
                const SizedBox(height: 12),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(padding: const EdgeInsets.all(18.0), child: AnimatedSwitcher(duration: const Duration(milliseconds: 300), child: bodyForStep())),
                ),
                const SizedBox(height: 12),
                Row(children: [Text('Already have an account?', style: GoogleFonts.poppins()), TextButton(onPressed: () => Navigator.of(context).pushReplacementNamed('/login'), child: const Text('Login'))])
              ]),
            ),
          )
        ]),
      ),
    );
  }
}
