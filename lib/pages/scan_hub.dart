import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../l10n/app_localizations.dart';
import '../features/camera/camera_service.dart';
import '../services/scan_history_service.dart';
import '../services/image_service.dart';
import '../widgets/scale_on_tap.dart';
import '../screens/result_screen.dart';
import '../screens/history_screen.dart';

// Import our new decomposed sub-widgets
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
      _createPremiumRoute(ResultScreen(image: image)),
    );
    _loadHistory();
  }

  Future<void> _triggerCamera() async {
    if (Platform.isAndroid) {
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
    }

    final image = await CameraService().takePicture();
    if (image != null) {
      // Immediate image compression before MLM evaluation and storage entering
      final compressedFile = await ImageService.prepareImage(image);
      _handleImage(XFile(compressedFile.path));
    }
  }

  Future<void> _triggerGallery() async {
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
       backgroundColor: const Color(0xFFF3F7F4),
      appBar: AppBar(
        title: Text(
          "Scan Hub",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E6B52),
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E6B52)),
          onPressed: () {
            bool handled = false;
            context.visitAncestorElements((element) {
              if (element is StatefulElement) {
                final state = element.state;
                try {
                  (state as dynamic).navigateToPreviousTab();
                  handled = true;
                  return false; // Stop traversing
                } catch (_) {}
              }
              return true;
            });
            if (!handled && Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded, color: Color(0xFF1E6B52)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryScreen()),
              );
            },
          ),
        ],
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
                color: const Color(0xFF1E6B52).withValues(alpha: 0.06),
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
                color: const Color(0xFF58D9A6).withValues(alpha: 0.06),
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
                color: const Color(0xFF1E6B52).withValues(alpha: 0.06),
              ),
            ),
          ),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: SingleChildScrollView(
                key: _storageKey,
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Text(
                          "FAW AI-powered crop diagnosis in seconds",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline_rounded, color: Color(0xFFD97706), size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "FAW AI can make mistakes, check important info",
                                style: GoogleFonts.poppins(
                                  fontSize: 11.5,
                                  color: const Color(0xFFB45309),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // 1. Animated Scanner Circle & Badge
                      const AnimatedScanner(),

                      const SizedBox(height: 24),

                      // 2. Weather & Farm Status Card
                      const _WeatherFarmStatusCard(),

                      const SizedBox(height: 24),

                      // 3. AI Assistant Card
                      const _AiAssistantCard(),

                      const SizedBox(height: 24),

                      // 4. Primary Actions (Row of buttons height 56px, radius 16px)
                      Row(
                        children: [
                          Expanded(
                            child: ScaleOnTap(
                              onTap: _triggerCamera,
                              child: Container(
                                height: 56,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E6B52),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF1E6B52).withValues(alpha: 0.15),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    )
                                  ],
                                ),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.camera_alt_rounded, size: 20, color: Colors.white),
                                          const SizedBox(width: 8),
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
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ScaleOnTap(
                              onTap: _triggerGallery,
                              child: Container(
                                height: 56,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFF1E6B52), width: 1.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.02),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    )
                                  ],
                                ),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.photo_library_rounded, size: 20, color: Color(0xFF1E6B52)),
                                          const SizedBox(width: 8),
                                          Text(
                                            l10n.chooseFromGallery,
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                              color: const Color(0xFF1E6B52),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // 5. AI Tips Rotation Banner (Decoupled & Highly Optimized)
                      const AiTipsSection(),

                      const SizedBox(height: 24),

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
                        Container(height: 236, decoration: const BoxDecoration(color: Colors.transparent)),

                      const SizedBox(height: 32),

                      // 7. Quick Tips Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2EFE7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.lightbulb_outline_rounded,
                                color: Color(0xFF1E6B52),
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.tipsForDetection,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: const Color(0xFF1E6B52),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  _buildTipCheckmark(l10n.tipOneSubject),
                                  const SizedBox(height: 4),
                                  _buildTipCheckmark(l10n.tipUseDaylight),
                                  const SizedBox(height: 4),
                                  _buildTipCheckmark(l10n.tipKeepFocused),
                                  const SizedBox(height: 4),
                                  _buildTipCheckmark(l10n.tipMoveCloser),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: Color(0xFF1E6B52),
                              size: 24,
                            ),
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
            ),
          ),
        ],
      ),
     ),
    );
  }

  Widget _buildTipCheckmark(String text) {
    return Row(
      children: [
        const Icon(Icons.check_rounded, color: Color(0xFF1E6B52), size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color(0xFF1E6B52),
              fontWeight: FontWeight.w500,
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
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFF1E6B52).withValues(alpha: 0.08)),
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
                      color: const Color(0xFF1E6B52),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E6B52).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF1E6B52).withValues(alpha: 0.15)),
                ),
                child: Text(
                  "Optimal Check",
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF1E6B52),
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
                iconColor: const Color(0xFF3B82F6),
                label: "Temperature",
                value: "29°C",
              ),
              Container(width: 1, height: 36, color: const Color(0xFF1E6B52).withValues(alpha: 0.08)),
              _buildMetricItem(
                icon: Icons.water_drop_rounded,
                iconColor: Colors.blue.shade700,
                label: "Humidity",
                value: "72%",
              ),
              Container(width: 1, height: 36, color: const Color(0xFF1E6B52).withValues(alpha: 0.08)),
              _buildMetricItem(
                icon: Icons.verified_user_rounded,
                iconColor: Colors.orange.shade700,
                label: "Risk Level",
                value: "Medium",
                valueColor: Colors.orange.shade700,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(height: 1, color: const Color(0xFF1E6B52).withValues(alpha: 0.08)),
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
            color: valueColor ?? const Color(0xFF1E6B52),
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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: const Color(0xFF58D9A6).withValues(alpha: 0.12),
              blurRadius: 24,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.auto_awesome_rounded, color: Color(0xFF58D9A6), size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Ask Krishi FAW AI",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Get instant answers about pests, treatments, and crop care.",
                    style: GoogleFonts.poppins(
                      fontSize: 12.5,
                      color: const Color(0xFFCBD5E1),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 20),
            ),
          ],
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
      "text": "Namaste! I am your FAW AI Farmer Assistant. How can I help you support your maize and other crops today?"
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
          "Krishi FAW AI Assistant",
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

