import 'package:flutter/material.dart';

enum AppExceptionType {
  network,
  server,
  timeout,
  imageProcessing,
}

class AppException implements Exception {
  final String message;
  final AppExceptionType type;

  AppException(this.message, this.type);

  @override
  String toString() => 'AppException: $message (Type: $type)';
}

class ErrorHandler extends StatelessWidget {
  final AppExceptionType type;
  final VoidCallback onRetry;

  const ErrorHandler({
    super.key,
    required this.type,
    required this.onRetry,
  });

  IconData _getIcon() {
    switch (type) {
      case AppExceptionType.network:
        return Icons.wifi_off;
      case AppExceptionType.server:
        return Icons.cloud_off;
      case AppExceptionType.timeout:
        return Icons.timer_off;
      case AppExceptionType.imageProcessing:
        return Icons.image_not_supported;
    }
  }

  String _getMessage() {
    switch (type) {
      case AppExceptionType.network:
        return "Check your internet connection";
      case AppExceptionType.server:
        return "Something went wrong, please try again";
      case AppExceptionType.timeout:
        return "Request timed out, please try again";
      case AppExceptionType.imageProcessing:
        return "Couldn't process image, please try a clearer photo";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getIcon(),
              size: 64,
              color: Colors.grey[700],
            ),
            const SizedBox(height: 16),
            Text(
              _getMessage(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
