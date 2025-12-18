// profile_screen.dart
// NOTE: if your provider class is named ProfileProvider_NEW_NEW, update import & type accordingly.

import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'JS_Profile_Provider.dart';

// Update this import path to the actual provider file in your project.

class ProfileScreen_NEW extends StatefulWidget {
  const ProfileScreen_NEW({super.key});

  @override
  State<ProfileScreen_NEW> createState() => _ProfileScreen_NEWState();
}

class _ProfileScreen_NEWState extends State<ProfileScreen_NEW> with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  // Local short-lived controllers (for personal + add-item inputs)
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _secondaryEmailCtrl = TextEditingController();
  final TextEditingController _contactCtrl = TextEditingController();
  final TextEditingController _nationalityCtrl = TextEditingController();
  final TextEditingController _objectivesCtrl = TextEditingController();
  final TextEditingController _personalSummaryCtrl = TextEditingController();
  final TextEditingController _dobCtrl = TextEditingController();
  final TextEditingController _socialLinkCtrl = TextEditingController();
  // Education temp fields
  final TextEditingController _institutionCtrl = TextEditingController();
  final TextEditingController _durationCtrl = TextEditingController();
  final TextEditingController _majorCtrl = TextEditingController();
  final TextEditingController _marksCtrl = TextEditingController();
  // Experience temp
  final TextEditingController _experienceTextCtrl = TextEditingController();
  // Certifications / pubs / awards / references temp
  final TextEditingController _singleLineCtrl = TextEditingController();

  bool _didLoad = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 9, vsync: this); // 8 sections + Documents
    _animController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animController);
    _animController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoad) return;
    _didLoad = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Use the provider available in the tree
      final prov = Provider.of<ProfileProvider_NEW>(context, listen: false);
      // call the provider load method (provider should expose loadAll() or loadAllSectionsOnce())
      Future<void> loadFuture;
      try {
        // prefer loadAll if available
        loadFuture = prov.loadAllSectionsOnce();
      } catch (_) {
        // fallback to older name if present
        loadFuture = prov.loadAllSectionsOnce();
      }
      loadFuture.then((_) {
        // populate local controllers from provider values (provider already parsed user_data)
        _nameCtrl.text = prov.name;
        _emailCtrl.text = prov.email;
        _secondaryEmailCtrl.text = prov.secondaryEmail;
        _contactCtrl.text = prov.contactNumber;
        _nationalityCtrl.text = prov.nationality;
        _objectivesCtrl.text = prov.objectives;
        _personalSummaryCtrl.text = prov.personalSummary;
        _dobCtrl.text = prov.dob;
        setState(() {});
      }).catchError((e) {
        // ignore here — provider logs errors
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animController.dispose();

    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _secondaryEmailCtrl.dispose();
    _contactCtrl.dispose();
    _nationalityCtrl.dispose();
    _objectivesCtrl.dispose();
    _personalSummaryCtrl.dispose();
    _dobCtrl.dispose();
    _socialLinkCtrl.dispose();

    _institutionCtrl.dispose();
    _durationCtrl.dispose();
    _majorCtrl.dispose();
    _marksCtrl.dispose();

    _experienceTextCtrl.dispose();
    _singleLineCtrl.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double topBarHeight = 100.0;
    return ChangeNotifierProvider(
      create: (_) => Provider.of<ProfileProvider_NEW>(context, listen: false), // ensure provider is injected above if already created in your app; otherwise remove and use create: (_) => ProfileProvider_NEW()
      child: Stack(
        children: [
          Positioned.fill(
            top: topBarHeight,
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Consumer<ProfileProvider_NEW>(builder: (context, prov, _) {
                    if (prov.isLoading) return const Center(child: CircularProgressIndicator());
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: _buildMainColumn(prov)),
                        const SizedBox(width: 28),
                        Flexible(flex: 1, child: _buildSidebar(prov)),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: topBarHeight,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.bottomLeft,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Personnel Profile', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700)),
                  // quick debug line (remove in production)
                  Consumer<ProfileProvider_NEW>(builder: (context, prov, _) {
                    return Text(prov.debugInfo, style: const TextStyle(fontSize: 10, color: Colors.grey));
                  })
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainColumn(ProfileProvider_NEW prov) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Complete your profile', style: GoogleFonts.poppins(color: Colors.grey)),
        const SizedBox(height: 18),
        _buildTabBar(),
        const SizedBox(height: 18),
        Expanded(child: _buildTabContent(prov)),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(                                                    color: Color(0xff5C738A),
      ))),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: const Color(0xFF003366),
        indicatorWeight: 2,
        labelColor: const Color(0xFF024095),
        unselectedLabelColor: Colors.grey.shade600,
        tabs: const [
          Tab(text: 'Personal'),
          Tab(text: 'Education'),
          Tab(text: 'Professional Profile'),
          Tab(text: 'Experience'),
          Tab(text: 'Certifications'),
          Tab(text: 'Publications'),
          Tab(text: 'Awards'),
          Tab(text: 'References'),
          Tab(text: 'Documents'),
        ],
      ),
    );
  }

  Widget _buildTabContent(ProfileProvider_NEW prov) {
    return Form(
      key: prov.formKey,
      child: TabBarView(
        controller: _tabController,
        children: [
          _personalTab(prov),
          _educationTab(prov),
          _professionalProfileTab(prov),
          _experienceTab(prov),
          _certificationsTab(prov),
          _publicationsTab(prov),
          _awardsTab(prov),
          _referencesTab(prov),
          _documentsTab(prov),
        ],
      ),
    );
  }

  // ---------------- Tab widgets ----------------

  Widget _personalTab(ProfileProvider_NEW prov) {
    return SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 8),
        Row(children: [
          // profile avatar + upload
          Column(children: [
            CircleAvatar(
              radius: 44,
              backgroundImage: prov.profilePicUrl.isNotEmpty ? NetworkImage(prov.profilePicUrl) as ImageProvider : null,
              child: prov.profilePicUrl.isEmpty ? const Icon(Icons.person, size: 44) : null,
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => _pickAndUploadProfilePic(prov),
              icon: const Icon(Icons.upload),
              label: const Text('Upload Photo'),
            )
          ]),
          const SizedBox(width: 18),
          Expanded(
            child: Column(children: [
              _label('Name'),
              TextFormField(controller: _nameCtrl, decoration: _dec('Full Name'), onChanged: (v){ prov.updateName(v); }),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: _fieldInline('Email', _emailCtrl, onChanged: (v){ prov.updateEmail(v); })),
                const SizedBox(width: 12),
                Expanded(child: _fieldInline('Secondary Email', _secondaryEmailCtrl, onChanged: (v){ prov.updateSecondaryEmail(v); })),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: _fieldInline('Contact Number', _contactCtrl, onChanged: (v){ prov.updateContactNumber(v); })),
                const SizedBox(width: 12),
                Expanded(child: _fieldInline('Nationality', _nationalityCtrl, onChanged: (v){ prov.updateNationality(v); })),
              ]),
              const SizedBox(height: 8),
              _label('Objectives'),
              TextFormField(controller: _objectivesCtrl, decoration: _dec('Career objective'), onChanged: (v){ prov.updateObjectives(v); }),
              const SizedBox(height: 8),
              _label('Summary'),
              TextFormField(controller: _personalSummaryCtrl, maxLines: 3, decoration: _dec('Short professional summary'), onChanged: (v){ prov.updatePersonalSummary(v); }),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: _fieldInline('DOB (YYYY-MM-DD)', _dobCtrl, onChanged: (v){ prov.updateDob(v); })),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _label('Skills'),
                    Wrap(spacing: 8, children: prov.skillsList.asMap().entries.map((e) {
                      final idx = e.key;
                      final s = e.value;
                      return Chip(label: Text(s), onDeleted: () => prov.removeSkillAt(idx));
                    }).toList()),
                    Row(children: [
                      Expanded(child: TextFormField(controller: prov.skillController, decoration: const InputDecoration(hintText: 'Add skill'))),
                      IconButton(icon: const Icon(Icons.add), onPressed: () { prov.addSkillEntry(context);})
                    ])
                  ]),
                ),
              ]),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton(
                  onPressed: () async { await prov.savePersonalSection(context); },
                  style: ElevatedButton.styleFrom(backgroundColor: prov.getButtonColorForSection('personal')),
                  child: const Text('Save Personal'),
                ),
              )
            ]),
          )
        ]),
      ]),
    );
  }

  Widget _educationTab(ProfileProvider_NEW prov) {
    return SingleChildScrollView(
      child: Column(children: [
        _label('Add Education'),
        Row(children: [
          Expanded(child: TextFormField(controller: _institutionCtrl, decoration: _dec('Institution'))),
          const SizedBox(width: 8),
          Expanded(child: TextFormField(controller: _durationCtrl, decoration: _dec('Duration (e.g. 2016 - 2020)'))),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: TextFormField(controller: _majorCtrl, decoration: _dec('Major Subjects'))),
          const SizedBox(width: 8),
          Expanded(child: TextFormField(controller: _marksCtrl, decoration: _dec('Marks / CGPA'))),
        ]),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(onPressed: () {
            // use provider helper to add
            prov.tempSchool = _institutionCtrl.text;
            prov.tempEduStart = _durationCtrl.text;
            prov.tempFieldOfStudy = _majorCtrl.text;
            prov.tempDegree = _marksCtrl.text;
            prov.addEducationEntry(context);
            _institutionCtrl.clear(); _durationCtrl.clear(); _majorCtrl.clear(); _marksCtrl.clear();
          }, icon: const Icon(Icons.add), label: const Text('Add Education')),
        ),
        const SizedBox(height: 12),
        _listCardsMap(prov.educationalProfile, prov, section: 'education'),
        const SizedBox(height: 12),
        ElevatedButton(onPressed: () => prov.saveEducationSection(context), style: ElevatedButton.styleFrom(backgroundColor: prov.getButtonColorForSection('education')), child: const Text('Save Education')),
      ]),
    );
  }

  Widget _professionalProfileTab(ProfileProvider_NEW prov) {
    return SingleChildScrollView(
      child: Column(children: [
        _label('Professional Profile Summary'),
        TextFormField(controller: TextEditingController(text: prov.professionalProfileSummary), maxLines: 5, decoration: _dec('Longer professional summary'), onChanged: (v){ prov.professionalProfileSummary = v; prov.markPersonalDirty(); }),
        const SizedBox(height: 12),
        ElevatedButton(onPressed: () => prov.saveProfessionalProfileSection(context), child: const Text('Save Professional Profile'))
      ]),
    );
  }

  Widget _experienceTab(ProfileProvider_NEW prov) {
    return SingleChildScrollView(
      child: Column(children: [
        _label('Add Experience (free text or structured)'),
        TextFormField(controller: _experienceTextCtrl, maxLines: 3, decoration: _dec('Job title, Company, Duration, Responsibilities...')),
        const SizedBox(height: 8),
        Row(children: [
          TextButton.icon(onPressed: () {
            prov.tempCompany = '';
            prov.tempRole = '';
            prov.tempExpStart = '';
            prov.tempExpEnd = '';
            prov.tempExpDescription = _experienceTextCtrl.text.trim();
            prov.addExperienceEntry(context);
            _experienceTextCtrl.clear();
          }, icon: const Icon(Icons.add), label: const Text('Add Experience')),
        ]),
        const SizedBox(height: 12),
        _listCardsMap(prov.professionalExperience, prov, section: 'experience'),
        const SizedBox(height: 12),
        ElevatedButton(onPressed: () => prov.saveExperienceSection(context), style: ElevatedButton.styleFrom(backgroundColor: prov.getButtonColorForSection('experience')), child: const Text('Save Experience'))
      ]),
    );
  }

  Widget _certificationsTab(ProfileProvider_NEW prov) {
    return SingleChildScrollView(
      child: Column(children: [
        _label('Certifications'),
        Row(children: [
          Expanded(child: TextFormField(controller: _singleLineCtrl, decoration: _dec('Certification name'))),
          IconButton(icon: const Icon(Icons.add), onPressed: () { prov.tempCertName = _singleLineCtrl.text.trim(); prov.addCertificationEntry(context); _singleLineCtrl.clear(); }),
        ]),
        const SizedBox(height: 12),
        ...prov.certifications.asMap().entries.map((e) => ListTile(
          title: Text(e.value),
          trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () => prov.removeCertificationAt(e.key)),
        )),
        const SizedBox(height: 8),
        ElevatedButton(onPressed: () => prov.saveCertificationsSection(context), child: const Text('Save Certifications'))
      ]),
    );
  }

  Widget _publicationsTab(ProfileProvider_NEW prov) {
    return SingleChildScrollView(
      child: Column(children: [
        _label('Publications'),
        Row(children: [
          Expanded(child: TextFormField(controller: _singleLineCtrl, decoration: _dec('Publication entry'))),
          IconButton(icon: const Icon(Icons.add), onPressed: () { prov.addPublication(_singleLineCtrl.text); _singleLineCtrl.clear(); }),
        ]),
        const SizedBox(height: 12),
        ...prov.publications.asMap().entries.map((e) => ListTile(
          title: Text(e.value),
          trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () => prov.removePublicationAt(e.key)),
        )),
        const SizedBox(height: 8),
        ElevatedButton(onPressed: () => prov.savePublicationsSection(context), child: const Text('Save Publications'))
      ]),
    );
  }

  Widget _awardsTab(ProfileProvider_NEW prov) {
    return SingleChildScrollView(
      child: Column(children: [
        _label('Awards'),
        Row(children: [
          Expanded(child: TextFormField(controller: _singleLineCtrl, decoration: _dec('Award entry'))),
          IconButton(icon: const Icon(Icons.add), onPressed: () { prov.awards; _singleLineCtrl.clear(); }),
        ]),
        const SizedBox(height: 12),
        ...prov.awards.asMap().entries.map((e) => ListTile(
          title: Text(e.value),
          trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () => prov.removeAwardAt(e.key)),
        )),
        const SizedBox(height: 8),
        ElevatedButton(onPressed: () => prov.saveAwardsSection(context), child: const Text('Save Awards'))
      ]),
    );
  }

  Widget _referencesTab(ProfileProvider_NEW prov) {
    return SingleChildScrollView(
      child: Column(children: [
        _label('References'),
        Row(children: [
          Expanded(child: TextFormField(controller: _singleLineCtrl, decoration: _dec('Reference entry'))),
          IconButton(icon: const Icon(Icons.add), onPressed: () { prov.addReference(_singleLineCtrl.text); _singleLineCtrl.clear(); }),
        ]),
        const SizedBox(height: 12),
        ...prov.references.asMap().entries.map((e) => ListTile(
          title: Text(e.value),
          trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () => prov.removeReferenceAt(e.key)),
        )),
        const SizedBox(height: 8),
        ElevatedButton(onPressed: () => prov.saveReferencesSection(context), child: const Text('Save References'))
      ]),
    );
  }

  Widget _documentsTab(ProfileProvider_NEW prov) {
    return SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _label('Upload Documents (PDF, images, etc.)'),
        Row(children: [
          TextButton.icon(onPressed: () => _pickAndUploadDocument(prov), icon: const Icon(Icons.upload_file), label: const Text('Choose & Upload')),
          const SizedBox(width: 12),
          ElevatedButton(onPressed: () => prov.saveDocumentsSection(context), child: const Text('Save Documents List'))
        ]),
        const SizedBox(height: 12),
        ...prov.documents.asMap().entries.map((e) {
          final item = e.value;
          final idx = e.key;
          return ListTile(
            leading: const Icon(Icons.picture_as_pdf),
            title: Text(item['name']?.toString() ?? 'Document'),
            subtitle: Text(item['contentType']?.toString() ?? ''),
            trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () {
              prov.removeDocumentAt(idx);
              prov.saveDocumentsSection(context);
            }),
            onTap: () {
              final url = item['url']?.toString() ?? '';
              if (url.isNotEmpty) {
                // open in new tab (web) or use url_launcher in real app
              }
            },
          );
        }),
      ]),
    );
  }

  // ---------------- helpers / small widgets ----------------

  Widget _buildSidebar(ProfileProvider_NEW prov) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          if (prov.profilePicUrl.isNotEmpty)
            Image.network(prov.profilePicUrl, height: 140, fit: BoxFit.cover)
          else
            const SizedBox(height: 140, child: Icon(Icons.person, size: 100)),
          const SizedBox(height: 12),
          Text(prov.name.isNotEmpty ? prov.name : 'Your name', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(prov.personalSummary, maxLines: 4, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: () { prov.forceReload(); }, child: const Text('Reload'))
        ]),
      ),
    );
  }

  Widget _label(String s) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(s, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)));

  InputDecoration _dec(String hint) => InputDecoration(hintText: hint, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)));

  Widget _fieldInline(String label, TextEditingController ctrl, {Function(String)? onChanged}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: GoogleFonts.poppins(fontSize: 12)),
      const SizedBox(height: 6),
      TextFormField(controller: ctrl, decoration: _dec(''), onChanged: onChanged)
    ]);
  }

  Widget _listCardsMap(List<Map<String, dynamic>> items, ProfileProvider_NEW prov, {required String section}) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(children: items.asMap().entries.map((entry) {
      final i = entry.key;
      final item = entry.value;
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: ListTile(
          title: Text(item['institutionName']?.toString() ?? item['text']?.toString() ?? 'Record'),
          subtitle: Text((item['duration'] ?? item['majorSubjects'] ?? '').toString()),
          trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () {
            if (section == 'education') {
              prov.removeEducationAt(i);
            } else if (section == 'experience') prov.removeExperienceAt(i);
            // You can call the corresponding save method if you want immediate persistence
          }),
          onTap: () {
            // Optional: show details dialog
            showDialog(context: context, builder: (_) => AlertDialog(
              title: Text(item['institutionName']?.toString() ?? item['text']?.toString() ?? 'Details'),
              content: SingleChildScrollView(child: Column(children: item.entries.map((e) => ListTile(title: Text(e.key), subtitle: Text(e.value?.toString() ?? ''))).toList())),
              actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close'))],
            ));
          },
        ),
      );
    }).toList());
  }

  // ---------------- pick & upload helpers (uses file_picker) ----------------

  Future<void> _pickAndUploadProfilePic(ProfileProvider_NEW prov) async {
    final res = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      withData: true,
      type: FileType.image,
    );
    if (res == null) return;

    final file = res.files.first;
    final bytes = file.bytes;
    if (bytes == null) return;

    final mimeType = lookupMimeType(file.name, headerBytes: bytes);
    await prov.uploadProfilePicture(Uint8List.fromList(bytes), file.name, mimeType: mimeType);
  }

  Future<void> _pickAndUploadDocument(ProfileProvider_NEW prov) async {
    final res = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      withData: true,
    );
    if (res == null) return;

    final file = res.files.first;
    final bytes = file.bytes;
    if (bytes == null) return;

    final mimeType = lookupMimeType(file.name, headerBytes: bytes);
    final entry = await prov.uploadDocument(Uint8List.fromList(bytes), file.name, mimeType: mimeType);
    if (entry != null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Uploaded successfully')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Upload failed')));
    }
  }
}
