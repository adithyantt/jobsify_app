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
  // 🔹 GET JOB BY ID (PUBLIC)
  // ===============================
  static Future<Job?> fetchJobById(int jobId) async {
    final uri = Uri.parse('${ApiEndpoints.jobs}/$jobId');

    try {
      final response = await http
          .get(uri, headers: {"Content-Type": "application/json"})
          .timeout(const Duration(seconds: 10));

      debugPrint("FETCH JOB BY ID STATUS: ${response.statusCode}");
      debugPrint("FETCH JOB BY ID BODY: ${response.body}");

      if (response.statusCode == 200) {
        if (response.body.isEmpty || response.body == 'null') {
          return null;
        }
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return Job.fromJson(data);
      } else if (response.statusCode == 404) {
        return null; // Job not found
      }

      throw Exception("Failed to load job (${response.statusCode})");
    } on TimeoutException {
      throw Exception("Server timeout");
    } catch (e) {
      debugPrint("FETCH JOB BY ID ERROR: $e");
      return null;
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
    bool? urgent,
    String? salary,
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
      "urgent": urgent ?? false,
      "salary": salary,
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
    // Validate email before making request
    if (email.isEmpty) {
      debugPrint("FETCH MY JOBS ERROR: Email is empty");
      throw Exception("Email is required to fetch jobs");
    }

    final uri = Uri.parse('${ApiEndpoints.myJobs}?email=$email');
    debugPrint("FETCH MY JOBS URL: $uri");

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
        debugPrint("FETCH MY JOBS: Parsing ${data.length} jobs");

        final jobs = <Job>[];
        for (var i = 0; i < data.length; i++) {
          try {
            final job = Job.fromJson(data[i] as Map<String, dynamic>);
            jobs.add(job);
          } catch (e) {
            debugPrint("FETCH MY JOBS: Error parsing job at index $i: $e");
            debugPrint("FETCH MY JOBS: Problematic data: ${data[i]}");
            // Continue parsing other jobs instead of failing completely
          }
        }

        debugPrint("FETCH MY JOBS: Successfully parsed ${jobs.length} jobs");
        return jobs;
      } else if (response.statusCode == 500) {
        debugPrint("FETCH MY JOBS: Server error (500) - ${response.body}");
        throw Exception("Server error: ${response.body}");
      }

      throw Exception(
        "Failed to load my jobs (${response.statusCode}): ${response.body}",
      );
    } on TimeoutException {
      debugPrint("FETCH MY JOBS ERROR: Server timeout");
      throw Exception("Server timeout - please try again");
    } on FormatException catch (e) {
      debugPrint("FETCH MY JOBS ERROR: JSON parsing error - $e");
      throw Exception("Invalid data format from server");
    } catch (e) {
      debugPrint("FETCH MY JOBS ERROR: $e");
      throw Exception("Fetch my jobs failed: $e");
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

  // ===============================
  // 🔹 SAVE JOB
  // ===============================
  static Future<void> saveJob({
    required String userEmail,
    required int jobId,
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse("${ApiEndpoints.baseUrl}/jobs/save"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"user_email": userEmail, "job_id": jobId}),
          )
          .timeout(const Duration(seconds: 20));

      debugPrint("SAVE JOB STATUS: ${res.statusCode}");
      debugPrint("SAVE JOB BODY: ${res.body}");

      if (res.statusCode != 200 && res.statusCode != 201) {
        throw Exception("Save job failed (${res.statusCode})");
      }
    } on TimeoutException {
      throw Exception("Server timeout");
    } catch (e) {
      debugPrint("SAVE JOB ERROR: $e");
      throw Exception("Save job failed");
    }
  }

  // ===============================
  // 🔹 UNSAVE JOB
  // ===============================
  static Future<void> unsaveJob({
    required int jobId,
    required String userEmail,
  }) async {
    try {
      final res = await http
          .delete(
            Uri.parse(
              "${ApiEndpoints.baseUrl}/jobs/save/$jobId?email=$userEmail",
            ),
            headers: {"Content-Type": "application/json"},
          )
          .timeout(const Duration(seconds: 20));

      debugPrint("UNSAVE JOB STATUS: ${res.statusCode}");
      debugPrint("UNSAVE JOB BODY: ${res.body}");

      if (res.statusCode != 200) {
        throw Exception("Unsave job failed (${res.statusCode})");
      }
    } on TimeoutException {
      throw Exception("Server timeout");
    } catch (e) {
      debugPrint("UNSAVE JOB ERROR: $e");
      throw Exception("Unsave job failed");
    }
  }

  // ===============================
  // 🔹 GET SAVED JOBS
  // ===============================
  static Future<List<Job>> fetchSavedJobs(String email) async {
    try {
      final uri = Uri.parse('${ApiEndpoints.baseUrl}/jobs/saved?email=$email');
      debugPrint("FETCH SAVED JOBS URL: $uri");

      final response = await http
          .get(uri, headers: {"Content-Type": "application/json"})
          .timeout(const Duration(seconds: 10));

      debugPrint("FETCH SAVED JOBS STATUS: ${response.statusCode}");
      debugPrint("FETCH SAVED JOBS BODY: ${response.body}");

      if (response.statusCode == 200) {
        if (response.body.isEmpty || response.body == '[]') {
          return [];
        }

        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((e) => Job.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      throw Exception("Failed to load saved jobs (${response.statusCode})");
    } on TimeoutException {
      throw Exception("Server timeout");
    } catch (e) {
      debugPrint("FETCH SAVED JOBS ERROR: $e");
      throw Exception("Fetch saved jobs failed");
    }
  }

  // ===============================
  // 🔹 CHECK IF JOB IS SAVED
  // ===============================
  static Future<bool> checkJobSaved({
    required int jobId,
    required String userEmail,
  }) async {
    try {
      final uri = Uri.parse(
        '${ApiEndpoints.baseUrl}/jobs/saved/$jobId?email=$userEmail',
      );

      final response = await http
          .get(uri, headers: {"Content-Type": "application/json"})
          .timeout(const Duration(seconds: 10));

      debugPrint("CHECK SAVED JOB STATUS: ${response.statusCode}");
      debugPrint("CHECK SAVED JOB BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["is_saved"] == true;
      }

      return false;
    } on TimeoutException {
      throw Exception("Server timeout");
    } catch (e) {
      debugPrint("CHECK SAVED JOB ERROR: $e");
      return false;
    }
  }
}
