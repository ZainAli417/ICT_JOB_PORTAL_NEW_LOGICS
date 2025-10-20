// file: cv_analysis_screen.dart
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:markdown_widget/config/configs.dart';
import 'package:markdown_widget/widget/blocks/container/blockquote.dart';
import 'package:markdown_widget/widget/blocks/container/list.dart';
import 'package:markdown_widget/widget/blocks/leaf/code_block.dart';
import 'package:markdown_widget/widget/blocks/leaf/heading.dart';
import 'package:markdown_widget/widget/blocks/leaf/link.dart';
import 'package:markdown_widget/widget/blocks/leaf/paragraph.dart';
import 'package:markdown_widget/widget/inlines/code.dart';
import 'package:markdown_widget/widget/markdown.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Screens/Job_Seeker/JS_Dashboard.dart';
import '../Screens/Job_Seeker/JS_Top_Bar.dart';
import 'cv_analysis_provider.dart';

/// Enhanced CV Analysis Screen with vibrant UI/UX
class CVAnalysisScreen extends StatefulWidget {
  final String geminiApiKey;

  const CVAnalysisScreen({
    super.key,
    this.geminiApiKey = 'AIzaSyCGkh3g_A_HvBtRNQ2q2WGxS3LP2Sqtko0',
  });

  @override
  State<CVAnalysisScreen> createState() => _CVAnalysisScreenState();
}

class _CVAnalysisScreenState extends State<CVAnalysisScreen>
    with TickerProviderStateMixin {
  PlatformFile? _pickedFile;
  final TextEditingController _roleController = TextEditingController();
  final TextEditingController _jdController = TextEditingController();

  late AnimationController _aiAnimController;
  late Animation<double> _aiPulseAnimation;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animController);
    _animController.forward();

    _aiAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _aiPulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _aiAnimController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _roleController.dispose();
    _jdController.dispose();
    _aiAnimController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'rtf'],
      withData: true,
    );
    if (res != null && res.files.isNotEmpty) {
      setState(() => _pickedFile = res.files.single);
    }
  }

  void _startAnalysis(BuildContext ctx) {
    if (_pickedFile == null) {
      _showSnackBar(ctx, '📄 Please select a CV file first', isError: true);
      return;
    }
    if (_roleController.text.trim().isEmpty) {
      _showSnackBar(ctx, '💼 Please enter the target role', isError: true);
      return;
    }

    final provider = Provider.of<CVAnalyzerBackendProvider>(ctx, listen: false);
    provider.reset();
    provider.analyzeCV(
      file: _pickedFile!,
      roleName: _roleController.text.trim(),
      jobDescription: _jdController.text.trim(),
    );
  }

  void _showSnackBar(BuildContext ctx, String msg, {bool isError = false}) {
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    const double topBarHeight = 120.0;

    return ScrollConfiguration(
      behavior: SmoothScrollBehavior(),
      child: ChangeNotifierProvider(
        create: (_) => CVAnalyzerBackendProvider(),
        child: SizedBox.expand(
          child: Stack(
            children: [
              // Main content area sits under the top bar (starts below topBarHeight)
              Positioned.fill(
                top: topBarHeight,
                // IMPORTANT: Scaffold provides the Material ancestor TabBar needs
                child: Scaffold(
                  // Keep transparent so the top bar overlay remains visible
                  backgroundColor: Colors.transparent,
                  // We don't use AppBar here because MainLayout is the topbar overlay
                  body: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.03),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut)),
                      child: _buildcvaiContent(context),
                    ),
                  ),
                ),
              ),

              // Top navigation bar (MainLayout used as the bar)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: topBarHeight,
                child: MainLayout(
                  activeIndex: 1,
                  child: const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildcvaiContent(BuildContext context) {
    return ChangeNotifierProvider<CVAnalyzerBackendProvider>(
      create: (_) => CVAnalyzerBackendProvider(
        useDirectGemini: true,
        geminiApiKey: widget.geminiApiKey,
      ),
      child: Consumer<CVAnalyzerBackendProvider>(
        builder: (context, prov, _) {
// Replace the Scaffold -> body: Container(...) content with this:
          return ChangeNotifierProvider<CVAnalyzerBackendProvider>(
            create: (_) => CVAnalyzerBackendProvider(
              useDirectGemini: true,
              geminiApiKey: widget.geminiApiKey,
            ),
            child: Consumer<CVAnalyzerBackendProvider>(
              builder: (context, prov, _) {
                return Scaffold(
                  body: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.blue.shade50,
                          Colors.purple.shade50,
                          Colors.pink.shade50,
                        ],
                      ),
                    ),
                    // <-- make the whole content scrollable
                    child: SafeArea(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(24),
                        // Use a Column inside the scroll view; children may grow vertically and page will scroll
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Header row with score and progress cards
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: _buildHeader(prov),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Main content area with input and results side by side
                            // --- replaced Expanded(...) with a bounded SizedBox to avoid unbounded-height issues ---
                            SizedBox(
                              // tuned to be responsive: adjust multiplier if you want more/less visible area
                              height: MediaQuery.of(context).size.height * 0.72,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Left side - Input Section
                                  Expanded(
                                    flex: 1,
                                    child: _buildInputSection(context, prov),
                                  ),
                                  const SizedBox(width: 24),

                                  // Right side - Results Section
                                  Expanded(
                                    flex: 2,
                                    child: _buildResultsSection(context, prov),
                                  ),
                                ],
                              ),
                            ),

                            // optional bottom padding so last content doesn't stick to screen edge
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(CVAnalyzerBackendProvider prov) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade600, Colors.purple.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade200.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.analytics_outlined,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI-Powered CV Analyzer',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Get instant insights, match scores, and actionable recommendations',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          if (prov.isLoading)
            ScaleTransition(
              scale: _aiPulseAnimation,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                  strokeWidth: 3,
                ),
              ),
            ),
        ],
      ),
    );
  }


