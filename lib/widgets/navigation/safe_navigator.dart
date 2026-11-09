import 'package:flutter/material.dart';

/// A navigator wrapper that debounces rapid multi-taps and ensures safe popping
/// to prevent duplicate screen pushes and double-pop gesture artifacts.
class SafeNavigator {
  static bool _isNavigating = false;

  /// Pushes a route only if no navigation operation is actively in flight.
  static Future<T?> push<T>(BuildContext context, Route<T> route) async {
    if (_isNavigating) return null;
    _isNavigating = true;
    try {
      return await Navigator.push<T>(context, route);
    } finally {
      Future.delayed(const Duration(milliseconds: 400), () {
        _isNavigating = false;
      });
    }
  }

  /// Pushes a replacement route only if no navigation operation is actively in flight.
  static Future<T?> pushReplacement<T, TO>(
    BuildContext context,
    Route<T> route, {
    TO? result,
  }) async {
    if (_isNavigating) return null;
    _isNavigating = true;
    try {
      return await Navigator.pushReplacement<T, TO>(
        context,
        route,
        result: result,
      );
    } finally {
      Future.delayed(const Duration(milliseconds: 400), () {
        _isNavigating = false;
      });
    }
  }

  /// Pops the current route if [Navigator.canPop] evaluates to true.
  static bool safePop<T extends Object?>(BuildContext context, [T? result]) {
    if (Navigator.canPop(context)) {
      Navigator.pop<T>(context, result);
      return true;
    }
    return false;
  }
}
