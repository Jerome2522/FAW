import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/predict_result.dart';
import '../../widgets/error_handler.dart';
import 'prediction_service.dart';
import '../../services/result_cache_service.dart';
import '../../services/pending_prediction_queue.dart';

class PredictionPage extends StatefulWidget {
  final XFile image;

  const PredictionPage({
    super.key,
    required this.image,
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

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _predict();
  }

  Future<void> _loadInitialData() async {
    final cached = await ResultCacheService.loadLastResult();
    final pending = await PendingPredictionQueue.getPendingCount();
    
    if (mounted) {
      setState(() {
        if (cached != null) {
          _lastResult = cached['result'];
          _lastResultTime = cached['time'];
        }
        _pendingCount = pending;
      });
    }
  }

  Future<void> _predict() async {
    setState(() {
      _isLoading = true;
      _errorType = null;
      _result = null;
    });

    try {
      final result = await PredictionService.predict(widget.image);
      final pending = await PendingPredictionQueue.getPendingCount();
      
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
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 24),
          Text(
            'Analyzing image...',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
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
          if (_lastResult != null && result.action == 'offline') _buildCacheCard(),
          
          // Image preview at the top
          Image.file(
            File(widget.image.path),
            fit: BoxFit.cover,
            height: 300,
            width: double.infinity,
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
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

  Widget _buildCacheCard() {
    if (_lastResult == null || _lastResultTime == null) return const SizedBox.shrink();
    
    final pred = _lastResult!.prediction!;
    final timeAgo = DateTime.now().difference(_lastResultTime!).inHours;
    final timeStr = timeAgo == 0 ? "Just now" : "$timeAgo hours ago";

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueGrey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.history, size: 16, color: Colors.blueGrey),
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

  Widget _buildPredictionResult(PredictResult result) {
    final pred = result.prediction!;
    final double confidencePercent = pred.confidence * 100;
    final bool isLowConfidence = pred.confidence < 0.65;
    final bool isMediumConfidence = pred.confidence >= 0.65 && pred.confidence < 0.75;
    
    final bool isFaw = pred.isFaw ?? false;

    final Color cardColor = isFaw ? const Color(0xFFFFEBEE) : const Color(0xFFE8F5E9);
    final Color mainColor = isFaw ? const Color(0xFFB91C1C) : const Color(0xFF2D6A4F);
    final IconData statusIcon = isFaw ? Icons.warning_amber_rounded : Icons.check_circle_outline_rounded;
    final Color progressBarColor = isFaw ? Colors.red : Colors.green;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(statusIcon, color: mainColor, size: 32),
                  const SizedBox(width: 8),
                  const Text(
                    'Detection Result',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                pred.displayName,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: mainColor,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Confidence', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  Text('${confidencePercent.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: pred.confidence,
                minHeight: 12,
                color: progressBarColor,
                backgroundColor: Colors.white54,
                borderRadius: BorderRadius.circular(6),
              ),
            ],
          ),
        ),
        
        if (result.treatment != null) ...[
          const SizedBox(height: 24),
          _buildTreatmentCard(result.treatment!),
        ],

        if (isMediumConfidence || isLowConfidence) ...[
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isLowConfidence ? Colors.orange.shade100 : Colors.amber.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isLowConfidence 
                ? "📷 Low confidence. Result may not be accurate. Try retaking the photo in better lighting."
                : "⚠️ Medium confidence. For better accuracy, ensure the subject is clearly in focus.",
              style: GoogleFonts.poppins(fontSize: 13),
            ),
          ),
        ],
        
        const SizedBox(height: 32),
        _buildScanAgainButton(),
      ],
    );
  }

  Widget _buildTreatmentCard(Treatment treatment) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Recommended Action", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 8),
          Text(treatment.summary, style: const TextStyle(color: Colors.black87)),
          const SizedBox(height: 16),
          const Text("Steps:", style: TextStyle(fontWeight: FontWeight.w600)),
          ...treatment.steps.map((step) => Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("• ", style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(child: Text(step)),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildRetake(PredictResult result) {
    final guidance = result.guidance!;
    return Column(
      children: [
        Icon(Icons.camera_enhance_rounded, size: 64, color: Colors.orange.shade700),
        const SizedBox(height: 16),
        Text(guidance.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Text(guidance.instruction, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: Colors.black87)),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2D6A4F)),
            child: const Text("Retake Photo", style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }

  Widget _buildReject(PredictResult result) {
    final guidance = result.guidance!;
    return Column(
      children: [
        const Icon(Icons.error_outline_rounded, size: 64, color: Colors.red),
        const SizedBox(height: 16),
        Text(guidance.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Text(guidance.instruction, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: Colors.black87)),
        const SizedBox(height: 32),
        _buildScanAgainButton(),
      ],
    );
  }

  Widget _buildAbstain(PredictResult result) {
    return Column(
      children: [
        const Icon(Icons.help_outline_rounded, size: 64, color: Colors.blueGrey),
        const SizedBox(height: 16),
        const Text("Uncertain Result", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        const Text(
          "Our system is unable to provide a high-confidence classification for this image. Please try another photo or consult an expert.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.black87),
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
        const Icon(Icons.wifi_off_rounded, size: 64, color: Colors.blueGrey),
        const SizedBox(height: 16),
        Text(guidance.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Text(guidance.instruction, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: Colors.black87)),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ),
      ],
    );
  }

  Widget _buildScanAgainButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Scan Another Crop'),
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
