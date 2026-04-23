import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/prediction_result.dart';
import '../../widgets/error_handler.dart';
import 'prediction_service.dart';

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
  PredictionResult? _result;
  AppExceptionType? _errorType;

  @override
  void initState() {
    super.initState();
    _predict();
  }

  Future<void> _predict() async {
    setState(() {
      _isLoading = true;
      _errorType = null;
      _result = null;
    });

    try {
      final result = await PredictionService.predict(widget.image);
      if (mounted) {
        setState(() {
          _result = result;
          _isLoading = false;
        });
      }
    } catch (e) {
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

  Widget _buildSuccess(PredictionResult result) {
    final double confidencePercent = result.confidence * 100;
    final bool isLowConfidence = result.confidence < 0.6;
    final bool isMediumConfidence = result.confidence >= 0.6 && result.confidence < 0.7;
    
    final bool isFaw = result.label == "Fall Armyworm Detected";

    final Color cardColor = isFaw ? const Color(0xFFFFEBEE) : const Color(0xFFE8F5E9);
    final Color mainColor = isFaw ? const Color(0xFFB91C1C) : const Color(0xFF2D6A4F);
    final IconData statusIcon = isFaw ? Icons.warning_amber_rounded : Icons.check_circle_outline_rounded;
    final Color progressBarColor = isFaw ? Colors.red : Colors.green;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image preview at the top
          Image.file(
            File(widget.image.path),
            fit: BoxFit.cover,
            height: 300,
            width: double.infinity,
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 0),
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
                              'Result',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          result.label,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: mainColor,
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Confidence display
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Confidence',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${confidencePercent.toStringAsFixed(1)}%',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: result.confidence,
                          minHeight: 12,
                          color: progressBarColor,
                          backgroundColor: Colors.white54,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ],
                    ),
                  ),
                  if (isMediumConfidence) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "⚠️ Low confidence result. For better accuracy, retake the photo in good lighting with the damage clearly visible.",
                        style: GoogleFonts.poppins(fontSize: 13),
                      ),
                    ),
                  ],
                  if (isLowConfidence) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "📷 Low confidence. The result may not be accurate. Try retaking the photo in better lighting with the damaged area clearly visible.",
                        style: GoogleFonts.poppins(fontSize: 13),
                      ),
                    ),
                  ],
                  const SizedBox(height: 48),
                  
                  // Scan Again Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Scan Again'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prediction'),
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
