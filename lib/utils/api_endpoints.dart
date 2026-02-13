class ApiEndpoints {
  // static const String baseUrl = "http://172.22.39.105:8000";
  // static const String baseUrl = "http://10.137.141.105:8000";
  // static const String baseUrl = "http://10.0.2.2:8000";
  static const String baseUrl = "http://10.13.1.105:8000";
  // static const String baseUrl = "http://172.22.39.105:8000";

  // Auth
  static const String login = "$baseUrl/auth/login";

  // Admin - Dashboard
  static const String adminStats = "$baseUrl/admin/stats";

  // Admin - Jobs
  static const String pendingJobs = "$baseUrl/jobs/admin/pending";
  static const String approveJob = "$baseUrl/jobs/admin/approve";
  static const String rejectJob = "$baseUrl/jobs/admin/reject";

  // Admin - Providers
  // Workers (Admin)
  static const String pendingWorkers = "$baseUrl/workers/admin/pending";

  static const String approveWorker = "$baseUrl/workers/admin/approve";
  static const String deleteWorker = "$baseUrl/workers/admin/reject";

  // Workers (Public)
  static const String workers = "$baseUrl/workers";

  // Jobs (Public)
  static const String jobs = "$baseUrl/jobs";

  // User-specific endpoints
  static const String myJobs = "$baseUrl/jobs/my";
  static const String myWorkers = "$baseUrl/workers/my";

  // Admin - Reports
  static const String reports = "$baseUrl/admin/reports";
  static const String takeReportAction =
      "$baseUrl/admin/reports"; // append /{report_id}/action

  // Notifications
  static const String notifications = "$baseUrl/notifications";

  // Admin - Users
  static const String users = "$baseUrl/admin/users";
  static const String blockUser = "$baseUrl/admin/users/block";
}
