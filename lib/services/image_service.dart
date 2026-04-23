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
        minWidth: 800,
        minHeight: 800,
        quality: 85,
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
}