//LEFT COLOUMN
  Widget _buildInputSection(BuildContext context, CVAnalyzerBackendProvider prov) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // File Upload Section
          _buildFileUploadCard(),
          const SizedBox(height: 24),

          // Input Fields Section
          _buildInputFields(context, prov),
        ],
      ),
    );
  }
  Widget _buildFileUploadCard() {
    return Container(
      padding: const EdgeInsets.all(12), // reduced
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade50, Colors.blue.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14), // slightly tighter
        border: Border.all(color: Colors.blue.shade200, width: 1.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // important to avoid extra vertical space
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8), // reduced
                decoration: BoxDecoration(
                  color: Colors.blue.shade600,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.cloud_upload_outlined, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Upload CV',
                  style: GoogleFonts.poppins(
                    fontSize: 16, // reduced
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10), // reduced
          if (_pickedFile != null) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(_getFileIcon(), color: _getFileColor(), size: 22), // slightly smaller
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _pickedFile!.name,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 12, // reduced
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatFileSize(_pickedFile!.size),
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => setState(() => _pickedFile = null),
                    color: Colors.red.shade400,
                    padding: const EdgeInsets.all(6),
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ] else ...[
            InkWell(
              onTap: _pickFile,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blue.shade300, width: 1.6),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.file_upload_outlined, size: 32, color: Colors.blue.shade600), // smaller
                      const SizedBox(height: 6),
                      Text(
                        'Click to browse',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'PDF, DOC, DOCX (Max 2MB)',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 40, // slightly smaller button
            child: ElevatedButton.icon(
              onPressed: _pickFile,
              icon: const Icon(Icons.folder_open, size: 16),
              label: Text(
                _pickedFile == null ? 'Choose File' : 'Change File',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(40),
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildInputFields(BuildContext context, CVAnalyzerBackendProvider prov) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInputLabel('Target Role', Icons.work_outline),
        const SizedBox(height: 8),
        TextField(
          controller: _roleController,
          decoration: _inputDecoration('e.g., Senior Flutter Developer'),
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 20),
        _buildInputLabel('Job Description (Optional)', Icons.description_outlined),
        const SizedBox(height: 8),
        TextField(
          controller: _jdController,
          maxLines: 4,
          decoration: _inputDecoration('Paste the job description here...'),
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.purple.shade600,
                      Colors.blue.shade600,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ElevatedButton.icon(
                  onPressed: prov.isLoading ? null : () => _startAnalysis(context),
                  icon: Icon(
                    prov.isLoading ? Icons.hourglass_empty : Icons.auto_awesome,
                    size: 20,
                  ),
                  label: Text(
                    prov.isLoading ? 'Analyzing...' : 'Analyze CV',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    minimumSize: const Size.fromHeight(55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              height: 55,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red.shade400, Colors.orange.shade400],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ElevatedButton(
                onPressed: prov.isLoading ? null : () {
                  setState(() {
                    _pickedFile = null;
                    _roleController.clear();
                    _jdController.clear();
                  });
                  prov.reset();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                ),
                child: Icon(Icons.refresh, size: 24),
              ),
            ),
          ],
        ),
      ],
    );
  }
  Widget _buildInputLabel(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.blue.shade700),
        const SizedBox(width: 8),
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(
        color: Colors.grey.shade400,
        fontWeight: FontWeight.w600,
      ),
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
        borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
      ),
      contentPadding: const EdgeInsets.all(16),
    );
  }


