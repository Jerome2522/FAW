import 'dart:io';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:uuid/uuid.dart';
import '../config/app_config.dart';
import '../models/predict_response.dart';

class ApiService {
  static Future<PredictResponseModel> predict(File imageFile) async {
    final String baseUrlStr = AppConfig.getBaseUrl();
    final uri = Uri.parse('$baseUrlStr${AppConfig.predictEndpoint}');
    
    debugPrint("DEBUG URL: $baseUrlStr");
    debugPrint("DEBUG REQUEST: $uri");
    
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
    
    debugPrint("REQUEST URL: $uri");
    debugPrint("X-API-Key: ${AppConfig.apiKey}");

    debugPrint("TIMEOUT SET: 90s");
    try {
      final streamedResponse = await request.send().timeout(const Duration(seconds: 90));
      final response = await http.Response.fromStream(streamedResponse);
      
      debugPrint("STATUS CODE: ${response.statusCode}");
      debugPrint("RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return PredictResponseModel.fromJson(data);
      } else {
        throw Exception('Server returned status code: ${response.statusCode}');
      }
    } on TimeoutException {
      debugPrint("DEBUG: Request Timeout");
      rethrow;
    } on SocketException catch (e) {
      debugPrint("SOCKET ERROR: $e");
      rethrow;
    } catch (e) {
      debugPrint("DEBUG: Unexpected Error: $e");
      if (e is Exception && e.toString().contains('status code')) {
        rethrow;
      }
      throw Exception('Error occurred during prediction: $e');
    }
  }

  static Future<bool> submitFeedback({
    required String requestId,
    required String feedbackType,
    String? diagnosis,
    String? userFeedback,
    String? notes,
  }) async {
    final String baseUrlStr = AppConfig.getBaseUrl();
    final uri = Uri.parse('$baseUrlStr/feedback');

    debugPrint("FEEDBACK REQUEST: $uri");

    final Map<String, dynamic> body = {
      'request_id': requestId,
      'feedback_type': feedbackType,
      'diagnosis': diagnosis,
      'user_feedback': userFeedback,
      'notes': notes,
      'timestamp': DateTime.now().toIso8601String(),
    };

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': AppConfig.apiKey,
        },
        body: json.encode(body),
      ).timeout(const Duration(seconds: 15));

      debugPrint("FEEDBACK STATUS CODE: ${response.statusCode}");
      debugPrint("FEEDBACK RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['status'] == 'success';
      }
      return false;
    } catch (e) {
      debugPrint("ERROR submitting feedback: $e");
      return false;
    }
  }
}
