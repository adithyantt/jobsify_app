import 'package:flutter/material.dart';
import '../services/connectivity_service.dart';

/// Utility for consistent offline handling across app
class OfflineHandler {
  /// Show consistent error snackbar with optional retry
  static void showErrorSnackBar(
    BuildContext context,
    dynamic error, {
    VoidCallback? onRetry,
    String? customMessage,
  }) {
    if (!context.mounted) return;

    // Clear existing snackbars to prevent spam
    ScaffoldMessenger.of(context).clearSnackBars();

    final isOfflineError =
        error.toString().contains('NoInternetException') ||
        error.toString().contains('No internet') ||
        error.toString().contains('internet');
    final isTimeout =
        error.toString().contains('timeout') ||
        error.toString().contains('TimeoutException');

    final message =
        customMessage ??
        (isOfflineError
            ? 'No internet connection. Please check your connection.'
            : isTimeout
            ? 'Server timeout. Please try again.'
            : 'Something went wrong. Please try again.');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 4),
        content: Row(
          children: [
            Icon(
              isOfflineError || isTimeout ? Icons.wifi_off : Icons.error,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isOfflineError || isTimeout
            ? Colors.orange
            : Colors.red,
        action: onRetry != null
            ? SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
      ),
    );
  }

  /// Show standard offline snackbar with retry (backward compatibility)
  static void showOfflineSnackBar(
    BuildContext context, {
    required VoidCallback? onRetry,
    String message = 'No internet connection. Please check your connection.',
  }) {
    showErrorSnackBar(
      context,
      const NoInternetException(),
      onRetry: onRetry,
      customMessage: message,
    );
  }

  /// Disable widget when offline
  static Future<Widget> offlineGuard(
    BuildContext context,
    Widget child, {
    String? customMessage,
  }) async {
    final isOnline = await ConnectivityService.isConnected;
    if (!isOnline) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(Icons.wifi_off, size: 64, color: Colors.grey[400]),
            Text(
              customMessage ?? 'Offline - Feature unavailable',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }
    return child;
  }

  /// Async wrapper for API calls with offline handling
  static Future<T> wrapApiCall<T>(
    Future<T> Function() apiCall,
    BuildContext context,
  ) async {
    if (!await ConnectivityService.isConnected) {
      throw const NoInternetException();
    }
    return apiCall();
  }
}
