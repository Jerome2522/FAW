import 'dart:io';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:uuid/uuid.dart';

import '../../models/predict_result.dart';
import '../../services/api_service.dart';
import '../../services/image_service.dart';
import '../../services/pending_prediction_queue.dart';
import '../../services/result_cache_service.dart';
import '../../widgets/error_handler.dart';

class PredictionService {
  static Future<PredictResult> predict(XFile image) async {
    // 1. Check Connectivity
    final connectivityResult = await Connectivity().checkConnectivity();
    final bool isOffline = connectivityResult.contains(ConnectivityResult.none) || connectivityResult.isEmpty;

    if (isOffline) {
      final String requestId = const Uuid().v4();
      await PendingPredictionQueue.enqueuePrediction(image, requestId);
      
      return PredictResult(
        action: 'offline',
        routerDebug: RouterDebug(scene: 'offline', sceneConf: 0, qualityProb: 0),
        latencyMs: 0,
        guidance: Guidance(
          title: "No connection",
          instruction: "Saved locally — will analyse automatically when online.",
          icon: "wifi_off",
        ),
      );
    }

    try {
      final File compressedFile = await ImageService.prepareImage(image);
      final PredictResult result = await ApiService.predict(compressedFile);
      
      // Cleanup compressed file after upload
      await ImageService.cleanup(compressedFile);
      
      if (result.action == 'result') {
        await ResultCacheService.saveResult(result);
      }
      
      return result;
    } on SocketException catch (e) {
      final String requestId = const Uuid().v4();
      await PendingPredictionQueue.enqueuePrediction(image, requestId);
      
      return PredictResult(
        action: 'offline',
        routerDebug: RouterDebug(scene: 'offline', sceneConf: 0, qualityProb: 0),
        latencyMs: 0,
        guidance: Guidance(
          title: "Connection Lost",
          instruction: "Failed to reach server. Image saved for later analysis.",
          icon: "wifi_off",
        ),
      );
    } on TimeoutException catch (e) {
      throw AppException(e.toString(), AppExceptionType.timeout);
    } catch (e) {
      throw AppException(e.toString(), AppExceptionType.server);
    }
  }
}
