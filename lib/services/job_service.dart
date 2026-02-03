import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/job_model.dart';

class JobService {
  // ⚠️ Use the SAME IP that works in Swagger
  // static const String baseUrl = "http://172.22.39.105:8000"; //A06
  static const String baseUrl = "http://10.137.141.105:8000";

  // ============================
  // 🔹 GET ALL JOBS
  // ============================
  static Future<List<Job>> fetchJobs() async {
    final uri = Uri.parse('$baseUrl/jobs');
    debugPrint("🚀 Fetching jobs from $uri");

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      debugPrint("✅ Status: ${response.statusCode}");
      debugPrint("📦 Body: ${response.body}");

      if (response.statusCode == 200) {
        if (response.body.isEmpty || response.body == '[]') {
          debugPrint("⚠️ No jobs found");
          return [];
        }

        final List<dynamic> data = jsonDecode(response.body);

        debugPrint("✅ Parsed ${data.length} jobs");

        return data
            .map((e) => Job.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(
          "Server error ${response.statusCode}: ${response.body}",
        );
      }
    } on TimeoutException {
      debugPrint("🔥 FETCH JOBS TIMEOUT");
      throw Exception("Cannot connect to server. Check WiFi / IP / backend.");
    } catch (e) {
      debugPrint("🔥 FETCH JOBS ERROR: $e");
      throw Exception("Fetch jobs failed: $e");
    }
  }

  // ============================
  // 🔹 CREATE JOB
  // ============================
  static Future<void> createJob({
    required String title,
    required String category,
    required String description,
    required String location,
    required String phone,
    String? latitude,
    String? longitude,
    bool urgent = false,
    String? salary,
  }) async {
    final uri = Uri.parse('$baseUrl/jobs');
    debugPrint("🚀 Creating job at $uri");

    final body = {
      "title": title,
      "category": category,
      "description": description,
      "location": location,
      "phone": phone,
      "latitude": latitude,
      "longitude": longitude,
      "urgent": urgent,
      "salary": salary,
    };

    debugPrint("📤 Sending JSON: $body");

    try {
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));

      debugPrint("✅ Status: ${response.statusCode}");
      debugPrint("📦 Response: ${response.body}");

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
          "Server error ${response.statusCode}: ${response.body}",
        );
      }
    } on TimeoutException {
      debugPrint("🔥 CREATE JOB TIMEOUT");
      throw Exception("Cannot connect to server. Check backend & network.");
    } catch (e) {
      debugPrint("🔥 CREATE JOB ERROR: $e");
      throw Exception("Create job failed: $e");
    }
  }
}
