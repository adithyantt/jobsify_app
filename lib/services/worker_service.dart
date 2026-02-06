import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/worker_model.dart';
import '../utils/api_endpoints.dart';

class WorkerService {
  // ===============================
  // 🔹 FETCH VERIFIED WORKERS (PUBLIC)
  // ===============================
  static Future<List<Worker>> fetchWorkers() async {
    final uri = Uri.parse("${ApiEndpoints.baseUrl}/workers");

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
  }) async {
    final res = await http.post(
      Uri.parse("${ApiEndpoints.baseUrl}/workers/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "role": role,
        "phone": phone,
        "experience": experience,
        "location": location,
        "latitude": latitude,
        "longitude": longitude,
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
  }) async {
    final res = await http.post(
      Uri.parse("${ApiEndpoints.baseUrl}/workers/report"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "worker_id": workerId,
        "reason": reason,
        "description": description,
      }),
    );

    debugPrint("REPORT WORKER STATUS: ${res.statusCode}");
    debugPrint("REPORT WORKER BODY: ${res.body}");

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception("Report worker failed (${res.statusCode})");
    }
  }
}
