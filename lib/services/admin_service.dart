import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/worker_model.dart';
import '../models/job_model.dart';
import '../utils/api_endpoints.dart';
import '../services/user_session.dart';

class AdminService {
  // ============================
  // 🔹 PENDING WORKERS
  // ============================
  static Future<List<Worker>> fetchPendingWorkers() async {
    final res = await http.get(
      Uri.parse(ApiEndpoints.pendingWorkers),
      headers: {
        "Authorization": "Bearer ${UserSession.token}",
        "Content-Type": "application/json",
      },
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
      headers: {
        "Authorization": "Bearer ${UserSession.token}",
        "Content-Type": "application/json",
      },
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
      headers: {
        "Authorization": "Bearer ${UserSession.token}",
        "Content-Type": "application/json",
      },
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
    final res = await http.post(
      Uri.parse(ApiEndpoints.approveJob),
      headers: {
        "Authorization": "Bearer ${UserSession.token}",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"job_id": jobId}),
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
    final res = await http.post(
      Uri.parse(ApiEndpoints.rejectJob),
      headers: {
        "Authorization": "Bearer ${UserSession.token}",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"job_id": jobId}),
    );

    debugPrint("REJECT JOB STATUS: ${res.statusCode}");

    if (res.statusCode != 200) {
      throw Exception("Job rejection failed");
    }
  }
}
