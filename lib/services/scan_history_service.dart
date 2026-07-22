import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/predict_response.dart';
import 'image_service.dart';

class ScanHistoryItem {
  final String id;
  final String imagePath;
  final String? thumbnailPath;
  final PredictResponseModel result;
  final DateTime timestamp;

  ScanHistoryItem({
    required this.id,
    required this.imagePath,
    this.thumbnailPath,
    required this.result,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imagePath': imagePath,
      'thumbnailPath': thumbnailPath,
      'result': result.toJson(),
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory ScanHistoryItem.fromJson(Map<String, dynamic> json) {
    var resultJson = json['result'] as Map<String, dynamic>;
    PredictResponseModel resultModel;

    // Check if resultJson is the legacy PredictResult
    if (resultJson.containsKey('action') || resultJson.containsKey('prediction') || !resultJson.containsKey('status')) {
      // Migrate V1 to V2
      resultModel = _migrateV1ToV2(resultJson);
    } else {
      resultModel = PredictResponseModel.fromJson(resultJson);
    }

    return ScanHistoryItem(
      id: json['id'],
      imagePath: json['imagePath'],
      thumbnailPath: json['thumbnailPath'],
      result: resultModel,
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
    );
  }

  static PredictResponseModel _migrateV1ToV2(Map<String, dynamic> v1) {
    // 1. Status
    String status = 'unknown';
    var prediction = v1['prediction'];
    var action = v1['action'];
    if (prediction != null) {
      bool isFaw = prediction['is_faw'] ?? false;
      status = isFaw ? 'fall_armyworm_detected' : 'healthy';
    } else if (action == 'retake') {
      status = 'retake_image';
    }

    // 2. Severity
    String severity = 'unknown';
    var treatment = v1['treatment'];
    if (treatment != null) {
      severity = treatment['urgency'] ?? 'unknown';
    }

    // 3. Detected classes & counts
    List<String> detectedClasses = [];
    Map<String, int> classCounts = {};
    List<DetectionModel> detections = [];
    double maxConfidence = 0.0;

    if (prediction != null) {
      String label = prediction['label'] ?? 'unknown';
      maxConfidence = (prediction['confidence'] as num? ?? 0.0).toDouble();
      detectedClasses.add(label);
      classCounts[label] = 1;
      detections.add(DetectionModel(
        className: label,
        confidence: maxConfidence,
        bbox: [0.0, 0.0, 1.0, 1.0], // Default bbox for legacy
      ));
    }

    // 4. Treatment
    String title = 'Unknown Diagnosis';
    String summary = 'No summary available.';
    List<String> recommendations = [];

    if (prediction != null) {
      title = prediction['display_name'] ?? 'Unknown';
    }
    if (treatment != null) {
      summary = treatment['summary'] ?? 'No summary available.';
      var steps = treatment['steps'];
      if (steps is List) {
        recommendations = List<String>.from(steps);
      } else {
        var products = treatment['products'];
        if (products is List) {
          recommendations = List<String>.from(products);
        }
      }
    }

    TreatmentModel treatmentModel = TreatmentModel(
      title: title,
      summary: summary,
      recommendations: recommendations,
    );

    // 5. Confidence Level
    String confidenceLevel = 'low';
    if (maxConfidence >= 0.90) {
      confidenceLevel = 'very_high';
    } else if (maxConfidence >= 0.75) {
      confidenceLevel = 'high';
    } else if (maxConfidence >= 0.50) {
      confidenceLevel = 'medium';
    }

    return PredictResponseModel(
      status: status,
      severity: severity,
      detectedClasses: detectedClasses,
      classCounts: classCounts,
      detectionCount: detections.length,
      maxConfidence: maxConfidence,
      detections: detections,
      treatment: treatmentModel,
      requestId: 'migrated_${v1['latency_ms'] ?? 0}',
      confidenceLevel: confidenceLevel,
    );
  }
}

class ScanHistoryService {
  static const String _historyKey = 'scan_history_list';

  static Future<List<ScanHistoryItem>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? listJson = prefs.getString(_historyKey);
    if (listJson == null) return [];
    try {
      final List<dynamic> decoded = json.decode(listJson);
      return decoded.map((item) => ScanHistoryItem.fromJson(item)).toList();
    } catch (e) {
      debugPrint("SCAN HISTORY ERROR: Failed to load scan history: $e");
      return [];
    }
  }

  static Future<void> saveScan(String imagePath, PredictResponseModel result) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getHistory();
    
    // Check if we already have this exact scan
    final exists = history.any((item) => item.imagePath == imagePath);
    if (exists) return;

    // Generate highly optimized, software-decodable JPEG thumbnail
    String? thumbPath;
    try {
      thumbPath = await ImageService.generateThumbnail(imagePath);
    } catch (e) {
      debugPrint("Error generating history thumbnail: $e");
    }

    final newItem = ScanHistoryItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      imagePath: imagePath,
      thumbnailPath: thumbPath,
      result: result,
      timestamp: DateTime.now(),
    );
    
    history.insert(0, newItem);
    
    // Limit history to top 25 scans
    if (history.length > 25) {
      history.removeRange(25, history.length);
    }
    
    final String encoded = json.encode(history.map((item) => item.toJson()).toList());
    await prefs.setString(_historyKey, encoded);
    debugPrint("SCAN HISTORY SAVED: Saved scan for path: $imagePath");
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
    debugPrint("SCAN HISTORY CLEARED");
  }

  /// Lazily repairs and generates missing thumbnails for legacy scans.
  /// Runs asynchronously in the background and fires a callback on completion.
  static Future<void> repairMissingThumbnails(List<ScanHistoryItem> items, Function() onCompleted) async {
    bool updated = false;
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      if (item.thumbnailPath == null) {
        try {
          final String? thumbPath = await ImageService.generateThumbnail(item.imagePath);
          if (thumbPath != null) {
            items[i] = ScanHistoryItem(
              id: item.id,
              imagePath: item.imagePath,
              thumbnailPath: thumbPath,
              result: item.result,
              timestamp: item.timestamp,
            );
            updated = true;
          }
        } catch (e) {
          debugPrint("Error lazily repairing thumbnail for ${item.id}: $e");
        }
      }
    }
    
    if (updated) {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = json.encode(items.map((item) => item.toJson()).toList());
      await prefs.setString(_historyKey, encoded);
      debugPrint("SCAN HISTORY REPAIRED: Generated missing thumbnails for old scans!");
      onCompleted();
    }
  }
}
