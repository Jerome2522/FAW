import 'dart:io';
import 'package:image_picker/image_picker.dart';
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
        minWidth: 640,
        minHeight: 640,
        quality: 82,
      );

      if (compressedFile != null) {
        return File(compressedFile.path);
      }
    } catch (e) {
      // In case of any error (e.g., unsupported format), return the original untouched file
      print('Error compressing image: $e');
    }

    return originalFile;
  }

  static Future<void> cleanup(File file) async {
    try {
      if (await file.exists() && p.basename(file.path).startsWith('compressed_')) {
        await file.delete();
      }
    } catch (e) {
      print('Error cleaning up image: $e');
    }
  }
}
