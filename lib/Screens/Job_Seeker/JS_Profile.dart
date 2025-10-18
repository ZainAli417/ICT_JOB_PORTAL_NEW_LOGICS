import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Constant/Profile_Sidebar.dart';
import 'JS_Top_Bar.dart';
import 'Profile_Provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  // Controllers for personal fields
  late final TextEditingController _summaryCtrl;
  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _rankCtrl;

  // Controllers for service (education) tab
  late final TextEditingController _unitCtrl;
  late final TextEditingController _positionCtrl;
  late final TextEditingController _afscCtrl;
  late final TextEditingController _serviceStartCtrl;
  late final TextEditingController _serviceEndCtrl;

  // Controllers for flight tab
  late final TextEditingController _aircraftCtrl;
  late final TextEditingController _flightHoursCtrl;
  late final TextEditingController _flightCountCtrl;
  late final TextEditingController _missionTypeCtrl;
  late final TextEditingController _flightDescCtrl;

  // Controllers for training tab
  late final TextEditingController _courseCtrl;
  late final TextEditingController _institutionCtrl;
  late final TextEditingController _completionYearCtrl;

  bool _didLoad = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _animController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animController);
    _animController.forward();

    // initialize all your TextEditingController objects:
    _summaryCtrl         = TextEditingController();
    _firstNameCtrl       = TextEditingController();
    _lastNameCtrl        = TextEditingController();
    _emailCtrl           = TextEditingController();
    _phoneCtrl           = TextEditingController();
    _locationCtrl        = TextEditingController();
    _rankCtrl            = TextEditingController();
    _unitCtrl            = TextEditingController();
    _positionCtrl        = TextEditingController();
    _afscCtrl            = TextEditingController();
    _serviceStartCtrl    = TextEditingController();
    _serviceEndCtrl      = TextEditingController();
    _aircraftCtrl        = TextEditingController();
    _flightHoursCtrl     = TextEditingController();
    _flightCountCtrl     = TextEditingController();
    _missionTypeCtrl     = TextEditingController();
    _flightDescCtrl      = TextEditingController();
    _courseCtrl          = TextEditingController();
    _institutionCtrl     = TextEditingController();
    _completionYearCtrl  = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didLoad) {
      _didLoad = true;
      final prov = context.read<ProfileProvider>();
      prov.loadAllSectionsOnce().then((_) {
        // populate controllers from provider
        _summaryCtrl.text      = prov.summary;
        _firstNameCtrl.text    = prov.firstName;
        _lastNameCtrl.text     = prov.lastName;
        _emailCtrl.text        = prov.email;
        _phoneCtrl.text        = prov.phone;
        _locationCtrl.text     = prov.location;
        _rankCtrl.text         = prov.current_job;

        _unitCtrl.text         = prov.tempSchool;
        _positionCtrl.text     = prov.tempDegree;
        _afscCtrl.text         = prov.tempFieldOfStudy;
        _serviceStartCtrl.text = prov.tempEduStart;
        _serviceEndCtrl.text   = prov.tempEduEnd;

        _aircraftCtrl.text     = prov.tempCompany;
        _flightHoursCtrl.text  = prov.tempRole;
        _flightCountCtrl.text  = prov.tempExpStart;
        _missionTypeCtrl.text  = prov.tempExpEnd;
        _flightDescCtrl.text   = prov.tempExpDescription;

        _courseCtrl.text       = prov.tempCertName;
        _institutionCtrl.text  = prov.tempCertInstitution;
        _completionYearCtrl.text = prov.tempCertYear;

        setState(() {});
      });
    }
  }

  void _nextTab() {
    if (_tabController.index < 5) {
      _tabController.animateTo(_tabController.index + 1);
    }
  }
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileProvider(),
      child: MainLayout(
        activeIndex: 1,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            color: Colors.grey.shade50,
            padding: const EdgeInsets.all(24),
            child: Consumer<ProfileProvider>(
              builder: (context, provider, _) {
                if (provider.errorMessage.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(provider.errorMessage),
                          backgroundColor: Colors.red,
                          action: SnackBarAction(
                            label: 'Retry',
                            textColor: Colors.white,
                            onPressed: () => provider.forceReload(),
                          ),
                        ),
                      );
                    }
                  });
                }

                return provider.isLoading
                    ? _buildLoadingState()
                    : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: _buildMainContent(provider)),
                    const SizedBox(width: 32),
                    Flexible(child: ProfileSidebar(provider: provider)),
                  ],
                );
              },
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
          const CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF003366)),
          const SizedBox(height: 16),
          Text(
            'Loading your profile...',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(ProfileProvider prov) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 32),
        _buildTabBar(),
        const SizedBox(height: 24),
        Expanded(child: _buildTabContent(prov)),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Personnel Profile',
          style: GoogleFonts.inter(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade900,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Complete your service information and records',
          style: GoogleFonts.inter(
            fontSize: 16,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: const Color(0xFF003366),
        indicatorWeight: 2,
        labelColor: const Color(0xFF024095),
        unselectedLabelColor: Colors.grey.shade600,
        labelStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
        dividerColor: Colors.transparent,
        tabAlignment: TabAlignment.start,
        tabs: const [
          Tab(text: 'Personal Information'),
          Tab(text: 'Military Service'),
          Tab(text: 'Flight Records'),
          Tab(text: 'Training & Education'),
          Tab(text: 'Specialties'),
          Tab(text: 'Documents'),
        ],
      ),
    );
  }

  Widget _buildTabContent(ProfileProvider prov) {
    return Form(
      key: prov.formKey,
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildPersonalTab(prov),
          _buildServiceTab(prov),
          _buildFlightTab(prov),
          _buildTrainingTab(prov),
          _buildSkillsTab(prov),
          _buildDocsTab(),
        ],
      ),
    );
  }

  Widget _buildPersonalTab(ProfileProvider prov) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildField('Service Summary',
            TextFormField(
              controller: _summaryCtrl,
              maxLines: 4,
              decoration: _fieldDecoration('Brief summary of your Air Force service and achievements'),
              validator: (v) => v?.isEmpty ?? true ? 'Service summary is required' : null,
              onChanged: (v) {
                prov.updateSummary(v);
                prov.markPersonalDirty();
              },
            ),
          ),
          _buildRowFields([
            _buildField('First Name',
              TextFormField(
                controller: _firstNameCtrl,
                decoration: _fieldDecoration('Enter first name'),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                onChanged: (v) {
                  prov.updateFirstName(v);
                  prov.markPersonalDirty();
                },
              ),
            ),
            _buildField('Last Name',
              TextFormField(
                controller: _lastNameCtrl,
                decoration: _fieldDecoration('Enter last name'),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                onChanged: (v) {
                  prov.updateLastName(v);
                  prov.markPersonalDirty();
                },
              ),
            ),
          ]),
          _buildRowFields([
            _buildField('Service Number',
              TextFormField(
                controller: _emailCtrl,
                decoration: _fieldDecoration('AF123456789'),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                onChanged: (v) {
                  prov.updateEmail(v);
                  prov.markPersonalDirty();
                },
              ),
            ),
            _buildField('Contact Number',
              TextFormField(
                controller: _phoneCtrl,
                decoration: _fieldDecoration('+1 234 567 890'),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                onChanged: (v) {
                  prov.updatePhone(v);
                  prov.markPersonalDirty();
                },
              ),
            ),
          ]),
          _buildRowFields([
            _buildField('Current Base/Station',
              TextFormField(
                controller: _locationCtrl,
                decoration: _fieldDecoration('e.g. Edwards AFB, CA'),
                onChanged: (v) {
                  prov.updateLocation(v);
                  prov.markPersonalDirty();
                },
              ),
            ),
            _buildField('Current Rank',
              TextFormField(
                controller: _rankCtrl,
                decoration: _fieldDecoration('e.g. Captain, Major, Colonel'),
                onChanged: (v) {
                  prov.updatecurrent_job(v);
                  prov.markPersonalDirty();
                },
              ),
            ),
          ]),
          const SizedBox(height: 20),
          Selector<ProfileProvider, Color>(
            selector: (_, p) => p.getButtonColorForSection('personal'),
            builder: (_, color, __) => SizedBox(
              width: 200,
              height: 44,
              child: ElevatedButton(
                onPressed: () {
                  if (prov.formKey.currentState!.validate()) {
                    prov.savePersonalSection(context);
                    Future.delayed(const Duration(milliseconds: 200), _nextTab);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Save & Continue'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceTab(ProfileProvider prov) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildField('Unit/Squadron',
            TextFormField(
              controller: _unitCtrl,
              decoration: _fieldDecoration('e.g. 1st Fighter Squadron'),
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              onChanged: (v) {
                prov.updateTempSchool(v);
                prov.markEducationDirty();
              },
            ),
          ),
          _buildRowFields([
            _buildField('Position/Role',
              TextFormField(
                controller: _positionCtrl,
                decoration: _fieldDecoration('e.g. Pilot, Navigator, Crew Chief'),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                onChanged: (v) {
                  prov.updateTempDegree(v);
                  prov.markEducationDirty();
                },
              ),
            ),
            _buildField('Specialty Code (AFSC)',
              TextFormField(
                controller: _afscCtrl,
                decoration: _fieldDecoration('e.g. 11F, 12F, 2A3X3'),
                onChanged: (v) {
                  prov.updateTempFieldOfStudy(v);
                  prov.markEducationDirty();
                },
              ),
            ),
          ]),
          _buildRowFields([
            _buildField('Start Date',
              TextFormField(
                controller: _serviceStartCtrl,
                decoration: _fieldDecoration('MM/YYYY'),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                onChanged: (v) {
                  prov.updateTempEduStart(v);
                  prov.markEducationDirty();
                },
              ),
            ),
            _buildField('End Date',
              TextFormField(
                controller: _serviceEndCtrl,
                decoration: _fieldDecoration('MM/YYYY or Current'),
                onChanged: (v) {
                  prov.updateTempEduEnd(v);
                  prov.markEducationDirty();
                },
              ),
            ),
          ]),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => prov.addEducationEntry(context),
              icon: const Icon(Icons.add, size: 16),
              label: Text('Add Service Record', style: GoogleFonts.inter(fontWeight: FontWeight.w500, color: Colors.black87)),
              style: TextButton.styleFrom(foregroundColor: const Color(0xFF003366).withOpacity(0.5), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
            ),
          ),
          _buildListItems(prov.educationList, 'education'),
          const SizedBox(height: 40),
          Selector<ProfileProvider, Color>(
            selector: (_, p) => p.getButtonColorForSection('education'),
            builder: (_, color, __) => SizedBox(
              width: 200,
              height: 44,
              child: ElevatedButton(
                onPressed: () {
                  if (prov.formKey.currentState!.validate()) {
                    prov.saveEducationSection(context);
                    Future.delayed(const Duration(milliseconds: 200), _nextTab);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Save & Continue'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlightTab(ProfileProvider prov) {
    return SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _buildField('Aircraft Type',
          TextFormField(
            controller: _aircraftCtrl,
            decoration: _fieldDecoration('e.g. F-16C, C-130J, KC-135'),
            validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            onChanged: (v) {
              prov.updateTempCompany(v);
              prov.markExperienceDirty();
            },
          ),
        ),
        _buildRowFields([
          _buildField('Total Flight Hours',
            TextFormField(
              controller: _flightHoursCtrl,
              decoration: _fieldDecoration('e.g. 1500.5'),
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              onChanged: (v) {
                prov.updateTempRole(v);
                prov.markExperienceDirty();
              },
            ),
          ),
          _buildField('Number of Flights',
            TextFormField(
              controller: _flightCountCtrl,
              decoration: _fieldDecoration('e.g. 450'),
              onChanged: (v) {
                prov.updateTempExpStart(v);
                prov.markExperienceDirty();
              },
            ),
          ),
        ]),
        _buildField('Mission Type',
          TextFormField(
            controller: _missionTypeCtrl,
            decoration: _fieldDecoration('Combat, Training, Transport'),
            onChanged: (v) {
              prov.updateTempExpEnd(v);
              prov.markExperienceDirty();
            },
          ),
        ),
        _buildField('Flight Experience Details',
          TextFormField(
            controller: _flightDescCtrl,
            maxLines: 3,
            decoration: _fieldDecoration('Describe your flight experience, missions, and achievements'),
            validator: (v) => v?.isEmpty ?? true ? 'Flight experience is required' : null,
            onChanged: (v) {
              prov.updateTempExpDescription(v);
              prov.markExperienceDirty();
            },
          ),
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => prov.addExperienceEntry(context),
            icon: const Icon(Icons.add, size: 16),
            label: Text('Add Flight Record', style: GoogleFonts.inter(fontWeight: FontWeight.w500, color: Colors.black87)),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFF003366).withOpacity(0.5), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
          ),
        ),
        _buildListItems(prov.experienceList, 'experience'),
        const SizedBox(height: 10),
        Selector<ProfileProvider, Color>(
          selector: (_, p) => p.getButtonColorForSection('experience'),
          builder: (_, color, __) => SizedBox(
            width: 200,
            height: 44,
            child: ElevatedButton(
              onPressed: () {
                if (prov.formKey.currentState!.validate()) {
                  prov.saveExperienceSection(context);
                  Future.delayed(const Duration(milliseconds: 200), _nextTab);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Save & Continue'),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildTrainingTab(ProfileProvider prov) {
    return SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _buildField('Training Course/Program',
          TextFormField(
            controller: _courseCtrl,
            decoration: _fieldDecoration('e.g. Pilot Training, Combat Systems Officer'),
            validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            onChanged: (v) {
              prov.updateTempCertName(v);
              prov.markCertificationsDirty();
            },
          ),
        ),
        _buildRowFields([
          _buildField('Training Base/Institution',
            TextFormField(
              controller: _institutionCtrl,
              decoration: _fieldDecoration('e.g. Sheppard AFB, USAFA'),
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              onChanged: (v) {
                prov.updateTempCertInstitution(v);
                prov.markCertificationsDirty();
              },
            ),
          ),
          _buildField('Completion Year',
            TextFormField(
              controller: _completionYearCtrl,
              decoration: _fieldDecoration('YYYY'),
              onChanged: (v) {
                prov.updateTempCertYear(v);
                prov.markCertificationsDirty();
              },
            ),
          ),
        ]),
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => prov.addCertificationEntry(context),
            icon: const Icon(Icons.add, size: 16),
            label: Text('Add Training Record', style: GoogleFonts.inter(fontWeight: FontWeight.w500, color: Colors.black87)),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFF003366).withOpacity(0.5), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
          ),
        ),
        _buildListItems(prov.certificationsList, 'certifications'),
        const SizedBox(height: 40),
        Selector<ProfileProvider, Color>(
          selector: (_, p) => p.getButtonColorForSection('certifications'),
          builder: (_, color, __) => SizedBox(
            width: 200,
            height: 44,
            child: ElevatedButton(
              onPressed: () {
                if (prov.formKey.currentState!.validate()) {
                  prov.saveCertificationsSection(context);
                  Future.delayed(const Duration(milliseconds: 200), _nextTab);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Save & Continue'),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildSkillsTab(ProfileProvider prov) {
    return SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _buildField('Add Military Specialty/Skill',
          TextFormField(
            controller: prov.skillController,
            decoration: _fieldDecoration('Enter specialty and press Add'),
            onFieldSubmitted: (_) => prov.addSkillEntry(context),
          ),
        ),
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => prov.addSkillEntry(context),
            icon: const Icon(Icons.add, size: 16),
            label: Text('Add Specialty', style: GoogleFonts.inter(fontWeight: FontWeight.w500, color: Colors.black87)),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFF003366).withOpacity(0.5), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
          ),
        ),
        const SizedBox(height: 24),
        if (prov.skillsList.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: prov.skillsList.map((skill) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.grey.shade300)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(skill, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(width: 8),
                GestureDetector(onTap: () { prov.skillsList.remove(skill); prov.notifyListeners(); }, child: Icon(Icons.close, size: 14, color: Colors.grey.shade600)),
              ]),
            )).toList(),
          ),
        const SizedBox(height: 40),
        Selector<ProfileProvider, Color>(
          selector: (_, p) => p.getButtonColorForSection('skills'),
          builder: (_, color, __) => SizedBox(
            width: 200,
            height: 44,
            child: ElevatedButton(
              onPressed: () {
                if (prov.formKey.currentState!.validate()) {
                  prov.saveSkillsSection(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Save Specialties'),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildDocsTab() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Upload Military Documents', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey.shade900)),
      const SizedBox(height: 8),
      Text('Upload relevant military documents such as service records, commendations, or certifications.', style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade600)),
      const SizedBox(height: 32),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(48),
        decoration: BoxDecoration(border: Border.all(color: const Color(0xFF003366)), borderRadius: BorderRadius.circular(8)),
        child: Column(children: [
          const Icon(Icons.upload_file, size: 48, color: Color(0xFF003366)),
          const SizedBox(height: 16),
          Text('Drag and drop files here, or click to browse', style: GoogleFonts.inter(fontSize: 16, color: Colors.grey.shade700)),
          const SizedBox(height: 8),
          Text('Supported formats: PDF, DOC, DOCX, JPG, PNG', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade500)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF003366), elevation: 0, side: const BorderSide(color: Color(0xFF003366)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
            child: Text('Choose Files', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
          ),
        ]),
      ),
    ]);
  }

  Widget _buildField(String label, Widget child) {
    return Padding(padding: const EdgeInsets.only(bottom: 24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade900)),
      const SizedBox(height: 8),
      child,
    ]));
  }

  Widget _buildRowFields(List<Widget> children) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: children.map((child) => Expanded(child: Padding(padding: EdgeInsets.only(right: children.indexOf(child) == children.length - 1 ? 0 : 16), child: child))).toList());
  }

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(color: Colors.grey.shade500, fontSize: 14),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF003366), width: 2)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.red, width: 2)),
    );
  }

  Widget _buildListItems(List<Map<String, dynamic>> items, String section) {
    if (items.isEmpty) return const SizedBox(height: 16);
    return Column(children: [
      const SizedBox(height: 16),
      ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        itemBuilder: (context, index) => _buildDetailedCard(items[index], section, index),
      ),
    ]);
  }

  Widget _buildDetailedCard(Map<String, dynamic> item, String section, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.blue.shade100, width: 1)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showDetailModal(item, section),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _buildCardHeader(item, section, index),
              const SizedBox(height: 12),
              _buildCardContent(item, section),
              const SizedBox(height: 8),
              _buildCardFooter(item, section),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildCardHeader(Map<String, dynamic> item, String section, int index) {
    return Row(children: [
      Container(padding: const EdgeInsets.all(8), color: Colors.white, child: Icon(_getSectionIcon(section), color: const Color(0xFF003366), size: 18)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(_getCardTitle(item, section), style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade800), maxLines: 1, overflow: TextOverflow.ellipsis),
        Text(_getCardSubtitle(item, section), style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF003366), fontWeight: FontWeight.w500)),
      ])),
      Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: const Color(0xFF003366), borderRadius: BorderRadius.circular(12)), child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.verified, color: Colors.white, size: 14),
        const SizedBox(width: 4),
        Text('#${(index + 1).toString().padLeft(2, '0')}', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white)),
      ])),
    ]);
  }

  Widget _buildCardContent(Map<String, dynamic> item, String section) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: Column(children: _getDetailRows(item, section)),
    );
  }

  List<Widget> _getDetailRows(Map<String, dynamic> item, String section) {
    switch (section) {
      case 'education':
        return [
          _buildDetailRow(Icons.school, 'Unit/Squadron', item['school'] ?? 'N/A'),
          _buildDetailRow(Icons.work, 'Position', item['degree'] ?? 'N/A'),
          _buildDetailRow(Icons.code, 'AFSC', item['fieldOfStudy'] ?? 'N/A'),
          _buildDetailRow(Icons.calendar_month, 'Duration', '${item['eduStart'] ?? 'N/A'} - ${item['eduEnd'] ?? 'N/A'}'),
        ];
      case 'experience':
        return [
          _buildDetailRow(Icons.flight, 'Aircraft', item['company'] ?? 'N/A'),
          _buildDetailRow(Icons.access_time, 'Flight Hours', '${item['role'] ?? 'N/A'} hrs'),
          _buildDetailRow(Icons.flight_takeoff, 'Total Flights', item['expStart'] ?? 'N/A'),
          _buildDetailRow(Icons.assignment, 'Mission Type', item['expEnd'] ?? 'N/A'),
          if ((item['expDescription'] ?? '').toString().isNotEmpty)
            _buildDetailRow(Icons.description, 'Details', item['expDescription'], isMultiline: true),
        ];
      case 'certifications':
        return [
          _buildDetailRow(Icons.school, 'Course', item['certName'] ?? 'N/A'),
          _buildDetailRow(Icons.location_city, 'Institution', item['certInstitution'] ?? 'N/A'),
          _buildDetailRow(Icons.calendar_today, 'Year', item['certYear'] ?? 'N/A'),
        ];
      default:
        return [_buildDetailRow(Icons.info, 'Info', item.toString())];
    }
  }

  Widget _buildDetailRow(IconData icon, String label, dynamic value, {bool isMultiline = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: Colors.blue.shade400),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: Text(label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey.shade600)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value.toString(), style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade800), maxLines: isMultiline ? 3 : 1, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  Widget _buildCardFooter(Map<String, dynamic> item, String section) {
    return Row(children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        decoration: BoxDecoration(color: const Color(0xFF003366), borderRadius: BorderRadius.circular(8)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.visibility, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text('View Details', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.white)),
        ]),
      ),
    ]);
  }

  IconData _getSectionIcon(String section) {
    switch (section) {
      case 'education':
        return Icons.military_tech;
      case 'experience':
        return Icons.flight;
      case 'certifications':
        return Icons.school;
      default:
        return Icons.info;
    }
  }

  String _getCardTitle(Map<String, dynamic> item, String section) {
    switch (section) {
      case 'education':
        return item['school']?.toString() ?? 'Military Unit';
      case 'experience':
        return item['company']?.toString() ?? 'Aircraft Type';
      case 'certifications':
        return item['certName']?.toString() ?? 'Training Course';
      default:
        return 'Record';
    }
  }

  String _getCardSubtitle(Map<String, dynamic> item, String section) {
    switch (section) {
      case 'education':
        return item['degree']?.toString() ?? 'Position';
      case 'experience':
        return '${item['role']?.toString() ?? '0'} Flight Hours';
      case 'certifications':
        return item['certInstitution']?.toString() ?? 'Institution';
      default:
        return 'Details';
    }
  }

  void _showDetailModal(Map<String, dynamic> item, String section) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          Icon(_getSectionIcon(section), color: Colors.blue.shade600),
          const SizedBox(width: 8),
          Text('Record Details', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        ]),
        content: SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: _getDetailRows(item, section)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Close', style: GoogleFonts.poppins(color: Colors.blue.shade600))),
        ],
      ),
    );
  }
}
