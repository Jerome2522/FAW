import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../l10n/app_localizations.dart';
import '../features/camera/camera_service.dart';
import '../features/prediction/prediction_page.dart';
import '../services/scan_history_service.dart';
import '../services/image_service.dart';
import '../widgets/scale_on_tap.dart';

// Import our new decomposed sub-widgets
import 'scan_hub/hero_section.dart';
import 'scan_hub/ai_tips.dart';
import 'scan_hub/recent_scans.dart';
import 'scan_hub/floating_scan_button.dart';
import 'scan_hub/guide_cards.dart';
import 'krishi_chat.dart';

class ScanHubPage extends StatefulWidget {
  const ScanHubPage({super.key});

  @override
  State<ScanHubPage> createState() => _ScanHubPageState();
}

class _ScanHubPageState extends State<ScanHubPage> with AutomaticKeepAliveClientMixin<ScanHubPage> {
  final ValueNotifier<List<ScanHistoryItem>> _historyNotifier = ValueNotifier<List<ScanHistoryItem>>([]);
  final ScrollController _scrollController = ScrollController();

  // Key used by PageStorage to persist scroll offset across navigation
  final PageStorageKey _storageKey = const PageStorageKey('scan_hub_scroll_key');
  bool _showDeferredContent = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
    // Defer heavy UI sections until the tab-switch transition is fully completed
    Future.delayed(const Duration(milliseconds: 375), () {
      if (mounted) {
        setState(() {
          _showDeferredContent = true;
        });
        
        // Asynchronously repair missing thumbnails for old history items
        // AFTER the transition is 100% complete!
        ScanHistoryService.repairMissingThumbnails(
          _historyNotifier.value,
          () {
            if (mounted) {
              _loadHistory(); // Reload history once repair is complete to switch to thumbnails!
            }
          },
        );
      }
    });
  }

  @override
  void dispose() {
    _historyNotifier.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final items = await ScanHistoryService.getHistory();
    if (mounted) {
      _historyNotifier.value = items;
    }
  }

  Future<void> _handleImage(XFile image) async {
    if (!mounted) return;
    await Navigator.push(
      context,
      _createPremiumRoute(PredictionPage(image: image)),
    );
    _loadHistory();
  }

  Future<void> _triggerCamera() async {
    HapticFeedback.mediumImpact();
    var status = await Permission.camera.status;
    if (!mounted) return;
    if (!status.isGranted) {
      bool? allowed = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Camera Access Required"),
            content: const Text(
              "We need camera access to scan your crops for Fall Armyworm damage. Your photos are only used for analysis and are not stored without your consent."
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Not Now"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Allow"),
              ),
            ],
          );
        },
      );
      if (allowed != true) return;
      await Permission.camera.request();
    }

    final image = await CameraService().takePicture();
    if (image != null) {
      // Immediate image compression before MLM evaluation and storage entering
      final compressedFile = await ImageService.prepareImage(image);
      _handleImage(XFile(compressedFile.path));
    }
  }

  Future<void> _triggerGallery() async {
    HapticFeedback.mediumImpact();
    final image = await CameraService().chooseFromGallery();
    if (image != null) {
      // Immediate image compression before MLM evaluation and storage entering
      final compressedFile = await ImageService.prepareImage(image);
      _handleImage(XFile(compressedFile.path));
    }
  }

  void _showScanOptionsBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  "Scan Your Crop",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1B4332),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Choose an action to check for pests",
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ScaleOnTap(
                        onTap: () {
                          Navigator.pop(context);
                          _triggerCamera();
                        },
                        child: _buildSheetActionCard(
                          icon: Icons.camera_alt_rounded,
                          label: "Open Camera",
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2D6A4F), Color(0xFF52B788)],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ScaleOnTap(
                        onTap: () {
                          Navigator.pop(context);
                          _triggerGallery();
                        },
                        child: _buildSheetActionCard(
                          icon: Icons.photo_library_rounded,
                          label: "Choose Gallery",
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1B4332), Color(0xFF40916C)],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSheetActionCard({
    required IconData icon,
    required String label,
    required Gradient gradient,
  }) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 30, color: Colors.white),
          const SizedBox(height: 10),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) return;
        bool handled = false;
        context.visitAncestorElements((element) {
          if (element is StatefulElement) {
            final state = element.state;
            try {
              (state as dynamic).navigateToPreviousTab();
              handled = true;
              return false; // Stop traversing
            } catch (_) {
              // Method not found, keep traversing up
            }
          }
          return true; // Keep traversing up
        });
        if (!handled && context.mounted) {
          Navigator.of(context).pop(result);
        }
      },
      child: Scaffold(
       backgroundColor: const Color(0xFFE8EEE8),
      appBar: AppBar(
        title: Text(
          l10n.scanHub,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1B4332),
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      floatingActionButtonLocation: const AboveNavFabLocation(),
      floatingActionButton: FloatingScanButton(
        onPressed: _showScanOptionsBottomSheet,
      ),
      body: Stack(
        children: [
          // Decorative background blobs to match app-wide style
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color.fromARGB(255, 27, 62, 46).withValues(alpha: 0.15),
              ),
            ),
          ),
          Positioned(
            top: 300,
            left: -40,
            child: Container(
              height: 160,
              width: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color.fromARGB(255, 40, 162, 105).withValues(alpha: 0.15),
              ),
            ),
          ),
          Positioned(
            bottom: 80,
            right: -20,
            child: Container(
              height: 180,
              width: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color.fromARGB(255, 85, 135, 92).withValues(alpha: 0.5),
              ),
            ),
          ),
          SingleChildScrollView(
            key: _storageKey,
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Premium Animated Hero Card
              PremiumHeroSection(
                title: l10n.scanYourCrop,
                subtitle: l10n.captureLeafInsect,
              ),

              const SizedBox(height: 20),

              // 2. Weather & Farm Status Card
              const _WeatherFarmStatusCard(),

              const SizedBox(height: 20),

              // 3. AI Assistant Card
              const _AiAssistantCard(),

              const SizedBox(height: 24),

              // 4. Primary Actions (Buttons wrapped in Scale animations)
              Row(
                children: [
                  Expanded(
                    child: ScaleOnTap(
                      onTap: _triggerCamera,
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2D6A4F), Color(0xFF52B788)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2D6A4F).withValues(alpha: 0.15),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            )
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.camera_alt_rounded, size: 24, color: Colors.white),
                            const SizedBox(height: 8),
                            Text(
                              l10n.openCamera,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ScaleOnTap(
                      onTap: _triggerGallery,
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1B4332), Color(0xFF40916C)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1B4332).withValues(alpha: 0.15),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            )
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.photo_library_rounded, size: 24, color: Colors.white),
                            const SizedBox(height: 8),
                            Text(
                              l10n.chooseFromGallery,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // 5. AI Tips Rotation Banner (Decoupled & Highly Optimized)
              const AiTipsSection(),

              const SizedBox(height: 28),

              // 6. Recent Visual Scans & Images - deferred to reduce initial build cost
              if (_showDeferredContent)
                ValueListenableBuilder<List<ScanHistoryItem>>(
                  valueListenable: _historyNotifier,
                  builder: (context, history, _) {
                    return RecentScansSection(
                      history: history,
                      onStartScan: _showScanOptionsBottomSheet,
                      onLoadHistory: _loadHistory,
                    );
                  },
                )
              else
                // lightweight placeholder to avoid layout jumps
                Container(height: 236, decoration: BoxDecoration(color: Colors.transparent)),

              const SizedBox(height: 32),

              // 7. Quick Tips Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.01),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    )
                  ],
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.tipsForDetection,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: const Color(0xFF1B4332),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTipItem(Icons.center_focus_weak_rounded, l10n.tipOneSubject),
                    const SizedBox(height: 12),
                    _buildTipItem(Icons.filter_center_focus_rounded, l10n.tipKeepFocused),
                    const SizedBox(height: 12),
                    _buildTipItem(Icons.zoom_in_rounded, l10n.tipMoveCloser),
                    const SizedBox(height: 12),
                    _buildTipItem(Icons.light_mode_rounded, l10n.tipUseDaylight),
                    const SizedBox(height: 12),
                    _buildTipItem(Icons.do_not_disturb_on_rounded, l10n.tipAvoidUnrelated),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 8. Farmer Education Guide
              const GuideCardsSection(),

              // Standard spacer to prevent Floating Action Button from blocking visual content
              const SizedBox(height: 96),
            ],
          ),
        ),
      ),
        ],
      ),
     ),
    );
  }

  Widget _buildTipItem(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFF2D6A4F).withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 15, color: const Color(0xFF2D6A4F)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }
}

