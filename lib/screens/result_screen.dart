import 'dart:io';
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/predict_response.dart';
import '../services/api_service.dart';
import '../services/scan_history_service.dart';
import '../services/image_service.dart';
import '../widgets/error_handler.dart';
import '../pages/krishi_chat.dart';
import '../widgets/scale_on_tap.dart';

class ResultScreen extends StatefulWidget {
  final XFile image;
  final PredictResponseModel? initialResult;

  const ResultScreen({
    super.key,
    required this.image,
    this.initialResult,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  PredictResponseModel? _result;
  AppExceptionType? _errorType;
  Size? _imageSize;
  bool _feedbackSubmitted = false;
  
  late AnimationController _scanningController;

  @override
  void initState() {
    super.initState();
    _scanningController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _loadImageSize();
    
    if (widget.initialResult != null) {
      _result = widget.initialResult;
      _isLoading = false;
    } else {
      _runPrediction();
    }
  }

  @override
  void dispose() {
    _scanningController.dispose();
    super.dispose();
  }

  Future<void> _loadImageSize() async {
    try {
      final Image image = Image.file(File(widget.image.path));
      image.image.resolve(const ImageConfiguration()).addListener(
        ImageStreamListener(
          (ImageInfo imageInfo, bool synchronousCall) {
            if (mounted) {
              setState(() {
                _imageSize = Size(
                  imageInfo.image.width.toDouble(),
                  imageInfo.image.height.toDouble(),
                );
              });
            }
          },
        ),
      );
    } catch (e) {
      debugPrint("Error resolving image size: $e");
    }
  }

  Future<void> _runPrediction() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorType = null;
      _result = null;
    });

