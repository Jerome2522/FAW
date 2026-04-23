import 'package:flutter/foundation.dart';

class AppConfig {
  static const String apiKey = '9dea141ff7713232e4841c41c0786e75098d357ac419eedb6373d8c09e6d6e1a';

  static String getBaseUrl() {
    if (kReleaseMode) {
      return 'https://faw-backend.onrender.com';
    }
    return 'http://192.168.1.4:8000';
  }

  static const String predictEndpoint = '/predict';
}
