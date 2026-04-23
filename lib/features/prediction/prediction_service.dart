import 'dart:io';
import 'dart:async';
import 'package:image_picker/image_picker.dart';

import '../../models/prediction_result.dart';
import '../../services/api_service.dart';
import '../../services/image_service.dart';
import '../../widgets/error_handler.dart';

class PredictionService {
  static Future<PredictionResult> predict(XFile image) async {
    try {
      final File compressedFile = await ImageService.prepareImage(image);
      final PredictionResult result = await ApiService.predict(compressedFile);
      return result;
    } on SocketException catch (e) {
      throw AppException(e.toString(), AppExceptionType.network);
    } on TimeoutException catch (e) {
      throw AppException(e.toString(), AppExceptionType.timeout);
    } catch (e) {
      throw AppException(e.toString(), AppExceptionType.server);
    }
  }
}
