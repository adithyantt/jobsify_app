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
  // ===============================
  // 🔹 GET ALL VERIFIED JOBS (WITH FILTERS)
  // ===============================
  // Full filters: salary range, location (comma-separated), urgent
  static Future<List<Job>> fetchJobs({
    int page = 1,
    int limit = 20,
    String? category,
    String? location,
    bool? urgent,
    double? minSalary,
    double? maxSalary,
  }) async {
    final params = <String, String?>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (category != null) params['category'] = category;
    if (location != null && location.isNotEmpty) params['location'] = location;
    if (urgent != null) params['urgent'] = urgent.toString();
    if (minSalary != null) params['min_salary'] = minSalary.toString();
    if (maxSalary != null) params['max_salary'] = maxSalary.toString();

    final nonNullParams = params.entries
        .where((entry) => entry.value != null)
        .fold<Map<String, String>>(
          {},
          (map, entry) => map..[entry.key] = entry.value!,
        );
    final uri = Uri.parse(
      ApiEndpoints.jobs,
    ).replace(queryParameters: nonNullParams);

    try {
      final response = await http
          .get(uri, headers: {"Content-Type": "application/json"})
          .timeout(const Duration(seconds: 15));

      debugPrint("FETCH JOBS URL: $uri");
      debugPrint("FETCH JOBS STATUS: ${response.statusCode}");
      debugPrint("FETCH JOBS BODY: ${response.body}");
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body == null || body is! Map) {
          debugPrint(
            "FETCH JOBS ERROR: Invalid JSON response (null or not Map)",
          );
          return [];
        }
        final List<dynamic> data = body["jobs"] ?? [];
        return data
            .map((e) => Job.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw Exception("Failed to load jobs (${response.statusCode})");
    } on TimeoutException {
      throw Exception("Server timeout");
    } catch (e) {
      debugPrint("FETCH JOBS ERROR: $e");
      throw Exception("Fetch jobs failed: $e");
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
  // ===============================
  static Future<void> createJob({
    required String title,
    required String category,
    required String description,
    required String location,
    required String phone,
    String? latitude,
    String? longitude,
    required String userEmail,
    bool? urgent,
    String? salary,
    int? requiredWorkers,
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
      "user_email": userEmail,
      "urgent": urgent ?? false,
      "salary": salary,
      "required_workers": requiredWorkers ?? 1,
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

  static Future<List<Job>> fetchMyJobs(String email) async {
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
        if (response.body.isEmpty) {
          return [];
        }

        final dynamic decoded = jsonDecode(response.body);
        List<dynamic> data;

        if (decoded is List) {
          data = decoded;
        } else if (decoded is Map &&
            (decoded.containsKey("jobs") || decoded.containsKey("data"))) {
          data = decoded["jobs"] ?? decoded["data"];
        } else {
          return [];
        }

        final jobs = <Job>[];
        for (var i = 0; i < data.length; i++) {
          try {
            final job = Job.fromJson(data[i] as Map<String, dynamic>);
            jobs.add(job);
          } catch (e) {
            debugPrint("FETCH MY JOBS: Error parsing job at index $i: $e");
          }
        }
        return jobs;
      } else if (response.statusCode == 500) {
        throw Exception("Server error: ${response.body}");
      }

      throw Exception("Failed to load my jobs (${response.statusCode})");
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
    bool? urgent,
    String? salary,
    int? requiredWorkers,
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
      "urgent": urgent ?? false,
      "salary": salary,
      "required_workers": requiredWorkers ?? 1,
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
        if (response.body.isEmpty) {
          return [];
        }

        final dynamic decoded = jsonDecode(response.body);
        List<dynamic> data;

        if (decoded is List) {
          data = decoded;
        } else if (decoded is Map &&
            (decoded.containsKey("jobs") || decoded.containsKey("data"))) {
          data = decoded["jobs"] ?? decoded["data"];
        } else {
          return [];
        }

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

  // ===============================
  // 🔹 HIDE JOB (Soft Delete)
  // ===============================
  static Future<void> hideJob({
    required int jobId,
    required String userEmail,
  }) async {
    final uri = Uri.parse('${ApiEndpoints.jobs}/$jobId/hide?email=$userEmail');

    try {
      final response = await http
          .put(uri, headers: {"Content-Type": "application/json"})
          .timeout(const Duration(seconds: 10));

      debugPrint("HIDE JOB STATUS: ${response.statusCode}");

      if (response.statusCode != 200) {
        throw Exception("Job hide failed (${response.statusCode})");
      }
    } on TimeoutException {
      throw Exception("Server timeout");
    } catch (e) {
      debugPrint("HIDE JOB ERROR: $e");
      throw Exception("Hide job failed");
    }
  }

  // ===============================
  // 🔹 SHOW JOB (Restore from Hidden)
  // ===============================
  static Future<void> showJob({
    required int jobId,
    required String userEmail,
  }) async {
    final uri = Uri.parse('${ApiEndpoints.jobs}/$jobId/show?email=$userEmail');

    try {
      final response = await http
          .put(uri, headers: {"Content-Type": "application/json"})
          .timeout(const Duration(seconds: 10));

      debugPrint("SHOW JOB STATUS: ${response.statusCode}");

      if (response.statusCode != 200) {
        throw Exception("Job show failed (${response.statusCode})");
      }
    } on TimeoutException {
      throw Exception("Server timeout");
    } catch (e) {
      debugPrint("SHOW JOB ERROR: $e");
      throw Exception("Show job failed");
    }
  }

  // ===============================
  // 🔹 HIRE WORKER (Update Vacancies)
  // ===============================
  static Future<Map<String, dynamic>> hireWorker({
    required int jobId,
    required String userEmail,
  }) async {
    final uri = Uri.parse('${ApiEndpoints.jobs}/$jobId/hire?email=$userEmail');

    try {
      final response = await http
          .put(uri, headers: {"Content-Type": "application/json"})
          .timeout(const Duration(seconds: 10));

      debugPrint("HIRE WORKER STATUS: ${response.statusCode}");

      if (response.statusCode != 200) {
        throw Exception("Hire worker failed (${response.statusCode})");
      }

      return jsonDecode(response.body);
    } on TimeoutException {
      throw Exception("Server timeout");
    } catch (e) {
      debugPrint("HIRE WORKER ERROR: $e");
      throw Exception("Hire worker failed");
    }
  }

  // ===============================
  // 🔹 UPDATE REQUIRED WORKERS
  // ===============================
  static Future<Map<String, dynamic>> updateRequiredWorkers({
    required int jobId,
    required String userEmail,
    required int requiredWorkers,
  }) async {
    final uri = Uri.parse(
      '${ApiEndpoints.jobs}/$jobId/required-workers?email=$userEmail&required_workers=$requiredWorkers',
    );

    try {
      final response = await http
          .put(uri, headers: {"Content-Type": "application/json"})
          .timeout(const Duration(seconds: 10));

      debugPrint("UPDATE REQUIRED WORKERS STATUS: ${response.statusCode}");

      if (response.statusCode != 200) {
        throw Exception(
          "Update required workers failed (${response.statusCode})",
        );
      }

      return jsonDecode(response.body);
    } on TimeoutException {
      throw Exception("Server timeout");
    } catch (e) {
      debugPrint("UPDATE REQUIRED WORKERS ERROR: $e");
      throw Exception("Update required workers failed");
    }
  }
}
