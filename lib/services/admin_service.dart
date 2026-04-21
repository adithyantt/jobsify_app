import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/worker_model.dart';
import '../models/job_model.dart';
import '../utils/api_endpoints.dart';
import '../services/user_session.dart';

class AdminService {
  // 🔐 Helper method to get auth headers safely
  static Map<String, String> _getAuthHeaders() {
    // Use safeToken to avoid null/undefined/"null" issues
    final token = UserSession.safeToken;
    if (token == null || token.isEmpty) {
      throw Exception("Authentication required. Please login.");
    }
    return {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    };
  }

  // ============================
  // 🔹 ADMIN STATS (Dashboard)
  // ============================
  static Future<Map<String, dynamic>> fetchAdminStats() async {
    // Removed strict connectivity check - now tries API + catches real HTTP errors
    final res = await http
        .get(Uri.parse(ApiEndpoints.adminStats), headers: _getAuthHeaders())
        .timeout(const Duration(seconds: 15));

    debugPrint("ADMIN STATS STATUS: ${res.statusCode}");
    debugPrint("ADMIN STATS BODY: ${res.body}");

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else if (res.statusCode == 401) {
      throw Exception("Admin authentication failed. Please login again.");
    } else {
      debugPrint("ADMIN STATS ERROR (${res.statusCode}): ${res.body}");
      throw Exception("Failed to load admin stats (${res.statusCode})");
    }
  }

