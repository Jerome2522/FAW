import 'dart:io';
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
  }

  static Future<Directory> _getQueueDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    return Directory(p.join(appDir.path, _queueDirName));
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
    
    print("QUEUE SAVED: $uuid");
  }

  static Future<void> processPending() async {
    if (_isProcessing) {
      print("QUEUE ACTIVE: Sync already in progress, skipping.");
      return;
    }
    
    _isProcessing = true;
    print("QUEUE ACTIVE: Starting sync process.");

    try {
      final dir = await _getQueueDir();
      if (!await dir.exists()) return;

    final List<FileSystemEntity> files = dir.listSync();
    final List<File> metaFiles = files
        .whereType<File>()
        .where((f) => f.path.endsWith('.json'))
        .toList();

    print("QUEUE PROCESSING: SIZE=${metaFiles.length}");

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
        print("QUEUE DISCARDED: $uuid (Max retries)");
        await metaFile.delete();
        await imageFile.delete();
        continue;
      }

      try {
        print("UPLOAD RETRY: $uuid (Attempt ${retryCount + 1})");
        await ApiService.predict(imageFile);
        
        // Success: Clean up
        await metaFile.delete();
        await imageFile.delete();
        print("QUEUE SUCCESS: $uuid");
      } catch (e) {
        print("QUEUE FAILED: $uuid - $e");
        retryCount++;
        metadata['retryCount'] = retryCount;
        await metaFile.writeAsString(json.encode(metadata));
        
        // Exponential backoff delay
        final int delaySec = (retryCount == 1) ? 2 : (retryCount == 2 ? 4 : 8);
        await Future.delayed(Duration(seconds: delaySec));
      }
      
      // Delay between items
      await Future.delayed(const Duration(seconds: 2));
    }
    } finally {
      _isProcessing = false;
      print("QUEUE ACTIVE: Sync process completed.");
    }
  }

  static Future<int> getPendingCount() async {
    final dir = await _getQueueDir();
    if (!await dir.exists()) return 0;
    return dir.listSync().whereType<File>().where((f) => f.path.endsWith('.json')).length;
  }
}
