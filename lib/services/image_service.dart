import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;

class ImageService {
  static Future<File> prepareImage(XFile image) async {
    final File originalFile = File(image.path);

    try {
      // Create a temporary path for the compressed image
      final String dir = originalFile.absolute.parent.path;
      final String targetPath = p.join(
        dir,
        'compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      final XFile? compressedFile = await FlutterImageCompress.compressAndGetFile(
        originalFile.absolute.path,
        targetPath,
        minWidth: 1280,
        minHeight: 1280,
        quality: 85,
      );

      if (compressedFile != null) {
        return File(compressedFile.path);
      }
    } catch (e) {
      // In case of any error (e.g., unsupported format), return the original untouched file
      debugPrint('Error compressing image: $e');
    }

    return originalFile;
  }

  static Future<void> cleanup(File file) async {
    try {
      if (await file.exists() && p.basename(file.path).startsWith('compressed_')) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Error cleaning up image: $e');
    }
  }

  /// Generates a tiny, highly-compressed, software-decodable JPEG thumbnail
  /// of 150x150 dimensions to bypass expensive hardware HEVC decoder channels
  /// when displaying lists of recent scans.
  static Future<String?> generateThumbnail(String imagePath) async {
    try {
      final File file = File(imagePath);
      if (!await file.exists()) return null;

      final String dir = file.absolute.parent.path;
      final String targetPath = p.join(
        dir,
        'thumb_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      final XFile? compressedFile = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        minWidth: 150,
        minHeight: 150,
        quality: 50, // Ultra-low size, soft JPEG decodable
      );

      if (compressedFile != null) {
        return compressedFile.path;
      }
    } catch (e) {
      debugPrint('Error generating thumbnail: $e');
    }
    return null;
  }
}
