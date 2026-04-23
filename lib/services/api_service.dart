import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/prediction_result.dart';

class ApiService {
  static Future<PredictionResult> predict(File imageFile) async {
    // We check if getBaseUrl() exists or fall back to the baseUrl static property.
    final String baseUrlStr = AppConfig.getBaseUrl();

    final uri = Uri.parse('$baseUrlStr${AppConfig.predictEndpoint}');
    
    var request = http.MultipartRequest('POST', uri);
    request.headers['X-API-Key'] = AppConfig.apiKey;
    
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
      ),
    );

    try {
      final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return PredictionResult.fromJson(data);
      } else {
        throw Exception('Server returned status code: ${response.statusCode}');
      }
    } on TimeoutException {
      rethrow;
    } on SocketException {
      rethrow;
    } catch (e) {
      if (e is Exception && e.toString().contains('status code')) {
        rethrow;
      }
      throw Exception('Error occurred during prediction: $e');
    }
  }
}