//MIDDLE COLUMN

// Modified results section - cards side by side in a row
  Widget _buildResultsSection(BuildContext context, CVAnalyzerBackendProvider prov) {
    // Show loading popup when processing
    if (prov.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showAIProcessingDialog(context, prov);
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Error Card (if any) - full width
        if (!prov.isLoading && prov.error != null) ...[
          _buildErrorCard(prov),
          const SizedBox(height: 16),
        ],

        // Main content row - side by side layout
        // --- Replace this Expanded(...) block with the SizedBox version ---
        if (!prov.isLoading && (prov.advisory != null || prov.highlights.isNotEmpty || prov.score != null))
          SizedBox(
            // bounded height for the whole results area; tweak multiplier as needed
            height: MediaQuery.of(context).size.height * 0.6,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left column: Advisory (top) + Highlights (bottom)
                if (prov.advisory != null || prov.highlights.isNotEmpty)
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        // Advisory on top — auto height (no Expanded here)
                        if (prov.advisory != null) _buildAdvisoryCard(prov),

                        if (prov.advisory != null && prov.highlights.isNotEmpty)
                          const SizedBox(height: 16),

                        // Highlights below — take remaining space and be scrollable if needed
                        if (prov.highlights.isNotEmpty)
                          Expanded(
                            child: _buildHighlightsCard(prov),
                          ),
                      ],
                    ),
                  ),

                if ((prov.advisory != null || prov.highlights.isNotEmpty) && prov.score != null)
                  const SizedBox(width: 16),

                // Right column: Score & Progress (fixed width)
                if (prov.score != null)
                  SizedBox(
                    width: 200,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildScoreCard(prov),
                        const SizedBox(height: 16),
                        _buildProgressCard(prov),
                      ],
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
  Widget _buildAdvisoryCard(CVAnalyzerBackendProvider prov) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // advisory should size itself
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade400, Colors.teal.shade400],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.lightbulb_outline, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'AI Advisory & Insights',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.grey.shade200, thickness: 1),
          const SizedBox(height: 16),

          // --- NEW: limit advisory height based on available parent space ---
          LayoutBuilder(
            builder: (context, constraints) {
              // Parent (left column) is inside a SizedBox(height: ...). Use that as baseline.
              final parentMax = constraints.hasBoundedHeight
                  ? constraints.maxHeight
              // fallback if not bounded (shouldn't happen in your layout)
                  : MediaQuery.of(context).size.height * 0.25;

              // advisory should take at most a portion of the parent's available height
              final double advisoryMaxHeight = math.min(parentMax * 0.65, MediaQuery.of(context).size.height * 0.45);

              return ConstrainedBox(
                constraints: BoxConstraints(maxHeight: advisoryMaxHeight),
                child: MarkdownWidget(
                  data: _formatAdvisoryText(prov.advisory ?? ''),
                  // allow the internal ListView in markdown_widget to size itself
                  shrinkWrap: true,
                  // let advisory scroll when its content exceeds advisoryMaxHeight
                  physics: const AlwaysScrollableScrollPhysics(),
                  config: MarkdownConfig(
                    configs: [
                      PConfig(
                        textStyle: GoogleFonts.poppins(
                          fontSize: 15,
                          height: 1.6,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      H1Config(
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade900,
                        ),
                      ),
                      H2Config(
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade900,
                        ),
                      ),
                      H3Config(
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      PreConfig(
                        textStyle: GoogleFonts.sourceCodePro(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      CodeConfig(
                        style: GoogleFonts.sourceCodePro(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          backgroundColor: Colors.grey.shade100,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      LinkConfig(
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightsCard(CVAnalyzerBackendProvider prov) {
    // Adjust this factor or replace with a fixed number like 420.0
    final double maxHeightFactor = 0.45;
    final double maxHeight = MediaQuery.of(context).size.height * maxHeightFactor;

    return SizedBox(
      height: maxHeight, // major container fixed height
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row (fixed height)
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.orange.shade400, Colors.red.shade400],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.stars, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Key Highlights',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${prov.highlights.length} items',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Content area: takes remaining space and scrolls if content overflows
            Expanded(
              child: ListView.separated(
                itemCount: prov.highlights.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                // leave shrinkWrap false for better performance inside fixed-height container
                physics: const AlwaysScrollableScrollPhysics(),
                itemBuilder: (_, idx) {
                  final h = prov.highlights[idx];
                  return _buildHighlightItem(h, idx);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

// Loading Popup Dialog
  void _showAIProcessingDialog(BuildContext context, CVAnalyzerBackendProvider prov) {
    showDialog(
      context: context,
      barrierDismissible: false,
      // reduced opacity so background doesn't get too dark
      barrierColor: Colors.black.withOpacity(0.15),
      builder: (BuildContext context) {
        return Center(
          // ClipRect limits BackdropFilter to the dialog's area so the whole page isn't blurred/darkened
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Dialog(
                backgroundColor: Colors.transparent,
                elevation: 0,
                insetPadding: const EdgeInsets.all(20),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 550),
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.purple.shade50, Colors.blue.shade50],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.purple.shade200.withOpacity(0.7), width: 1.5),
                    boxShadow: [
                      // softened shadow (less spread & opacity)

                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ScaleTransition(
                        scale: _aiPulseAnimation,
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.purple.shade400, Colors.blue.shade400],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.purple.shade200.withOpacity(0.6),
                                blurRadius: 16,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.auto_awesome_outlined,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _getAIProcessingText(prov.progress),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.purple.shade900,
                        ),
                      ),
                      const SizedBox(height: 14),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: prov.progress,
                          minHeight: 8,
                          backgroundColor: Colors.white,
                          valueColor: AlwaysStoppedAnimation(Colors.purple.shade600),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(prov.progress * 100).toStringAsFixed(0)}% Complete',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.purple.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );


    // Auto-close dialog when loading completes
    prov.addListener(() {
      if (!prov.isLoading && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });
  }

  Widget _buildErrorCard(CVAnalyzerBackendProvider prov) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.shade200, width: 2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.error_outline, color: Colors.red.shade700, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Analysis Failed',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.red.shade900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  prov.error ?? 'Unknown error',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.red.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildHighlightItem(Map<String, dynamic> highlight, int index) {
    final type = highlight['type']?.toString().toLowerCase() ?? 'info';
    final config = _getHighlightConfig(type);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [config['bgColor'].withOpacity(0.1), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: config['borderColor'], width: 2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: config['bgColor'],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(config['icon'], color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  highlight['text'] ?? 'No title',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade900,
                  ),
                ),
                if (highlight['detail'] != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    highlight['detail'],
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                      height: 1.4,
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
// REPLACE: _buildScoreCard
  Widget _buildScoreCard(CVAnalyzerBackendProvider prov) {
    final score = prov.score ?? 0;
    final color = _getScoreColor(score);
    final hasResults = prov.score != null;

    // tighter constraints to keep the card compact and prevent overflow
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 200, maxHeight: 350),
      child: Container(
        width: 200, // reduced from 280
        padding: const EdgeInsets.all(10), // reduced padding
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.12),
              Colors.white,
              color.withOpacity(0.04),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withOpacity(0.38),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.22),
              blurRadius: 20,
              offset: const Offset(0, 10),
              spreadRadius: 1,
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.45),
              blurRadius: 8,
              offset: const Offset(-4, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.analytics_rounded,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Match Score',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            // smaller circular indicator
            SizedBox(
              width: 100, // reduced size
              height: 100,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(100, 100),
                    painter: _CircularScorePainter(
                      progress: (score / 100).clamp(0.0, 1.0),
                      color: color,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [color, color.withOpacity(0.75)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ).createShader(bounds),
                        child: Text(
                          score.toStringAsFixed(0),
                          style: GoogleFonts.poppins(
                            fontSize: 35, // reduced from 56
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'out of 100',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.36),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    hasResults ? Icons.emoji_events_rounded : Icons.pending_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    hasResults ? _getScoreLabel(score) : 'Awaiting Analysis',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
// REPLACE: _buildProgressCard
  Widget _buildProgressCard(CVAnalyzerBackendProvider prov) {
    final hasResults = prov.score != null;
    final highlightCount = prov.highlights.length;

    // constrained height & slightly reduced width to avoid vertical overflow
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 200, maxHeight: 320),
      child: Container(
        width: 200, // reduced from 300
        padding: const EdgeInsets.all(16), // slightly reduced
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              Colors.blue.shade50.withOpacity(0.28),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.blue.shade200,
            width: 1.8,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.13),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: 1,
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.45),
              blurRadius: 8,
              offset: const Offset(-4, -4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade600, Colors.blue.shade400],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.timeline_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Analysis Status',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: prov.progress,
                minHeight: 10,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation(
                  prov.isLoading
                      ? Colors.blue.shade600
                      : (hasResults ? Colors.green.shade600 : Colors.grey.shade400),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: prov.isLoading
                        ? Colors.blue.shade600
                        : (hasResults ? Colors.green.shade600 : Colors.grey.shade400),
                    boxShadow: [
                      BoxShadow(
                        color: (prov.isLoading
                            ? Colors.blue.shade600
                            : (hasResults ? Colors.green.shade600 : Colors.grey.shade400))
                            .withOpacity(0.45),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    prov.isLoading
                        ? _getAIProcessingText(prov.progress)
                        : (hasResults ? '✓ Analysis Complete' : 'Ready to analyze'),
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 1.2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.grey.shade300,
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildStatRow(
              'Highlights',
              hasResults ? '$highlightCount' : '0',
              Icons.stars_rounded,
              Colors.amber.shade600,
            ),
            const SizedBox(height: 12),
            _buildStatRow(
              'Status',
              prov.isLoading ? 'Processing' : (hasResults ? 'Complete' : 'Pending'),
              hasResults
                  ? Icons.check_circle_rounded
                  : (prov.isLoading ? Icons.sync_rounded : Icons.pending_rounded),
              prov.isLoading
                  ? Colors.blue.shade600
                  : (hasResults ? Colors.green.shade600 : Colors.orange.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }



  // Helper methods
  IconData _getFileIcon() {
    final ext = _pickedFile?.extension?.toLowerCase() ?? '';
    switch (ext) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'txt':
        return Icons.text_snippet;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getFileColor() {
    final ext = _pickedFile?.extension?.toLowerCase() ?? '';
    switch (ext) {
      case 'pdf':
        return Colors.red.shade600;
      case 'doc':
      case 'docx':
        return Colors.blue.shade600;
      case 'txt':
        return Colors.grey.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green.shade600;
    if (score >= 60) return Colors.orange.shade600;
    if (score >= 40) return Colors.deepOrange.shade600;
    return Colors.red.shade600;
  }

  String _getScoreLabel(double score) {
    if (score >= 80) return '🎉 Excellent Match';
    if (score >= 60) return '👍 Good Match';
    if (score >= 40) return '⚠️ Fair Match';
    return '❌ Needs Improvement';
  }

  String _getAIProcessingText(double progress) {
    if (progress < 0.15) return '🚀 Initializing AI analysis...';
    if (progress < 0.35) return '📄 Reading and parsing document...';
    if (progress < 0.60) return '🔍 Extracting key information...';
    if (progress < 0.85) return '🧠 Comparing with job requirements...';
    if (progress < 0.95) return '✨ Generating insights and score...';
    return '✅ Finalizing report...';
  }

  Map<String, dynamic> _getHighlightConfig(String type) {
    switch (type) {
      case 'strength':
        return {
          'icon': Icons.check_circle,
          'bgColor': Colors.green.shade600,
          'borderColor': Colors.green.shade300,
        };
      case 'weakness':
      case 'gap':
        return {
          'icon': Icons.warning_amber_rounded,
          'bgColor': Colors.orange.shade600,
          'borderColor': Colors.orange.shade300,
        };
      case 'skill':
        return {
          'icon': Icons.stars,
          'bgColor': Colors.blue.shade600,
          'borderColor': Colors.blue.shade300,
        };
      case 'experience':
        return {
          'icon': Icons.work,
          'bgColor': Colors.purple.shade600,
          'borderColor': Colors.purple.shade300,
        };
      default:
        return {
          'icon': Icons.info,
          'bgColor': Colors.grey.shade600,
          'borderColor': Colors.grey.shade300,
        };
    }
  }

  String _formatAdvisoryText(String text) {
    // Convert plain text to markdown-friendly format
    text = text.trim();

    // Add bold formatting to key phrases
    text = text.replaceAllMapped(
      RegExp(r'\b(Strengths?|Weaknesses?|Recommendations?|Skills?|Experience|Education|Summary|Analysis|Conclusion|Key Points?):', caseSensitive: false),
          (match) => '\n\n**${match.group(0)}**\n',
    );

    // Format numbered lists
    text = text.replaceAllMapped(
      RegExp(r'^(\d+)\.\s+(.+)', multiLine: true),
          (match) => '• ${match.group(2)}',
    );


    // Add spacing around paragraphs
    text = text.replaceAll(RegExp(r'\n\s*\n'), '\n\n');

    return text;
  }
}

// Custom painter for circular score display
class _CircularScorePainter extends CustomPainter {
  final double progress;
  final Color color;

  _CircularScorePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background circle
    final bgPaint = Paint()
      ..color = Colors.grey.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius - 8, bgPaint);

    // Progress arc with gradient
    final rect = Rect.fromCircle(center: center, radius: radius - 8);
    final gradient = SweepGradient(
      startAngle: -math.pi / 2,
      endAngle: -math.pi / 2 + (2 * math.pi * progress),
      colors: [
        color,
        color.withOpacity(0.6),
      ],
    );

    final progressPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );

    // Outer glow effect
    final glowPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(_CircularScorePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}