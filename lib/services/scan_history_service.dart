import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/predict_result.dart';
import 'image_service.dart';

class ScanHistoryItem {
  final String id;
  final String imagePath;
  final String? thumbnailPath;
  final PredictResult result;
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
      'result': {
        'action': result.action,
        'scene': result.scene,
        'prediction': result.prediction != null ? {
          'label': result.prediction!.label,
          'display_name': result.prediction!.displayName,
          'confidence': result.prediction!.confidence,
          'is_faw': result.prediction!.isFaw,
        } : null,
        'treatment': result.treatment != null ? {
          'urgency': result.treatment!.urgency,
          'summary': result.treatment!.summary,
          'steps': result.treatment!.steps,
          'products': result.treatment!.products,
          'local_resources': result.treatment!.localResources,
        } : null,
        'guidance': result.guidance != null ? {
          'title': result.guidance!.title,
          'instruction': result.guidance!.instruction,
          'icon': result.guidance!.icon,
        } : null,
        'reason_code': result.reasonCode,
        'router_debug': {
          'scene': result.routerDebug.scene,
          'scene_conf': result.routerDebug.sceneConf,
          'quality_prob': result.routerDebug.qualityProb,
        },
        'latency_ms': result.latencyMs,
      },
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory ScanHistoryItem.fromJson(Map<String, dynamic> json) {
    return ScanHistoryItem(
      id: json['id'],
      imagePath: json['imagePath'],
      thumbnailPath: json['thumbnailPath'],
      result: PredictResult.fromJson(json['result']),
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
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
      print("SCAN HISTORY ERROR: Failed to load scan history: $e");
      return [];
    }
  }

  static Future<void> saveScan(String imagePath, PredictResult result) async {
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
      print("Error generating history thumbnail: $e");
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
    print("SCAN HISTORY SAVED: Saved scan for path: $imagePath");
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
    print("SCAN HISTORY CLEARED");
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
          print("Error lazily repairing thumbnail for ${item.id}: $e");
        }
      }
    }
    
    if (updated) {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = json.encode(items.map((item) => item.toJson()).toList());
      await prefs.setString(_historyKey, encoded);
      print("SCAN HISTORY REPAIRED: Generated missing thumbnails for old scans!");
      onCompleted();
    }
  }
}
