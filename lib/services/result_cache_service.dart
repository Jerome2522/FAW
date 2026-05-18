import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/predict_result.dart';

class ResultCacheService {
  static const String _lastResultKey = 'last_result';
  static const String _timestampKey = 'last_result_timestamp';

  static Future<void> saveResult(PredictResult result) async {
    final prefs = await SharedPreferences.getInstance();
    
    // We need a way to serialize PredictResult back to JSON
    // For now, let's assume we store the raw Map if possible, 
    // but since we only have the model, we'll need a toJson or similar.
    // I'll add a simple toJson-like mapping logic here since I shouldn't rewrite the model if not necessary.
    
    final Map<String, dynamic> data = {
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
    };

    await prefs.setString(_lastResultKey, json.encode(data));
    await prefs.setInt(_timestampKey, DateTime.now().millisecondsSinceEpoch);
    print("CACHE WRITES: Successfully cached result for ${result.prediction?.label}");
    print("CACHE SAVED");
  }

  static Future<Map<String, dynamic>?> loadLastResult() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonStr = prefs.getString(_lastResultKey);
    final int? timestamp = prefs.getInt(_timestampKey);

    if (jsonStr == null || timestamp == null) return null;

    final lastTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    if (DateTime.now().difference(lastTime).inHours > 24) {
      print("CACHE EXPIRED: ${lastTime.toIso8601String()}");
      await clearCache();
      return null;
    }

    print("CACHE HIT: ${lastTime.toIso8601String()}");
    final Map<String, dynamic> data = json.decode(jsonStr);
    return {
      'result': PredictResult.fromJson(data),
      'time': lastTime,
    };
  }

  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastResultKey);
    await prefs.remove(_timestampKey);
    print("CACHE CLEARED");
  }
}
