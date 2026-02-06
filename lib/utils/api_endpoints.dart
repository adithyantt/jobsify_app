class ApiEndpoints {
  // static const String baseUrl = "http://172.22.39.105:8000";
  static const String baseUrl = "http://10.137.141.105:8000";

  // Auth
  static const String login = "$baseUrl/auth/login";

  // Admin - Dashboard
  static const String adminStats = "$baseUrl/admin/stats";

  // Admin - Jobs
  static const String pendingJobs = "$baseUrl/admin/jobs/pending";
  static const String approveJob = "$baseUrl/admin/jobs/approve";
  static const String rejectJob = "$baseUrl/admin/jobs/reject";

  // Admin - Providers
  // Workers (Admin)
  static const String pendingWorkers = "$baseUrl/workers/admin/pending";

  static const String approveWorker = "$baseUrl/workers/admin/approve";
  static const String deleteWorker = "$baseUrl/admin/workers";

  // Workers (Public)
  static const String workers = "$baseUrl/workers";

  // Admin - Reports
  static const String reports = "$baseUrl/admin/reports";
  static const String takeReportAction =
      "$baseUrl/admin/reports"; // append /{report_id}/action

  // Admin - Users
  static const String users = "$baseUrl/admin/users";
  static const String blockUser = "$baseUrl/admin/users/block";
}