  // ============================
  // 🔹 PENDING WORKERS
  // ============================
  static Future<List<Worker>> fetchPendingWorkers() async {
    final res = await http.get(
      Uri.parse(ApiEndpoints.pendingWorkers),
      headers: _getAuthHeaders(),
    );

    debugPrint("ADMIN WORKERS STATUS: ${res.statusCode}");
    debugPrint("ADMIN WORKERS BODY: ${res.body}");

    if (res.statusCode == 200) {
      final dynamic decoded = jsonDecode(res.body);
      List<dynamic> data;

      if (decoded is List) {
        data = decoded;
      } else if (decoded is Map &&
          (decoded.containsKey("workers") || decoded.containsKey("data"))) {
        data = decoded["workers"] ?? decoded["data"];
      } else {
        return [];
      }

      return data
          .map((e) => Worker.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception("Failed to load pending workers");
    }
  }

  // Verify a worker
  static Future<void> verifyWorker(int workerId) async {
    final res = await http.put(
      Uri.parse("${ApiEndpoints.approveWorker}/$workerId"),
      headers: _getAuthHeaders(),
    );

    if (res.statusCode != 200) {
      throw Exception("Worker verification failed");
    }
  }

  // Reject/Delete a worker application
  static Future<void> rejectWorker(int workerId) async {
    final res = await http.put(
      Uri.parse("${ApiEndpoints.deleteWorker}/$workerId"),
      headers: _getAuthHeaders(),
    );

    if (res.statusCode != 200) {
      throw Exception("Worker rejection failed");
    }
  }

  // ============================
  // 🔹 PENDING JOBS
  // ============================
  static Future<List<Job>> fetchPendingJobs() async {
    final res = await http.get(
      Uri.parse(ApiEndpoints.pendingJobs),
      headers: _getAuthHeaders(),
    );

    debugPrint("ADMIN JOBS STATUS: ${res.statusCode}");
    debugPrint("ADMIN JOBS BODY: ${res.body}");

    if (res.statusCode == 200) {
      final dynamic decoded = jsonDecode(res.body);
      List<dynamic> data;

      if (decoded is List) {
        data = decoded;
      } else if (decoded is Map &&
          (decoded.containsKey("jobs") || decoded.containsKey("data"))) {
        data = decoded["jobs"] ?? decoded["data"];
      } else {
        return [];
      }
      return data.map((e) => Job.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception("Failed to load pending jobs");
    }
  }

  // Verify a job
  static Future<void> verifyJob(int jobId) async {
    final res = await http.put(
      Uri.parse("${ApiEndpoints.approveJob}/$jobId"),
      headers: _getAuthHeaders(),
    );

    if (res.statusCode != 200) {
      throw Exception("Job verification failed");
    }
  }

  // Reject/Delete a job application
  static Future<void> rejectJob(int jobId) async {
    final res = await http.put(
      Uri.parse("${ApiEndpoints.rejectJob}/$jobId"),
      headers: _getAuthHeaders(),
    );

    if (res.statusCode != 200) {
      throw Exception("Job rejection failed");
    }
  }

  // Block/Unblock a user
  static Future<void> blockUser(int userId) async {
    final res = await http.put(
      Uri.parse(ApiEndpoints.blockUser),
      headers: _getAuthHeaders(),
      body: jsonEncode({'user_id': userId}),
    );

    if (res.statusCode != 200) {
      throw Exception("User block failed: \${res.statusCode} - \${res.body}");
    }
  }

  // Fetch all users
  static Future<List<dynamic>> fetchAllUsers() async {
    final res = await http.get(
      Uri.parse(ApiEndpoints.users),
      headers: _getAuthHeaders(),
    );

    if (res.statusCode == 200) {
      final dynamic decoded = jsonDecode(res.body);
      if (decoded is List) {
        return decoded;
      } else if (decoded is Map && decoded.containsKey("users")) {
        return decoded["users"];
      } else if (decoded is Map && decoded.containsKey("data")) {
        return decoded["data"];
      }
      return [];
    } else {
      throw Exception("Failed to fetch users");
    }
  }

  // Fetch all reports
  static Future<List<dynamic>> fetchAllReports() async {
    final res = await http.get(
      Uri.parse(ApiEndpoints.reports),
      headers: _getAuthHeaders(),
    );

    if (res.statusCode == 200) {
      final dynamic decoded = jsonDecode(res.body);
      if (decoded is List) {
        return decoded;
      } else if (decoded is Map && decoded.containsKey("reports")) {
        return decoded["reports"];
      } else if (decoded is Map && decoded.containsKey("data")) {
        return decoded["data"];
      }
      return [];
    } else {
      throw Exception("Failed to fetch reports");
    }
  }

  // ============================
  // 🔹 PENDING REPORTS
  // ============================
  static Future<List<dynamic>> fetchPendingReports() async {
    final res = await http.get(
      Uri.parse("${ApiEndpoints.baseUrl}/admin/reports/pending"),
      headers: _getAuthHeaders(),
    );

    debugPrint("ADMIN REPORTS STATUS: ${res.statusCode}");
    debugPrint("ADMIN REPORTS BODY: ${res.body}");

    if (res.statusCode == 200) {
      final dynamic decoded = jsonDecode(res.body);
      if (decoded is List) {
        return decoded;
      } else if (decoded is Map &&
          (decoded.containsKey("reports") || decoded.containsKey("data"))) {
        return decoded["reports"] ?? decoded["data"] ?? [];
      }
      return [];
    } else {
      throw Exception("Failed to load pending reports");
    }
  }

  // Take action on report (ignore/warn/ban)
  static Future<void> takeReportAction(int reportId, String action) async {
    final res = await http.put(
      Uri.parse("${ApiEndpoints.baseUrl}/admin/reports/$reportId/action"),
      headers: _getAuthHeaders(),
      body: jsonEncode({"action": action}),
    );

    debugPrint("REPORT ACTION STATUS: ${res.statusCode} ACTION: $action");

    if (res.statusCode != 200) {
      throw Exception("Report action failed (${res.statusCode}): ${res.body}");
    }
  }

  // Resolve a report (legacy)
  static Future<void> resolveReport(int reportId) async {
    final res = await http.post(
      Uri.parse("${ApiEndpoints.baseUrl}/admin/reports/$reportId/resolve"),
      headers: _getAuthHeaders(),
    );

    if (res.statusCode != 200) {
      throw Exception("Report resolution failed");
    }
  }
}
