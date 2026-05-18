import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/predict_result.dart';
import '../../widgets/error_handler.dart';
import 'prediction_service.dart';
import '../../services/result_cache_service.dart';
import '../../services/pending_prediction_queue.dart';
import '../../services/scan_history_service.dart';
import '../../pages/krishi_chat.dart';
import '../../widgets/scale_on_tap.dart';

class PredictionPage extends StatefulWidget {
  final XFile image;
  final PredictResult? initialResult;

  const PredictionPage({
    super.key,
    required this.image,
    this.initialResult,
  });

  @override
  State<PredictionPage> createState() => _PredictionPageState();
}

class _PredictionPageState extends State<PredictionPage> {
  bool _isLoading = true;
  PredictResult? _result;
  AppExceptionType? _errorType;
  
  PredictResult? _lastResult;
  DateTime? _lastResultTime;
  int _pendingCount = 0;
  bool _showHistory = false;
  bool _isStepsExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _predict();
  }

  Future<void> _loadInitialData() async {
    final pending = await PendingPredictionQueue.getPendingCount();
    
    if (mounted) {
      setState(() {
        _pendingCount = pending;
      });
    }
  }

  Future<void> _predict() async {
    setState(() {
      _isLoading = true;
      _errorType = null;
      _result = null;
      _lastResult = null;
      _lastResultTime = null;
      _showHistory = false;
    });

    if (widget.initialResult != null) {
      if (mounted) {
        setState(() {
          _result = widget.initialResult;
          _isLoading = false;
        });
      }
      return;
    }

    try {
      final result = await PredictionService.predict(widget.image);
      final pending = await PendingPredictionQueue.getPendingCount();
      
      if (result.action == 'result') {
        await ScanHistoryService.saveScan(widget.image.path, result);
      }
      
      if (mounted) {
        setState(() {
          _result = result;
          _isLoading = false;
          _pendingCount = pending;
        });
      }
    } catch (e) {
      print("DEBUG: Prediction Error in UI: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          if (e is AppException) {
            _errorType = e.type;
          } else {
            _errorType = AppExceptionType.server;
          }
        });
      }
    }
  }

  Widget _buildLoading() {
    return const _AnalyzingIndicator();
  }

  Widget _buildError() {
    return ErrorHandler(
      type: _errorType ?? AppExceptionType.server,
      onRetry: _predict,
    );
  }

  Widget _buildSuccess(PredictResult result) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_pendingCount > 0) _buildPendingBanner(),
          
          // Premium Hero Image Preview with Rounded Top Corners & Shadow
          Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.file(
                    File(widget.image.path),
                    fit: BoxFit.cover,
                    height: 280,
                    width: double.infinity,
                    cacheWidth: 800,
                  ),
                  // Future Architecture Hook: Once YOLO-based model detection is enabled in backend,
                  // bounding-box coordinates can be parsed from `result.prediction` and rendered here
                  // via a custom painter or positioned widget overlays.
                ],
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: _buildActionResult(result),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingBanner() {
    return Container(
      color: Colors.orange.shade800,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: InkWell(
        onTap: () async {
          await PendingPredictionQueue.processPending();
          final count = await PendingPredictionQueue.getPendingCount();
          setState(() { _pendingCount = count; });
        },
        child: Row(
          children: [
            const Icon(Icons.sync, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              "$_pendingCount analysis pending",
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            const Text("Retry Now", style: TextStyle(color: Colors.white, fontSize: 12, decoration: TextDecoration.underline)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard({
    required String title,
    required String subtitle,
    required List<Color> gradient,
    required IconData icon,
    Widget? extraChild,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 36),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (extraChild != null) ...[
            const SizedBox(height: 20),
            extraChild,
          ],
        ],
      ),
    );
  }

  Widget _buildTipsCard({
    required String emoji,
    required String sectionTitle,
    required List<String> tips,
    required Color themeColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: themeColor.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Text(
                sectionTitle,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: themeColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...tips.map((tip) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "✓ ",
                  style: TextStyle(
                    color: themeColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Expanded(
                  child: Text(
                    tip.replaceFirst("✓ ", "").replaceFirst("• ", ""),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildCacheCard() {
    final result = _lastResult;
    final time = _lastResultTime;
    if (result == null || time == null) return const SizedBox.shrink();
    
    final pred = result.prediction;
    if (pred == null) return const SizedBox.shrink();
    
    final timeAgo = DateTime.now().difference(time).inHours;
    final timeStr = timeAgo == 0 ? "Just now" : "$timeAgo hours ago";

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blueGrey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.history, size: 18, color: Colors.blueGrey),
              const SizedBox(width: 8),
              const Text("Last Successful Result", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
              const Spacer(),
              Text(timeStr, style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
            ],
          ),
          const Divider(),
          Text("${pred.displayName} (${(pred.confidence * 100).toStringAsFixed(0)}%)", 
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildActionResult(PredictResult result) {
    // Add Slide & Fade Entrance Animation
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1.0 - value)),
            child: child,
          ),
        );
      },
      child: _buildRawActionResult(result),
    );
  }

  Widget _buildRawActionResult(PredictResult result) {
    switch (result.action) {
      case 'result':
        return _buildPredictionResult(result);
      case 'retake':
        return _buildRetake(result);
      case 'reject':
        return _buildReject(result);
      case 'abstain':
        return _buildAbstain(result);
      case 'offline':
        return _buildOfflineResult(result);
      default:
        return const Center(child: Text("Unexpected response from server"));
    }
  }

  Widget _buildCircularConfidence(double confidence) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1200),
      curve: Curves.fastOutSlowIn,
      tween: Tween<double>(begin: 0.0, end: confidence),
      builder: (context, value, child) {
        final int pct = (value * 100).round();
        final String label;
        final Color badgeBg;
        final Color badgeText;

        if (pct < 50) {
          label = "Low confidence";
          badgeBg = const Color(0xFFFEE2E2);
          badgeText = const Color(0xFF991B1B);
        } else if (pct < 75) {
          label = "Moderate confidence";
          badgeBg = const Color(0xFFFEF3C7);
          badgeText = const Color(0xFF92400E);
        } else if (pct < 90) {
          label = "High confidence";
          badgeBg = const Color(0xFFDBEAFE);
          badgeText = const Color(0xFF1E40AF);
        } else {
          label = "Very high confidence";
          badgeBg = const Color(0xFFD1FAE5);
          badgeText = const Color(0xFF065F46);
        }

        return Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 58,
                  height: 58,
                  child: CircularProgressIndicator(
                    value: value,
                    strokeWidth: 5.5,
                    color: Colors.white,
                    backgroundColor: Colors.white24,
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Icon(
                  pct < 50 ? Icons.trending_down_rounded : Icons.trending_up_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(width: 18),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$pct%',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.5,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: badgeText,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildPredictionResult(PredictResult result) {
    final pred = result.prediction!;
    final bool isLowConfidence = pred.confidence < 0.65;
    final bool isMediumConfidence = pred.confidence >= 0.65 && pred.confidence < 0.75;
    final bool isFaw = pred.isFaw ?? false;
    final String label = pred.label.toLowerCase();

    final List<Color> gradientColors;
    final IconData statusIcon;
    final String statusTitle;
    final String statusSubtitle;

    if (isLowConfidence) {
      gradientColors = [const Color(0xFFD97706), const Color(0xFFFBBF24)];
      statusIcon = Icons.help_outline_rounded;
      statusTitle = "Result Uncertain";
      statusSubtitle = "Low Confidence: ${pred.displayName}";
    } else if (isFaw || label == 'faw') {
      gradientColors = [const Color(0xFFB91C1C), const Color(0xFFEF4444)];
      statusIcon = Icons.bug_report_rounded;
      statusTitle = "Fall Armyworm Detected";
      statusSubtitle = pred.displayName;
    } else if (label == 'healthy') {
      gradientColors = [const Color(0xFF1E5631), const Color(0xFF4C9A2A)];
      statusIcon = Icons.check_circle_rounded;
      statusTitle = "Healthy";
      statusSubtitle = pred.displayName;
    } else if (label == 'damaged') {
      gradientColors = [const Color(0xFFE65C00), const Color(0xFFF9D423)];
      statusIcon = Icons.warning_rounded;
      statusTitle = "Damaged";
      statusSubtitle = pred.displayName;
    } else {
      gradientColors = [const Color(0xFF2563EB), const Color(0xFF3B82F6)];
      statusIcon = Icons.search_rounded;
      statusTitle = "Other Insect";
      statusSubtitle = pred.displayName;
    }

    // Dynamic Severity Chips (M3 Design)
    final String severity = result.treatment?.urgency.toUpperCase() ?? "LOW";
    final Color chipBgColor;
    final Color chipTextColor;

    if (severity == "HIGH") {
      chipBgColor = const Color(0xFFFEE2E2);
      chipTextColor = const Color(0xFF991B1B);
    } else if (severity == "MEDIUM") {
      chipBgColor = const Color(0xFFFEF3C7);
      chipTextColor = const Color(0xFF92400E);
    } else {
      chipBgColor = const Color(0xFFD1FAE5);
      chipTextColor = const Color(0xFF065F46);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Premium Hero Result Card
        _buildHeroCard(
          title: statusTitle,
          subtitle: statusSubtitle,
          gradient: gradientColors,
          icon: statusIcon,
          extraChild: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(color: Colors.white30, height: 20),
              _buildCircularConfidence(pred.confidence),
            ],
          ),
        ),

        const SizedBox(height: 20),
        
        // Severity Chip
        if (!isLowConfidence) ...[
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: chipBgColor,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: chipTextColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "$severity SEVERITY",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: chipTextColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],

        // Friendly Explanation Text & Tips Card Mapped Directly
        if (isLowConfidence) ...[
          _buildTipsCard(
            emoji: "❓",
            sectionTitle: "Suggestions",
            themeColor: const Color(0xFFD97706),
            tips: [
              "Retake image from another angle",
              "Improve lighting",
              "Capture closer details",
            ],
          ),
        ] else ...[
          if (isFaw || label == 'faw') ...[
            _buildTipsCard(
              emoji: "🐛",
              sectionTitle: "Immediate Actions",
              themeColor: const Color(0xFFB91C1C),
              tips: [
                "Inspect nearby plants",
                "Remove heavily affected leaves",
                "Follow treatment guidance",
              ],
            ),
          ] else if (label == 'healthy') ...[
            _buildTipsCard(
              emoji: "🌱",
              sectionTitle: "Tips",
              themeColor: const Color(0xFF1E5631),
              tips: [
                "Continue monitoring regularly",
                "Maintain field hygiene",
                "Check nearby crops periodically",
              ],
            ),
          ] else if (label == 'damaged') ...[
            _buildTipsCard(
              emoji: "⚠",
              sectionTitle: "Suggestions",
              themeColor: const Color(0xFFE65C00),
              tips: [
                "Inspect affected areas closely",
                "Monitor spread patterns",
                "Consider treatment recommendations",
              ],
            ),
          ] else ...[
            _buildTipsCard(
              emoji: "🔍",
              sectionTitle: "Suggestions",
              themeColor: const Color(0xFF2563EB),
              tips: [
                "Capture a closer image if needed",
                "Monitor crop condition",
                "Compare with future scans",
              ],
            ),
          ],
        ],

        const SizedBox(height: 20),
        _buildKrishiAiConsultationCard(context, result),

        if (result.treatment != null && !isLowConfidence) ...[
          const SizedBox(height: 20),
          _buildTreatmentCard(result.treatment!),
        ],

        if (isMediumConfidence) ...[
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.amber.shade100,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.amber.shade800,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Medium confidence. For better accuracy, ensure the subject is clearly in focus.",
                    style: GoogleFonts.poppins(
                      fontSize: 13, 
                      color: Colors.amber.shade900,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        
        const SizedBox(height: 28),
        _buildScanAgainButton(),
      ],
    );
  }

  Widget _buildStepRow(String step) {
    String emoji = "📋";
    final stepLower = step.toLowerCase();
    
    if (stepLower.contains("monitoring") || stepLower.contains("monitor")) {
      emoji = "👁";
    } else if (stepLower.contains("hygiene") || stepLower.contains("clean")) {
      emoji = "🧹";
    } else if (stepLower.contains("nearby") || stepLower.contains("crop") || stepLower.contains("plant")) {
      emoji = "🌱";
    } else if (stepLower.contains("identify") || stepLower.contains("pest")) {
      emoji = "🔍";
    } else if (stepLower.contains("consult") || stepLower.contains("expert") || stepLower.contains("officer")) {
      emoji = "👨‍🌾";
    } else if (stepLower.contains("apply") || stepLower.contains("biological") || stepLower.contains("treatment")) {
      emoji = "🧪";
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              step,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKrishiAiConsultationCard(BuildContext context, PredictResult result) {
    return ScaleOnTap(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => KrishiChatPage(
              scanContext: {
                "prediction": result.prediction?.label == "damaged" ? "Fall Armyworm suspected" : "Healthy leaf",
                "confidence": result.prediction?.confidence ?? 0.0,
                "crop_type": "maize",
              },
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1B4332), Color(0xFF0F172A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1B4332).withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome_outlined,
                color: Color(0xFF38BDF8),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Ask Krishi AI Assistant",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Get immediate botanical spray advice and tailored treatment options for this scan.",
                    style: GoogleFonts.poppins(
                      color: const Color(0xFFCBD5E1),
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.white,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTreatmentCard(Treatment treatment) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Recommended Action",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: const Color(0xFF1B4332)),
                ),
                const SizedBox(height: 6),
                Text(
                  treatment.summary,
                  style: GoogleFonts.poppins(color: Colors.black87, fontSize: 14, height: 1.4),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade200),
          InkWell(
            onTap: () {
              setState(() {
                _isStepsExpanded = !_isStepsExpanded;
              });
            },
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  const Icon(Icons.list_alt_rounded, size: 20, color: Color(0xFF2D6A4F)),
                  const SizedBox(width: 10),
                  Text(
                    "Steps to Take",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15, color: const Color(0xFF2D6A4F)),
                  ),
                  const Spacer(),
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 200),
                    turns: _isStepsExpanded ? 0.5 : 0.0,
                    child: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF2D6A4F)),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                children: treatment.steps.map((step) => _buildStepRow(step)).toList(),
              ),
            ),
            crossFadeState: _isStepsExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 350),
            firstCurve: Curves.easeInOut,
            secondCurve: Curves.easeInOut,
          ),
        ],
      ),
    );
  }

  Widget _buildRetake(PredictResult result) {
    final guidance = result.guidance!;
    return Column(
      children: [
        _buildHeroCard(
          title: "Quality Issue",
          subtitle: guidance.title,
          gradient: [const Color(0xFFD97706), const Color(0xFFFBBF24)],
          icon: Icons.photo_camera_rounded,
          extraChild: Text(
            guidance.instruction,
            style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 15, height: 1.4),
          ),
        ),
        const SizedBox(height: 20),
        _buildTipsCard(
          emoji: "📷",
          sectionTitle: "Tips for a better photo",
          themeColor: const Color(0xFFD97706),
          tips: [
            "Move closer",
            "Focus on one subject",
            "Avoid blur",
            "Use sunlight",
          ],
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            label: const Text("Retake Photo", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD97706),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReject(PredictResult result) {
    final guidance = result.guidance!;
    return Column(
      children: [
        _buildHeroCard(
          title: "Rejected",
          subtitle: guidance.title,
          gradient: [const Color(0xFF4B5563), const Color(0xFF9CA3AF)],
          icon: Icons.error_outline_rounded,
          extraChild: Text(
            guidance.instruction,
            style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 15, height: 1.4),
          ),
        ),
        const SizedBox(height: 20),
        _buildTipsCard(
          emoji: "🌿",
          sectionTitle: "Try these steps",
          themeColor: const Color(0xFF4B5563),
          tips: [
            "Capture leaf directly",
            "Keep background simple",
            "Avoid unrelated objects",
          ],
        ),
        const SizedBox(height: 32),
        _buildScanAgainButton(),
      ],
    );
  }

  Widget _buildAbstain(PredictResult result) {
    return Column(
      children: [
        _buildHeroCard(
          title: "Uncertain Result",
          subtitle: "Analysis Incomplete",
          gradient: [const Color(0xFF374151), const Color(0xFF6B7280)],
          icon: Icons.help_outline_rounded,
          extraChild: const Text(
            "Our system is unable to provide a high-confidence classification for this image. Please try another photo or consult an expert.",
            style: TextStyle(color: Colors.white70, fontSize: 15, height: 1.4),
          ),
        ),
        const SizedBox(height: 20),
        _buildTipsCard(
          emoji: "❓",
          sectionTitle: "Suggestions",
          themeColor: const Color(0xFF374151),
          tips: [
            "Retake image from another angle",
            "Improve lighting",
            "Capture closer details",
          ],
        ),
        const SizedBox(height: 32),
        _buildScanAgainButton(),
      ],
    );
  }

  Widget _buildOfflineResult(PredictResult result) {
    final guidance = result.guidance!;
    return Column(
      children: [
        _buildHeroCard(
          title: "Connection Lost",
          subtitle: guidance.title,
          gradient: [const Color(0xFF374151), const Color(0xFF6B7280)],
          icon: Icons.wifi_off_rounded,
          extraChild: Text(
            guidance.instruction,
            style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.4),
          ),
        ),
        const SizedBox(height: 24),
        
        if (!_showHistory)
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () async {
                final cached = await ResultCacheService.loadLastResult();
                if (cached != null && mounted) {
                  setState(() {
                    _lastResult = cached['result'];
                    _lastResultTime = cached['time'];
                    _showHistory = true;
                  });
                }
              },
              icon: const Icon(Icons.history_rounded, size: 20),
              label: const Text("View Cached History", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                side: const BorderSide(color: Colors.grey),
              ),
            ),
          ),
          
        if (_showHistory) ...[
          _buildCacheCard(),
          const SizedBox(height: 16),
        ],

        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2D6A4F),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text('OK', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildScanAgainButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.camera_alt_outlined, color: Colors.white),
        label: const Text('Scan Another Crop', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2D6A4F),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis'),
        centerTitle: true,
      ),
      body: _isLoading 
        ? _buildLoading() 
        : (_result != null) 
          ? _buildSuccess(_result!) 
          : _buildError(),
    );
  }
}