// Weather & Farm Risk Card
class _WeatherFarmStatusCard extends StatelessWidget {
  const _WeatherFarmStatusCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.green.shade50),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.wb_sunny_rounded, color: Colors.amber.shade700, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    "Farm Weather & Risk",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: const Color(0xFF1B4332),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade100),
                ),
                child: Text(
                  "Optimal Check",
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF2D6A4F),
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetricItem(
                icon: Icons.thermostat_rounded,
                iconColor: Colors.orange.shade700,
                label: "Temperature",
                value: "29°C",
              ),
              Container(width: 1, height: 36, color: Colors.grey.shade100),
              _buildMetricItem(
                icon: Icons.water_drop_rounded,
                iconColor: Colors.blue.shade700,
                label: "Humidity",
                value: "72%",
              ),
              Container(width: 1, height: 36, color: Colors.grey.shade100),
              _buildMetricItem(
                icon: Icons.bug_report_rounded,
                iconColor: Colors.red.shade700,
                label: "FAW Risk",
                value: "Medium",
                valueColor: Colors.red.shade700,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.lightbulb_outline_rounded, color: Colors.amber.shade800, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Today's Advice: High humidity triggers faster larval activity. Focus scanning under leaves today.",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: valueColor ?? const Color(0xFF1B4332),
          ),
        ),
      ],
    );
  }
}

