import 'dart:io';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import 'api_service.dart';

class PendingPredictionQueue {
  static const String _queueDirName = 'pending_predictions';
  static bool _isProcessing = false;
  
  static Future<void> initialize() async {
    final dir = await _getQueueDir();
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    await _cleanupStaleItems();
  }

  static Future<Directory> _getQueueDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    return Directory(p.join(appDir.path, _queueDirName));
  }

  static Future<void> _cleanupStaleItems() async {
    final dir = await _getQueueDir();
    if (!await dir.exists()) return;

    final List<FileSystemEntity> files = dir.listSync();
    final now = DateTime.now().millisecondsSinceEpoch;
    final oneDayMs = 24 * 60 * 60 * 1000;

    for (var file in files.whereType<File>().where((f) => f.path.endsWith('.json'))) {
      try {
        final Map<String, dynamic> metadata = json.decode(await file.readAsString());
        final int timestamp = metadata['timestamp'] ?? 0;
        
        if (now - timestamp > oneDayMs) {
          final String uuid = p.basenameWithoutExtension(file.path);
          final imageFile = File(p.join(dir.path, '$uuid.jpg'));
          
          await file.delete();
          if (await imageFile.exists()) await imageFile.delete();
          debugPrint("QUEUE CLEANUP: removed stale item $uuid");
        }
      } catch (e) {
        // Corrupted file
        await file.delete();
      }
    }
  }

  static Future<void> enqueuePrediction(XFile image, String requestId) async {
    final dir = await _getQueueDir();
    final String uuid = const Uuid().v4();
    
    // Save image
    final String imagePath = p.join(dir.path, '$uuid.jpg');
    await File(image.path).copy(imagePath);

    // Save metadata
    final Map<String, dynamic> metadata = {
      'requestId': requestId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'deviceId': 'mobile_app_default',
      'retryCount': 0,
    };
    
    final File metaFile = File(p.join(dir.path, '$uuid.json'));
    await metaFile.writeAsString(json.encode(metadata));
    
    debugPrint("QUEUE SAVED: $uuid");
  }

  static Future<void> processPending() async {
    if (_isProcessing) {
      debugPrint("QUEUE ACTIVE: Sync already in progress, skipping.");
      return;
    }
    
    _isProcessing = true;
    debugPrint("QUEUE ACTIVE: Starting sync process.");

    try {
      final dir = await _getQueueDir();
      if (!await dir.exists()) return;

      final List<FileSystemEntity> files = dir.listSync();
      final List<File> metaFiles = files
          .whereType<File>()
          .where((f) => f.path.endsWith('.json'))
          .toList();

      debugPrint("QUEUE PROCESSING: SIZE=${metaFiles.length}");

      for (var metaFile in metaFiles) {
        final String uuid = p.basenameWithoutExtension(metaFile.path);
        final String imagePath = p.join(dir.path, '$uuid.jpg');
        final File imageFile = File(imagePath);

        if (!await imageFile.exists()) {
          await metaFile.delete();
          continue;
        }

        final Map<String, dynamic> metadata = json.decode(await metaFile.readAsString());
        int retryCount = metadata['retryCount'] ?? 0;

        if (retryCount >= 3) {
          debugPrint("QUEUE DISCARDED: $uuid (Max retries)");
          await metaFile.delete();
          await imageFile.delete();
          continue;
        }

        try {
          debugPrint("UPLOAD RETRY: $uuid (Attempt ${retryCount + 1})");
          await ApiService.predict(imageFile);
          
          // Success: Clean up
          await metaFile.delete();
          await imageFile.delete();
          debugPrint("QUEUE SUCCESS: $uuid");
          
          // Wait before next upload to avoid overwhelming Render
          debugPrint("QUEUE WAITING: 15s before next upload");
          await Future.delayed(const Duration(seconds: 15));
        } catch (e) {
          final String errorStr = e.toString();
          bool isServerBusy = errorStr.contains('502') || 
                            errorStr.contains('503') || 
                            errorStr.contains('504');

          if (isServerBusy) {
            debugPrint("SERVER BUSY: delaying retry for $uuid");
          }

          debugPrint("QUEUE FAILED: $uuid - $e");
          retryCount++;
          metadata['retryCount'] = retryCount;
          await metaFile.writeAsString(json.encode(metadata));
          
          // New Retry schedule: 10s, 30s, 60s
          final int delaySec = (retryCount == 1) ? 10 : (retryCount == 2 ? 30 : 60);
          await Future.delayed(Duration(seconds: delaySec));
        }
      }
    } finally {
      _isProcessing = false;
      debugPrint("QUEUE ACTIVE: Sync process completed.");
    }
  }

  static Future<int> getPendingCount() async {
    final dir = await _getQueueDir();
    if (!await dir.exists()) return 0;
    return dir.listSync().whereType<File>().where((f) => f.path.endsWith('.json')).length;
  }
}
