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
    final uri = Uri.parse('${ApiEndpoints.baseUrl}/jobs');

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
  }) async {
    final uri = Uri.parse('${ApiEndpoints.baseUrl}/jobs');

    final body = {
      "title": title,
      "category": category,
      "description": description,
      "location": location,
      "phone": phone,
      "latitude": latitude,
      "longitude": longitude,
    };

    try {
      final response = await http
          .post(
            uri,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));

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
}
