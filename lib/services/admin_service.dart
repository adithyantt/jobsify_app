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
    final token = UserSession.token;
    if (token == null || token.isEmpty) {
      throw Exception("Authentication required. Please login.");
    }
    return {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    };
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
      final List data = jsonDecode(res.body);
      return data.map((e) => Worker.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load pending workers");
    }
  }

  // ============================
  // 🔹 VERIFY WORKER
  // ============================
  static Future<void> verifyWorker(int workerId) async {
    final res = await http.put(
      Uri.parse("${ApiEndpoints.approveWorker}/$workerId"),
      headers: _getAuthHeaders(),
    );

    debugPrint("VERIFY WORKER STATUS: ${res.statusCode}");

    if (res.statusCode != 200) {
      throw Exception("Worker verification failed");
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
      final List data = jsonDecode(res.body);
      return data.map((e) => Job.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load pending jobs");
    }
  }

  // ============================
  // 🔹 APPROVE JOB
  // ============================
  static Future<void> approveJob(int jobId) async {
    final res = await http.put(
      Uri.parse("${ApiEndpoints.approveJob}/$jobId"),
      headers: _getAuthHeaders(),
    );

    debugPrint("APPROVE JOB STATUS: ${res.statusCode}");

    if (res.statusCode != 200) {
      throw Exception("Job approval failed");
    }
  }

  // ============================
  // 🔹 REJECT JOB
  // ============================
  static Future<void> rejectJob(int jobId) async {
    final res = await http.put(
      Uri.parse("${ApiEndpoints.rejectJob}/$jobId"),
      headers: _getAuthHeaders(),
    );

    debugPrint("REJECT JOB STATUS: ${res.statusCode}");

    if (res.statusCode != 200) {
      throw Exception("Job rejection failed");
    }
  }
}
