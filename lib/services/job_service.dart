import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/job_model.dart';

class JobService {
  static const String baseUrl = "http://172.22.39.105:8000";
  // static const String baseUrl = "http://10.26.86.105:8000";

  // ---------------- GET JOBS ----------------
  static Future<List<Job>> fetchJobs() async {
    final uri = Uri.parse('$baseUrl/jobs');
    debugPrint("🚀 Fetching jobs from $uri");

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 5));

      debugPrint("✅ Status: ${response.statusCode}");
      debugPrint("📦 Body: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => Job.fromJson(e)).toList();
      } else {
        throw Exception("Server error ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("🔥 FETCH JOBS ERROR: $e");
      throw Exception("Failed to load jobs");
    }
  }

  // ---------------- CREATE JOB ----------------
  static Future<void> createJob({
    required String title,
    required String category,
    required String description,
    required String location,
    required String phone,
  }) async {
    final uri = Uri.parse('$baseUrl/jobs');
    debugPrint("🚀 Creating job at $uri");

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "title": title,
          "category": category,
          "description": description,
          "location": location,
          "phone": phone,
        }),
      );

      debugPrint("✅ Status: ${response.statusCode}");
      debugPrint("📦 Response: ${response.body}");

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception("Failed to create job");
      }
    } catch (e) {
      debugPrint("🔥 CREATE JOB ERROR: $e");
      throw Exception("Job creation failed");
    }
  }
}