// Ask AI Assistant Card
class _AiAssistantCard extends StatelessWidget {
  const _AiAssistantCard();

  @override
  Widget build(BuildContext context) {
    return ScaleOnTap(
      onTap: () {
        Navigator.push(
          context,
          _createPremiumRoute(const KrishiChatPage()),
        );
      },
      child: Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.15),
            blurRadius: 15,
            offset: const Offset(0, 6),
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
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_awesome_rounded, color: Color(0xFF38BDF8), size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                "Ask Krishi AI",
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "Instant answers about pest identification, treatments, and organic spray solutions.",
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: const Color(0xFFCBD5E1),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildQueryChip(context, "How to identify FAW?"),
              _buildQueryChip(context, "How to protect crops?"),
              _buildQueryChip(context, "Why are leaves yellow?"),
            ],
          ),
        ],
      ),
    ));
  }

  Widget _buildQueryChip(BuildContext context, String query) {
    return ScaleOnTap(
      onTap: () {
        Navigator.push(
          context,
          _createPremiumRoute(
            KrishiChatPage(initialQuery: query),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        child: Text(
          query,
          style: GoogleFonts.poppins(
            color: const Color(0xFF38BDF8),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// Simulated Krishi AI Chat Page
class _AiAssistantChatPage extends StatefulWidget {
  final String initialQuery;
  const _AiAssistantChatPage({required this.initialQuery});

  @override
  State<_AiAssistantChatPage> createState() => _AiAssistantChatPageState();
}

class _AiAssistantChatPageState extends State<_AiAssistantChatPage> {
  final List<Map<String, String>> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _messages.add({
      "sender": "ai",
      "text": "Namaste! I am your AI Farmer Assistant. How can I help you support your maize and other crops today?"
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sendUserMessage(widget.initialQuery);
    });
  }

  void _sendUserMessage(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add({
        "sender": "user",
        "text": text,
      });
      _isTyping = true;
    });
    _scrollToBottom();

    Timer(const Duration(seconds: 1), () {
      if (!mounted) return;

      String aiResponse = "";
      final query = text.toLowerCase();
      if (query.contains("identify")) {
        aiResponse = "To identify Fall Armyworm (FAW):\n\n"
            "1. Check for the characteristic light-colored 'Y' shape on the front of the head.\n"
            "2. Look for four dark spots arranged in a square on the eighth segment of the tail.\n"
            "3. Look for 'window-pane' feeding patterns on lower crop leaves.";
      } else if (query.contains("protect")) {
        aiResponse = "To protect crops from Fall Armyworm:\n\n"
            "1. Practice intercropping: Plant greenleaf desmodium between maize rows to repel the moths.\n"
            "2. Handpick larvae: Remove egg masses and larvae manually on small farms.\n"
            "3. Apply neem extract or botanical pesticide solutions at twilight.";
      } else if (query.contains("yellow")) {
        aiResponse = "Leaves turning yellow can be caused by:\n\n"
            "1. Nitrogen Deficiency: Starts on older lower leaves and progresses along the midrib.\n"
            "2. Overwatering/Poor Drainage: Roots drown and cannot absorb nutrients properly.\n"
            "3. Pest Damage: Root infestation or sap-sucking insects can stunt leaves.";
      } else {
        aiResponse = "That is a great agricultural question! I recommend inspecting your leaves regularly, keeping a clean field, and ensuring proper crop rotation. Let me know if you would like specific FAW management suggestions!";
      }

      setState(() {
        _isTyping = false;
        _messages.add({
          "sender": "ai",
          "text": aiResponse,
        });
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          "Krishi AI Assistant",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade700),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "AI is thinking...",
                            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final msg = _messages[index];
                final isAi = msg["sender"] == "ai";
                return Align(
                  alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: isAi ? Colors.white : const Color(0xFF2D6A4F),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(18),
                        topRight: const Radius.circular(18),
                        bottomLeft: isAi ? const Radius.circular(0) : const Radius.circular(18),
                        bottomRight: isAi ? const Radius.circular(18) : const Radius.circular(0),
                      ),
                    ),
                    child: Text(
                      msg["text"] ?? "",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: isAi ? const Color(0xFF1E293B) : Colors.white,
                        height: 1.4,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      style: GoogleFonts.poppins(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: "Ask anything about crop care...",
                        hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      onSubmitted: (val) {
                        if (val.trim().isNotEmpty) {
                          _sendUserMessage(val);
                          _textController.clear();
                        }
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send_rounded, color: Color(0xFF2D6A4F)),
                    onPressed: () {
                      if (_textController.text.trim().isNotEmpty) {
                        _sendUserMessage(_textController.text);
                        _textController.clear();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Fade + Slide Route Transition Builder
Route _createPremiumRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 0.05); // slight slide up
      const end = Offset.zero;
      const curve = Curves.easeOutCubic;

      var slideTween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var fadeTween = Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(slideTween),
        child: FadeTransition(
          opacity: animation.drive(fadeTween),
          child: child,
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 350),
  );
}

/// Custom Floating Action Button Location to position the scan button
/// cleanly and safely above the floating glass bottom navigation bar.
class AboveNavFabLocation extends FloatingActionButtonLocation {
  const AboveNavFabLocation();

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final double fabX = (scaffoldGeometry.scaffoldSize.width - scaffoldGeometry.floatingActionButtonSize.width) / 2.0;

    // Use the bottom inset (includes safe area) for spacing
    final double bottomInset = scaffoldGeometry.minInsets.bottom;
    // Position FAB lower (closer to bottom) — reduced offset
    final double bottomOffset = bottomInset + 64.0;

    final double fabY = scaffoldGeometry.scaffoldSize.height - scaffoldGeometry.floatingActionButtonSize.height - bottomOffset;
    return Offset(fabX, fabY);
  }
}