class AnimatedScanner extends StatefulWidget {
  const AnimatedScanner({super.key});

  @override
  State<AnimatedScanner> createState() => _AnimatedScannerState();
}

class _AnimatedScannerState extends State<AnimatedScanner> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 24),
        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer pulsing ring
              ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF58D9A6).withValues(alpha: 0.08),
                    border: Border.all(
                      color: const Color(0xFF58D9A6).withValues(alpha: 0.25),
                      width: 2,
                    ),
                  ),
                ),
              ),
              // Inner pulsing ring
              ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  width: 115,
                  height: 115,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF1E6B52).withValues(alpha: 0.05),
                    border: Border.all(
                      color: const Color(0xFF1E6B52).withValues(alpha: 0.15),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              // Rotating dots container
              RotationTransition(
                turns: _rotationController,
                child: SizedBox(
                  width: 155,
                  height: 155,
                  child: Stack(
                    children: [
                      // Dot 1
                      Positioned(
                        top: 0,
                        left: 77 - 4,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF58D9A6),
                          ),
                        ),
                      ),
                      // Dot 2
                      Positioned(
                        bottom: 0,
                        left: 77 - 4,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF1E6B52),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Center circle with leaf icon
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1E6B52).withValues(alpha: 0.1),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: const Color(0xFF1E6B52).withValues(alpha: 0.08),
                    width: 1.5,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.energy_savings_leaf_rounded,
                    size: 44,
                    color: Color(0xFF1E6B52),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // "AI Ready to Assist" Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF58D9A6).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: const Color(0xFF58D9A6).withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF1E6B52),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "FAW AI ready to assist",
                style: GoogleFonts.poppins(
                  color: const Color(0xFF1E6B52),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
