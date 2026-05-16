import 'package:flutter/foundation.dart';

class AppConfig {
  static const String apiKey =
      String.fromEnvironment('ML_API_KEY', defaultValue: 'REPLACE_ME');

  /// Returns the appropriate base URL based on the environment.
  static String getBaseUrl() {
    if (kReleaseMode) {
      return const String.fromEnvironment('BASE_URL',
          defaultValue: 'https://faw-backend.onrender.com');
    }

    // Default to localhost for USB ADB Reverse connectivity
    return 'http://127.0.0.1:8000';
  }

  static const String predictEndpoint = '/predict';
}
