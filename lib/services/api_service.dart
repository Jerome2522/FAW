import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:uuid/uuid.dart';
import '../config/app_config.dart';
import '../models/predict_result.dart';

class ApiService {
  static Future<PredictResult> predict(File imageFile) async {
    final String baseUrlStr = AppConfig.getBaseUrl();
    final uri = Uri.parse('$baseUrlStr${AppConfig.predictEndpoint}');
    
    print("DEBUG URL: $baseUrlStr");
    print("DEBUG REQUEST: $uri");
    
    var request = http.MultipartRequest('POST', uri);
    request.headers['X-API-Key'] = AppConfig.apiKey;
    
    // Generate a unique request ID
    final String requestId = const Uuid().v4();
    
    request.fields['request_id'] = requestId;
    request.fields['device_id'] = 'mobile_app_default';
    request.fields['app_version'] = '1.0.0';
    
    request.files.add(
      await http.MultipartFile.fromPath(
        'image', 
        imageFile.path,
        contentType: MediaType('image', 'jpeg'),
      ),
    );
    
    print("REQUEST URL: $uri");
    print("X-API-Key: ${AppConfig.apiKey}");

    print("TIMEOUT SET: 90s");
    try {
      final streamedResponse = await request.send().timeout(const Duration(seconds: 90));
      final response = await http.Response.fromStream(streamedResponse);
      
      print("STATUS CODE: ${response.statusCode}");
      print("RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return PredictResult.fromJson(data);
      } else {
        throw Exception('Server returned status code: ${response.statusCode}');
      }
    } on TimeoutException {
      print("DEBUG: Request Timeout");
      rethrow;
    } on SocketException catch (e) {
      print("SOCKET ERROR: $e");
      rethrow;
    } catch (e) {
      print("DEBUG: Unexpected Error: $e");
      if (e is Exception && e.toString().contains('status code')) {
        rethrow;
      }
      throw Exception('Error occurred during prediction: $e');
    }
  }
}