class _AnalyzingIndicator extends StatefulWidget {
  const _AnalyzingIndicator();

  @override
  State<_AnalyzingIndicator> createState() => _AnalyzingIndicatorState();
}

class _AnalyzingIndicatorState extends State<_AnalyzingIndicator> with TickerProviderStateMixin {
  late final AnimationController _scanController;
  late final Animation<double> _scanAnimation;
  
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  double _progress = 0.0;
  Timer? _progressTimer;

  final List<String> _stages = [
    "Scanning crop...",
    "Analyzing leaf...",
    "Checking pest patterns...",
    "Generating treatment...",
  ];

  @override
  void initState() {
    super.initState();
    
    // Vertical scanning sweep animation (moving plant/camera view)
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scanAnimation = Tween<double>(begin: 0.0, end: 120.0).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.easeInOut),
    );

    // Soft pulse/glow animation for plant/camera container
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Smooth progress simulation (reaches ~98% in ~7-8 seconds, slowing down)
    _startProgressTimer();
  }

  void _startProgressTimer() {
    const period = Duration(milliseconds: 100);
    _progressTimer = Timer.periodic(period, (timer) {
      if (!mounted) return;
      setState(() {
        if (_progress < 0.3) {
          _progress += 0.015; // Fast scan phase
        } else if (_progress < 0.6) {
          _progress += 0.010; // Medium analysis phase
        } else if (_progress < 0.85) {
          _progress += 0.006; // Fine pest patterns phase
        } else if (_progress < 0.98) {
          _progress += 0.002; // Very slow treatment generation phase
        }
        
        if (_progress > 0.98) {
          _progress = 0.98; // Hold near 100% until backend replies
        }
      });
    });
  }

  @override
  void dispose() {
    _scanController.dispose();
    _pulseController.dispose();
    _progressTimer?.cancel();
    super.dispose();
  }

  String _getCurrentStageText() {
    if (_progress < 0.25) {
      return _stages[0]; // Scanning crop...
    } else if (_progress < 0.50) {
      return _stages[1]; // Analyzing leaf...
    } else if (_progress < 0.75) {
      return _stages[2]; // Checking pest patterns...
    } else {
      return _stages[3]; // Generating treatment...
    }
  }

  IconData _getCurrentStageIcon() {
    if (_progress < 0.25) {
      return Icons.qr_code_scanner_rounded;
    } else if (_progress < 0.50) {
      return Icons.eco_rounded;
    } else if (_progress < 0.75) {
      return Icons.bug_report_outlined;
    } else {
      return Icons.assignment_turned_in_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentText = _getCurrentStageText();
    final currentIcon = _getCurrentStageIcon();
    final percentVal = (_progress * 100).toInt();

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Premium Scanning Arena (Moving Scan Line over glowing plant/camera)
            RepaintBoundary(
              child: ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2D6A4F).withOpacity(0.08),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      )
                    ],
                    border: Border.all(
                      color: const Color(0xFF2D6A4F).withOpacity(0.1),
                      width: 2,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer spinning circle
                      const SizedBox(
                        width: 130,
                        height: 130,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Color(0xFF52B788),
                          backgroundColor: Colors.transparent,
                        ),
                      ),
                      
                      // Central Camera & Plant icons overlay
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2D6A4F).withOpacity(0.06),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.eco_rounded,
                            size: 46,
                            color: Color(0xFF2D6A4F),
                          ),
                        ),
                      ),
                      
                      // Floating camera sub-badge to show plant/camera intersection
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFF2D6A4F),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      
                      // Moving scan line overlay (plant/camera moving sweep line)
                      AnimatedBuilder(
                        animation: _scanAnimation,
                        builder: (context, child) {
                          return Positioned(
                            top: _scanAnimation.value + 12.0,
                            left: 15,
                            right: 15,
                            child: Container(
                              height: 4,
                              decoration: BoxDecoration(
                                color: const Color(0xFF52B788),
                                borderRadius: BorderRadius.circular(2),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF52B788).withOpacity(0.8),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 48),
            
            // Dynamic Phase title
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                key: ValueKey(currentText),
                children: [
                  Icon(currentIcon, color: const Color(0xFF2D6A4F), size: 24),
                  const SizedBox(width: 10),
                  Text(
                    currentText,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1B4332),
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 10),
            
            Text(
              "Please hold your phone steady...",
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
            
            const SizedBox(height: 36),
            
            // Animated Gradient Progress Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Diagnosing...",
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D6A4F),
                  ),
                ),
                Text(
                  "$percentVal%",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2D6A4F),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                height: 8,
                width: double.infinity,
                child: LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: const Color(0xFF2D6A4F).withOpacity(0.08),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2D6A4F)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
