import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../utils/api_endpoints.dart';
import '../services/user_session.dart';

class AuthService {
  // ================= REGISTER =================
  static Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse("${ApiEndpoints.baseUrl}/auth/register"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "name": name,
              "email": email,
              "password": password,
            }),
          )
          .timeout(const Duration(seconds: 10));

      final body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          "success": true,
          "message": body["message"] ?? "Registered successfully",
        };
      }

      return {
        "success": false,
        "message": body["detail"] ?? "Registration failed",
      };
    } on TimeoutException {
      return {"success": false, "message": "Server timeout"};
    } catch (e) {
      return {"success": false, "message": "Unable to connect to server"};
    }
  }

  // ================= LOGIN (JSON – FINAL FIX) =================
  static Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiEndpoints.login),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"email": email, "password": password}),
          )
          .timeout(const Duration(seconds: 10));

      debugPrint("LOGIN STATUS CODE: ${response.statusCode}");
      debugPrint("LOGIN RAW RESPONSE: ${response.body}");

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // ✅ SAVE USER SESSION DATA
        UserSession.email = decoded["email"];
        UserSession.userName = decoded["name"];
        UserSession.role = decoded["role"];

        return {"success": true};
      }

      return {
        "success": false,
        "message": decoded["detail"] ?? "Invalid credentials",
      };
    } catch (e) {
      debugPrint("LOGIN ERROR: $e");
      return {"success": false, "message": "Unable to connect to server"};
    }
  }
}
