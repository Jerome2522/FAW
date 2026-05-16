import 'package:flutter/foundation.dart';

class AppConfig {
  static const String apiKey =
      String.fromEnvironment('ML_API_KEY', 
          defaultValue: 'd044d46bb034dfeeff20927e3aa6c8e4a0355a7c5ec6e75a88f70769d69a9178');

  /// Returns the appropriate base URL based on the environment.
  static String getBaseUrl() {
    return const String.fromEnvironment('BASE_URL',
        defaultValue: 'https://faw-backend.onrender.com');
  }

  static const String predictEndpoint = '/predict';
}
