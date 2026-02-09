import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/job_model.dart';
import '../utils/api_endpoints.dart';

class JobService {
  // ===============================
  // 🔹 GET ALL VERIFIED JOBS (PUBLIC)
  // ===============================
  static Future<List<Job>> fetchJobs() async {
    final uri = Uri.parse(ApiEndpoints.jobs);

    try {
      final response = await http
          .get(uri, headers: {"Content-Type": "application/json"})
          .timeout(const Duration(seconds: 10));

      debugPrint("FETCH JOBS STATUS: ${response.statusCode}");
      debugPrint("FETCH JOBS BODY: ${response.body}");

      if (response.statusCode == 200) {
        if (response.body.isEmpty || response.body == '[]') {
          return [];
        }

        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((e) => Job.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      throw Exception("Failed to load jobs (${response.statusCode})");
    } on TimeoutException {
      throw Exception("Server timeout");
    } catch (e) {
      debugPrint("FETCH JOBS ERROR: $e");
      throw Exception("Fetch jobs failed");
    }
  }

  // ===============================
  // 🔹 CREATE JOB (PUBLIC)
  // (ADMIN APPROVAL REQUIRED LATER)
  // ===============================
  static Future<void> createJob({
    required String title,
    required String category,
    required String description,
    required String location,
    required String phone,
    String? latitude,
    String? longitude,
    required String userEmail, // Add user email
  }) async {
    final uri = Uri.parse(ApiEndpoints.jobs);

    final body = {
      "title": title,
      "category": category,
      "description": description,
      "location": location,
      "phone": phone,
      "latitude": latitude,
      "longitude": longitude,
      "user_email": userEmail, // Add user email
    };

    try {
      final client = http.Client();
      final response = await client
          .post(
            uri,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 20));
      client.close();

      debugPrint("CREATE JOB STATUS: ${response.statusCode}");
      debugPrint("CREATE JOB BODY: ${response.body}");

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
          "Job creation failed (${response.statusCode}): ${response.body}",
        );
      }
    } on TimeoutException {
      throw Exception("Server timeout");
    } catch (e) {
      debugPrint("CREATE JOB ERROR: $e");
      throw Exception("Create job failed");
    }
  }

  // ===============================
  // 🔹 FETCH MY JOBS (USER-SPECIFIC)
  // ===============================

  static Future<List<Job>> fetchMyJobs(String email) async {
    final uri = Uri.parse('${ApiEndpoints.myJobs}?email=$email');

    try {
      final response = await http
          .get(uri, headers: {"Content-Type": "application/json"})
          .timeout(const Duration(seconds: 10));

      debugPrint("FETCH MY JOBS STATUS: ${response.statusCode}");
      debugPrint("FETCH MY JOBS BODY: ${response.body}");

      if (response.statusCode == 200) {
        if (response.body.isEmpty || response.body == '[]') {
          return [];
        }

        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((e) => Job.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      throw Exception("Failed to load my jobs (${response.statusCode})");
    } on TimeoutException {
      throw Exception("Server timeout");
    } catch (e) {
      debugPrint("FETCH MY JOBS ERROR: $e");
      throw Exception("Fetch my jobs failed");
    }
  }

  // ===============================
  // 🔹 UPDATE JOB
  // ===============================
  static Future<void> updateJob({
    required int jobId,
    required String title,
    required String category,
    required String description,
    required String location,
    required String phone,
    String? latitude,
    String? longitude,
    required String userEmail,
  }) async {
    final uri = Uri.parse('${ApiEndpoints.jobs}/$jobId?email=$userEmail');

    final body = {
      "title": title,
      "category": category,
      "description": description,
      "location": location,
      "phone": phone,
      "latitude": latitude,
      "longitude": longitude,
      "user_email": userEmail,
    };

    try {
      final response = await http
          .put(
            uri,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 20));

      debugPrint("UPDATE JOB STATUS: ${response.statusCode}");
      debugPrint("UPDATE JOB BODY: ${response.body}");

      if (response.statusCode != 200) {
        throw Exception(
          "Job update failed (${response.statusCode}): ${response.body}",
        );
      }
    } on TimeoutException {
      throw Exception("Server timeout");
    } catch (e) {
      debugPrint("UPDATE JOB ERROR: $e");
      throw Exception("Update job failed");
    }
  }

  // ===============================
  // 🔹 DELETE JOB
  // ===============================
  static Future<void> deleteJob({
    required int jobId,
    required String userEmail,
  }) async {
    final uri = Uri.parse('${ApiEndpoints.jobs}/$jobId?email=$userEmail');

    try {
      final response = await http
          .delete(uri, headers: {"Content-Type": "application/json"})
          .timeout(const Duration(seconds: 10));

      debugPrint("DELETE JOB STATUS: ${response.statusCode}");
      debugPrint("DELETE JOB BODY: ${response.body}");

      if (response.statusCode != 200) {
        throw Exception(
          "Job delete failed (${response.statusCode}): ${response.body}",
        );
      }
    } on TimeoutException {
      throw Exception("Server timeout");
    } catch (e) {
      debugPrint("DELETE JOB ERROR: $e");
      throw Exception("Delete job failed");
    }
  }

  // ===============================
  // 🔹 REPORT JOB
  // ===============================
  static Future<void> reportJob({
    required int jobId,
    required String reason,
    required String description,
    required String reporterEmail,
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse("${ApiEndpoints.baseUrl}/jobs/report"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "job_id": jobId,
              "reason": reason,
              "description": description,
              "reporter_email": reporterEmail,
            }),
          )
          .timeout(const Duration(seconds: 20));

      debugPrint("REPORT JOB STATUS: ${res.statusCode}");
      debugPrint("REPORT JOB BODY: ${res.body}");

      if (res.statusCode != 200 && res.statusCode != 201) {
        throw Exception("Report job failed (${res.statusCode})");
      }
    } on TimeoutException {
      throw Exception("Server timeout");
    } catch (e) {
      debugPrint("REPORT JOB ERROR: $e");
      throw Exception("Report job failed");
    }
  }
}