    try {
      final File preparedFile = await ImageService.prepareImage(widget.image);
      final result = await ApiService.predict(preparedFile);
      
      // Cleanup prepared temp file
      await ImageService.cleanup(preparedFile);

      // Persist directly to scan history cache
      if (result.status != 'retake_image') {
        await ScanHistoryService.saveScan(widget.image.path, result);
      }

      if (mounted) {
        setState(() {
          _result = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error calling /predict: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorType = AppExceptionType.server;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7F4),
      appBar: AppBar(
        title: Text(
          "Diagnostic Result",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E6B52),
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E6B52), size: 16),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Decorative background blobs
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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
                  final isWide = constraints.maxWidth > 800 || isLandscape;

                  if (_isLoading) {
                    return _buildLoadingState();
                  }

                  if (_errorType != null) {
                    return _buildErrorState();
                  }

                  if (_result == null) {
                    return const Center(child: Text("No result received."));
                  }

                  return isWide ? _buildWideLayout(constraints) : _buildNarrowLayout(constraints);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.file(
                    File(widget.image.path),
                    width: 300,
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _scanningController,
                    builder: (context, child) {
                      return FractionallySizedBox(
                        alignment: Alignment.topCenter,
                        heightFactor: 0.05,
                        child: Transform.translate(
                          offset: Offset(0, 300 * _scanningController.value),
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Color(0xFF58D9A6),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(color: Color(0xFF1E6B52)),
            const SizedBox(height: 16),
            Text(
              "Analyzing leaf...",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E6B52),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Performing spatial crop diagnosis",
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return ErrorHandler(
      type: _errorType ?? AppExceptionType.server,
      onRetry: _runPrediction,
    );
  }

  Widget _buildNarrowLayout(BoxConstraints constraints) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildImageContainer(constraints.maxWidth, 320),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDiagnosticCard(),
                const SizedBox(height: 16),
                _buildDisclaimer(),
                const SizedBox(height: 24),
                _buildTreatmentCard(),
                const SizedBox(height: 24),
                _buildFeedbackWidget(),
                const SizedBox(height: 24),
                _buildKrishiAiConsultationCard(),
                const SizedBox(height: 24),
                _buildTechnicalDetailsTile(),
                const SizedBox(height: 32),
                _buildScanAgainButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWideLayout(BoxConstraints constraints) {
    final imageWidth = constraints.maxWidth * 0.45;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: imageWidth,
          height: constraints.maxHeight,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildImageContainer(imageWidth, max(constraints.maxHeight * 0.8, 360)),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        VerticalDivider(width: 1, color: const Color(0xFF1E6B52).withValues(alpha: 0.08)),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDiagnosticCard(),
                const SizedBox(height: 16),
                _buildDisclaimer(),
                const SizedBox(height: 24),
                _buildTreatmentCard(),
                const SizedBox(height: 24),
                _buildFeedbackWidget(),
                const SizedBox(height: 24),
                _buildKrishiAiConsultationCard(),
                const SizedBox(height: 24),
                _buildTechnicalDetailsTile(),
                const SizedBox(height: 32),
                _buildScanAgainButton(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageContainer(double width, double height) {
    return Container(
      margin: const EdgeInsets.all(16),
      width: width - 32,
      height: height,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Image.file(
          File(widget.image.path),
          fit: BoxFit.contain,
          width: width - 32,
          height: height,
        ),
      ),
    );
  }

  Widget _buildDisclaimer() {
    return Container(
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
    );
  }

  Widget _buildDiagnosticCard() {
    final status = _result!.status;
    final Color accentColor;
    final IconData statusIcon;
    final String statusTitle;
    final String statusSubtitle;

    if (status == 'fall_armyworm_detected') {
      accentColor = const Color(0xFFDC2626);
      statusIcon = Icons.bug_report_rounded;
      statusTitle = "Fall Armyworm Detected";
      statusSubtitle = "Our model identified ${_result!.detectionCount} pest/damage feature${_result!.detectionCount == 1 ? '' : 's'}.";
    } else if (status == 'maize_streak_disease') {
      accentColor = const Color(0xFFD97706);
      statusIcon = Icons.warning_rounded;
      statusTitle = "Maize Streak Disease";
      statusSubtitle = "Visual streaks indicate Maize Streak Virus vectoring.";
    } else if (status == 'healthy') {
      accentColor = const Color(0xFF1E6B52);
      statusIcon = Icons.check_circle_rounded;
      statusTitle = "Healthy Maize Leaf";
      statusSubtitle = "Leaf looks clean. No target damage detected.";
    } else {
      accentColor = const Color(0xFF6B7280);
      statusIcon = Icons.no_photography_outlined;
      statusTitle = "Diagnosis Inconclusive";
      statusSubtitle = "Please ensure subject leaf is clear and in frame.";
    }

    final severity = _result!.severity.toUpperCase();
    final Color severityColor;
    final Color severityBg;
    if (severity == "HIGH") {
      severityColor = const Color(0xFF991B1B);
      severityBg = const Color(0xFFFEE2E2);
    } else if (severity == "MEDIUM") {
      severityColor = const Color(0xFF92400E);
      severityBg = const Color(0xFFFEF3C7);
    } else if (severity == "LOW") {
      severityColor = const Color(0xFF065F46);
      severityBg = const Color(0xFFD1FAE5);
    } else {
      severityColor = Colors.grey[800]!;
      severityBg = Colors.grey[200]!;
    }

    final double conf = _result!.maxConfidence;
    final int pct = (conf * 100).round();

    return Container(
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status icon badge, title, and subtitle
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(statusIcon, color: accentColor, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        statusTitle,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E6B52),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        statusSubtitle,
                        style: GoogleFonts.poppins(
                          fontSize: 12.5,
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            Divider(height: 1, color: const Color(0xFF1E6B52).withValues(alpha: 0.08)),
            const SizedBox(height: 16),
            
            // Badges/Chips Row: Severity & Confidence
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: severityBg,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: severityColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "$severity SEVERITY",
                        style: GoogleFonts.poppins(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: severityColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                if (status != 'retake_image')
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDBEAFE),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      "CONFIDENCE: $pct%",
                      style: GoogleFonts.poppins(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E40AF),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
              ],
            ),

            if (status == 'healthy') ...[
              const SizedBox(height: 16),
              Divider(height: 1, color: const Color(0xFF1E6B52).withValues(alpha: 0.08)),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.remove_red_eye_outlined, color: Color(0xFF1E6B52), size: 16),
                  const SizedBox(width: 8),
                  Text(
                    "Detected Features",
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E6B52),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E6B52).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: const Color(0xFF1E6B52).withValues(alpha: 0.15)),
                    ),
                    child: Text(
                      "Healthy Maize",
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF1E6B52),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ] else if (_result!.classCounts.isNotEmpty) ...[
              const SizedBox(height: 16),
              Divider(height: 1, color: const Color(0xFF1E6B52).withValues(alpha: 0.08)),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.remove_red_eye_outlined, color: Color(0xFF1E6B52), size: 16),
                  const SizedBox(width: 8),
                  Text(
                    "Detected Features",
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E6B52),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _result!.classCounts.entries.map((e) {
                  final name = e.key.replaceAll('_', ' ');
                  // Capitalize words helper
                  final formattedName = name.split(' ').map((word) {
                    if (word.isEmpty) return '';
                    return word[0].toUpperCase() + word.substring(1).toLowerCase();
                  }).join(' ');

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E6B52).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: const Color(0xFF1E6B52).withValues(alpha: 0.15)),
                    ),
                    child: Text(
                      "$formattedName (${e.value})",
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF1E6B52),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTreatmentCard() {
    final treatment = _result!.treatment;

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
            children: [
              const Icon(Icons.fact_check_rounded, color: Color(0xFF1E6B52), size: 24),
              const SizedBox(width: 8),
              Text(
                "Action Checklist",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: const Color(0xFF1E6B52),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...treatment.recommendations.map((rec) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF1E6B52), size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        rec,
                        style: GoogleFonts.poppins(
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

  Widget _buildFeedbackWidget() {
    if (_result == null || _result!.status == 'retake_image') return const SizedBox.shrink();

    if (_feedbackSubmitted) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFE2EFE7),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFF1E6B52)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "Thank you for your feedback! It helps improve our model.",
                style: GoogleFonts.poppins(
                  fontSize: 13.5,
                  color: const Color(0xFF1E6B52),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE2EFE7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            "Was this diagnosis accurate?",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: const Color(0xFF1E6B52),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => _submitUserFeedback(true),
                icon: const Icon(Icons.thumb_up_rounded, color: Colors.white, size: 20),
                label: Text(
                  "Yes",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E6B52),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              OutlinedButton.icon(
                onPressed: () => _submitUserFeedback(false),
                icon: const Icon(Icons.thumb_down_rounded, color: Color(0xFF1E6B52), size: 20),
                label: Text(
                  "No",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Color(0xFF1E6B52)),
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFF1E6B52), width: 1.5),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _submitUserFeedback(bool isPositive) async {
    if (_result == null) return;
    
    setState(() {
      _feedbackSubmitted = true;
    });

    final success = await ApiService.submitFeedback(
      requestId: _result!.requestId,
      feedbackType: isPositive ? 'thumbs_up' : 'thumbs_down',
      diagnosis: _result!.status,
      userFeedback: isPositive ? 'thumbs_up' : 'thumbs_down',
      notes: isPositive ? 'User reported accurate diagnosis' : 'User reported inaccurate diagnosis',
    );

    if (!success) {
      debugPrint("Warning: feedback submission API returned failure");
    }
  }

  Widget _buildKrishiAiConsultationCard() {
    final status = _result!.status;

    return ScaleOnTap(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => KrishiChatPage(
              scanContext: {
                "prediction": status == 'fall_armyworm_detected' 
                    ? "Fall Armyworm suspected (YOLO detection)" 
                    : (status == 'maize_streak_disease' ? "Maize Streak Disease suspected" : "Healthy leaf"),
                "confidence": _result!.maxConfidence,
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome_rounded, color: Color(0xFF58D9A6), size: 20),
                      const SizedBox(width: 8),
                      Text(
                        "Consult Krishi FAW AI",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Receive custom treatment protocols, organic pesticides formulations, or ask questions about this diagnostic report.",
                    style: GoogleFonts.poppins(
                      fontSize: 12.5,
                      color: Colors.grey[300],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanAgainButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFF1E6B52),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E6B52).withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(
          "SCAN AGAIN",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }

  Widget _buildTechnicalDetailsTile() {
    if (_result == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1E6B52).withValues(alpha: 0.08)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: ExpansionTile(
          title: Text(
            "Show Technical Details",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: const Color(0xFF1E6B52),
            ),
          ),
          leading: const Icon(Icons.analytics_outlined, color: Color(0xFF1E6B52)),
          childrenPadding: const EdgeInsets.all(16),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Detections Overlay Map:",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: const Color(0xFF1E6B52),
                ),
              ),
            ),
            const SizedBox(height: 8),
            _buildImageWithBoundingBoxes(MediaQuery.of(context).size.width, 300),
            const SizedBox(height: 16),
            Divider(color: const Color(0xFF1E6B52).withValues(alpha: 0.08)),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Raw Detections List:",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: const Color(0xFF1E6B52),
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (_result!.detections.isEmpty)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "No targets detected.",
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              )
            else
              ..._result!.detections.map((det) {
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F7F4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF1E6B52).withValues(alpha: 0.08)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              det.className.replaceAll('_', ' ').toUpperCase(),
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: const Color(0xFF1E6B52),
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDBEAFE),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "${(det.confidence * 100).toStringAsFixed(1)}% Conf",
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E40AF),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Bounding Box Coordinates: [${det.bbox.map((v) => v.toStringAsFixed(1)).join(', ')}]",
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF4B5563),
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWithBoundingBoxes(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(24),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.file(
              File(widget.image.path),
              fit: BoxFit.contain,
              width: width,
              height: height,
            ),
            if (_imageSize != null && _result != null)
              Positioned.fill(
                child: CustomPaint(
                  painter: BoundingBoxPainter(
                    detections: _result!.detections,
                    originalImageSize: _imageSize!,
                    widgetSize: Size(width, height),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class BoundingBoxPainter extends CustomPainter {
  final List<DetectionModel> detections;
  final Size originalImageSize;
  final Size widgetSize;

  BoundingBoxPainter({
    required this.detections,
    required this.originalImageSize,
    required this.widgetSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (originalImageSize.width == 0 || originalImageSize.height == 0) return;

    double scale = min(
      widgetSize.width / originalImageSize.width,
      widgetSize.height / originalImageSize.height,
    );

    double displayedWidth = originalImageSize.width * scale;
    double displayedHeight = originalImageSize.height * scale;

    double dx = (widgetSize.width - displayedWidth) / 2;
    double dy = (widgetSize.height - displayedHeight) / 2;

    for (var det in detections) {
      if (det.bbox.length < 4) continue;

      double x1 = det.bbox[0];
      double y1 = det.bbox[1];
      double x2 = det.bbox[2];
      double y2 = det.bbox[3];

      double left = dx + x1 * scale;
      double top = dy + y1 * scale;
      double right = dx + x2 * scale;
      double bottom = dy + y2 * scale;

      final paint = Paint()
        ..color = _getClassColor(det.className)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;

      canvas.drawRect(Rect.fromLTRB(left, top, right, bottom), paint);

      final textSpan = TextSpan(
        text: "${det.className.replaceAll('_', ' ')} (${(det.confidence * 100).toStringAsFixed(0)}%)",
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      double labelTop = top - textPainter.height - 4;
      if (labelTop < dy) {
        labelTop = top + 4;
      }

      final labelRect = Rect.fromLTWH(
        left,
        labelTop,
        textPainter.width + 8,
        textPainter.height + 4,
      );

      final bgPaint = Paint()..color = _getClassColor(det.className).withValues(alpha: 0.85);
      canvas.drawRRect(
        RRect.fromRectAndRadius(labelRect, const Radius.circular(4)),
        bgPaint,
      );

      textPainter.paint(canvas, Offset(left + 4, labelTop + 2));
    }
  }

  Color _getClassColor(String className) {
    if (className.contains("healthy")) {
      return const Color(0xFF1E6B52);
    } else if (className.contains("streak")) {
      return const Color(0xFFD97706);
    } else if (className.contains("larva") || className.contains("egg")) {
      return const Color(0xFFDC2626);
    } else {
      return const Color(0xFFDC2626);
    }
  }

  @override
  bool shouldRepaint(covariant BoundingBoxPainter oldDelegate) {
    return oldDelegate.detections != detections ||
        oldDelegate.originalImageSize != originalImageSize ||
        oldDelegate.widgetSize != widgetSize;
  }
}
