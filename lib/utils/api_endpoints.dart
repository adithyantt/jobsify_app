import 'package:flutter/foundation.dart';

class ApiEndpoints {
  static const String _defaultLocalUrl = "http://127.0.0.1:8000";
  static const String _defaultAndroidEmulatorUrl = "http://10.0.2.2:8000";
  static const String _configuredBaseUrl = String.fromEnvironment(
    "API_BASE_URL",
    defaultValue: "",
  );

  // Override with:
  // flutter run --dart-define=API_BASE_URL=http://<your-ip>:8000
  // Android emulator uses 10.0.2.2 to reach the host machine.
  // Physical devices should use dart-define with your Wi-Fi IP.
  static String get baseUrl {
    if (_configuredBaseUrl.isNotEmpty) {
      return _configuredBaseUrl;
    }
    if (kIsWeb) {
      return _defaultLocalUrl;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return _defaultAndroidEmulatorUrl;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return _defaultLocalUrl;
    }
  }

  // Auth
  static String get register => "$baseUrl/auth/register";
  static String get verifyOtp => "$baseUrl/auth/verify-otp";
  static String get login => "$baseUrl/auth/login";
  static String get forgotPasswordRequest =>
      "$baseUrl/auth/forgot-password/request";
  static String get forgotPasswordReset => "$baseUrl/auth/forgot-password/reset";

  // Admin - Dashboard
  static String get adminStats => "$baseUrl/admin/stats";

  // Admin - Jobs
  static String get pendingJobs => "$baseUrl/jobs/admin/pending";
  static String get approveJob => "$baseUrl/jobs/admin/approve";
  static String get rejectJob => "$baseUrl/jobs/admin/reject";

  // Admin - Providers
  // Workers (Admin)
  static String get pendingWorkers => "$baseUrl/workers/admin/pending";

  static String get approveWorker => "$baseUrl/workers/admin/approve";
  static String get deleteWorker => "$baseUrl/workers/admin/reject";

  // Workers (Public)
  static String get workers => "$baseUrl/workers";

  // Jobs (Public)
  static String get jobs => "$baseUrl/jobs";

  // User-specific endpoints
  static String get myJobs => "$baseUrl/jobs/my";
  static String get myWorkers => "$baseUrl/workers/my";

  // Admin - Reports
  static String get reports => "$baseUrl/admin/reports";
  static String get takeReportAction =>
      "$baseUrl/admin/reports"; // append /{report_id}/action

  // Notifications
  static String get notifications => "$baseUrl/notifications";
  static String get messages => "$baseUrl/messages";

  // Admin - Users
  static String get users => "$baseUrl/admin/users";
  static String get blockUser => "$baseUrl/admin/users/block";
}
