import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/worker_model.dart';
import '../utils/api_endpoints.dart';

class WorkerService {
  // ===============================
  // 🔹 FETCH VERIFIED WORKERS (PUBLIC) WITH FILTERS
  // ===============================
  static Future<List<Worker>> fetchWorkers({
    int? minExperience,
    int? maxExperience,
    double? minRating,
    String? location,
    String? availabilityType, // everyday | selected_days | not_available
    List<String>? availableDays, // ["Mon", "Tue", "Wed"]
    bool? isAvailable,
    String? sortBy,
  }) async {
    // Build query parameters
    final queryParams = <String, String>{};
    if (minExperience != null) {
      queryParams['min_experience'] = minExperience.toString();
    }
    if (maxExperience != null) {
      queryParams['max_experience'] = maxExperience.toString();
    }
    if (minRating != null) {
      queryParams['min_rating'] = minRating.toString();
    }
    if (location != null && location.isNotEmpty) {
      queryParams['location'] = location;
    }
    if (availabilityType != null && availabilityType.isNotEmpty) {
      queryParams['availability_type'] = availabilityType;
    }
    if (availableDays != null && availableDays.isNotEmpty) {
      queryParams['available_days'] = availableDays.join(',');
    }
    if (isAvailable != null) {
      queryParams['is_available'] = isAvailable.toString();
    }
    if (sortBy != null && sortBy.isNotEmpty) {
      queryParams['sort_by'] = sortBy;
    }

    final uri = Uri.parse(
      ApiEndpoints.workers,
    ).replace(queryParameters: queryParams.isEmpty ? null : queryParams);

    try {
      final res = await http.get(
        uri,
        headers: {"Content-Type": "application/json"},
      );

      debugPrint("FETCH WORKERS STATUS: ${res.statusCode}");
      debugPrint("FETCH WORKERS BODY: ${res.body}");

      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        return data.map((e) => Worker.fromJson(e)).toList();
      } else {
        throw Exception("Failed to load workers (${res.statusCode})");
      }
    } catch (e) {
      debugPrint("FETCH WORKERS ERROR: $e");
      throw Exception("Fetch workers failed");
    }
  }

  // ===============================
  // 🔹 GET WORKER BY ID (PUBLIC)
  // ===============================
  static Future<Worker?> fetchWorkerById(int workerId) async {
    final uri = Uri.parse('${ApiEndpoints.workers}/$workerId');

    try {
      final res = await http.get(
        uri,
        headers: {"Content-Type": "application/json"},
      );

      debugPrint("FETCH WORKER BY ID STATUS: ${res.statusCode}");
      debugPrint("FETCH WORKER BY ID BODY: ${res.body}");

      if (res.statusCode == 200) {
        if (res.body.isEmpty || res.body == 'null') {
          return null;
        }
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return Worker.fromJson(data);
      } else if (res.statusCode == 404) {
        return null; // Worker not found
      }

      throw Exception("Failed to load worker (${res.statusCode})");
    } catch (e) {
      debugPrint("FETCH WORKER BY ID ERROR: $e");
      return null;
    }
  }

  // ===============================
  // 🔹 CREATE WORKER (PUBLIC)
  // (ADMIN APPROVAL REQUIRED LATER)
  // ===============================
  static Future<void> createWorker({
    required String name,
    required String role,
    required String phone,
    required int experience,
    required String location,
    String? latitude,
    String? longitude,
    required String userEmail,
    String? availabilityType, // everyday | selected_days | not_available
    String? availableDays, // Comma-separated: "Mon,Tue,Wed"
  }) async {
    final res = await http.post(
      Uri.parse(ApiEndpoints.workers),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "role": role,
        "phone": phone,
        "experience": experience,
        "location": location,
        "latitude": latitude,
        "longitude": longitude,
        "user_email": userEmail,
        "availability_type": availabilityType ?? "everyday",
        "available_days": availableDays,
      }),
    );

    debugPrint("CREATE WORKER STATUS: ${res.statusCode}");
    debugPrint("CREATE WORKER BODY: ${res.body}");

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception("Create worker failed (${res.statusCode})");
    }
  }

  // ===============================
  // 🔹 REPORT WORKER
  // ===============================
  static Future<void> reportWorker({
    required int workerId,
    required String reason,
    required String description,
    required String reporterEmail,
  }) async {
    final res = await http.post(
      Uri.parse("${ApiEndpoints.baseUrl}/workers/report"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "worker_id": workerId,
        "reason": reason,
        "description": description,
        "reporter_email": reporterEmail,
      }),
    );

    debugPrint("REPORT WORKER STATUS: ${res.statusCode}");
    debugPrint("REPORT WORKER BODY: ${res.body}");

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception("Report worker failed (${res.statusCode})");
    }
  }

  // ===============================
  // 🔹 FETCH MY WORKERS (USER-SPECIFIC)
  // ===============================

  static Future<List<Worker>> fetchMyWorkers(String email) async {
    final uri = Uri.parse('${ApiEndpoints.myWorkers}?email=$email');

    try {
      final res = await http.get(
        uri,
        headers: {"Content-Type": "application/json"},
      );

      debugPrint("FETCH MY WORKERS STATUS: ${res.statusCode}");
      debugPrint("FETCH MY WORKERS BODY: ${res.body}");

      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        return data.map((e) => Worker.fromJson(e)).toList();
      } else {
        throw Exception("Failed to load my workers (${res.statusCode})");
      }
    } catch (e) {
      debugPrint("FETCH MY WORKERS ERROR: $e");
      throw Exception("Fetch my workers failed");
    }
  }

  // ===============================
  // 🔹 UPDATE WORKER
  // ===============================
  static Future<void> updateWorker({
    required int workerId,
    required String name,
    required String role,
    required String phone,
    required int experience,
    required String location,
    String? latitude,
    String? longitude,
    required String userEmail,
    String? availabilityType,
    String? availableDays,
  }) async {
    final uri = Uri.parse('${ApiEndpoints.workers}/$workerId?email=$userEmail');

    final body = {
      "name": name,
      "role": role,
      "phone": phone,
      "experience": experience,
      "location": location,
      "latitude": latitude,
      "longitude": longitude,
      "user_email": userEmail,
      "availability_type": availabilityType ?? "everyday",
      "available_days": availableDays,
    };

    try {
      final res = await http.put(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      debugPrint("UPDATE WORKER STATUS: ${res.statusCode}");
      debugPrint("UPDATE WORKER BODY: ${res.body}");

      if (res.statusCode != 200) {
        throw Exception("Update worker failed (${res.statusCode})");
      }
    } catch (e) {
      debugPrint("UPDATE WORKER ERROR: $e");
      throw Exception("Update worker failed");
    }
  }

  // ===============================
  // 🔹 DELETE WORKER
  // ===============================
  static Future<void> deleteWorker({
    required int workerId,
    required String userEmail,
  }) async {
    final uri = Uri.parse('${ApiEndpoints.workers}/$workerId?email=$userEmail');

    try {
      final res = await http.delete(
        uri,
        headers: {"Content-Type": "application/json"},
      );

      debugPrint("DELETE WORKER STATUS: ${res.statusCode}");
      debugPrint("DELETE WORKER BODY: ${res.body}");

      if (res.statusCode != 200) {
        throw Exception("Delete worker failed (${res.statusCode})");
      }
    } catch (e) {
      debugPrint("DELETE WORKER ERROR: $e");
      throw Exception("Delete worker failed");
    }
  }
}
