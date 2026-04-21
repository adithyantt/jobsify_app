import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:http/http.dart' as http;

import '../utils/api_endpoints.dart';

/// Custom exception for no internet - re-export for convenience
class NoInternetException implements Exception {
  const NoInternetException();

  @override
  String toString() =>
      'No internet connection. Please check your connection and try again.';
}

/// Service to check internet connectivity
class ConnectivityService {
  static Connectivity? _connectivity;
  static bool _hasConnection = false;
  static StreamSubscription<List<ConnectivityResult>>? _subscription;

  /// Initialize connectivity listener (call in main.dart)
  static Future<void> initialize() async {
    _connectivity = Connectivity();
    await _checkConnection();
    _subscription = _connectivity!.onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      _checkConnection();
    });
  }

  /// Check if device has active internet connection
  static Future<bool> get isConnected async {
    await _checkConnection();
    return _hasConnection;
  }

  /// Private method to check connectivity
  static Future<void> _checkConnection() async {
    try {
      final connectivityResults =
          await (_connectivity?.checkConnectivity() ??
              Connectivity().checkConnectivity());
      if (connectivityResults.contains(ConnectivityResult.none)) {
        _hasConnection = false;
        return;
      }

      bool hasRealConnection = false;

      if (kIsWeb) {
        // Web uses an HTTP probe because browsers block direct DNS lookup.
        try {
          final response = await http
              .head(Uri.parse("${ApiEndpoints.baseUrl}/"))
              .timeout(const Duration(seconds: 5));
          hasRealConnection =
              response.statusCode >= 200 && response.statusCode < 500;
        } catch (e) {
          // Fallback: data URL always works if browser online.
          try {
            await http.get(Uri.parse('data:text/plain;base64,'));
            hasRealConnection = true;
          } catch (_) {
            hasRealConnection = false;
          }
        }
      } else {
        // Mobile/desktop rely on connectivity_plus so requests stay fast.
        hasRealConnection = true;
      }

      _hasConnection = hasRealConnection;
    } catch (e) {
      debugPrint('Connectivity check error: $e');
      _hasConnection = false;
    }
  }

  /// Dispose subscription
  static void dispose() {
    _subscription?.cancel();
    _connectivity = null;
  }
}
