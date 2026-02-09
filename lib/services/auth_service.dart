import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../utils/api_config.dart';
import '../utils/api_endpoints.dart';
import '../utils/api_constants.dart';
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
            Uri.parse("${ApiConfig.baseUrl}/auth/register"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "name": name,
              "email": email,
              "password": password,
            }),
          )
          .timeout(const Duration(seconds: 20));

      final body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          "success": true,
          "message": body["message"] ?? "Registered successfully",
          "user_id": body["user_id"],
          "role": body["role"],
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

  // ================= VERIFY OTP =================
  static Future<Map<String, dynamic>> verifyOtp({
    required int userId,
    required String otp,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse("${ApiConfig.baseUrl}/auth/verify-otp"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"user_id": userId, "otp": otp}),
          )
          .timeout(const Duration(seconds: 20));

      final body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // ✅ SAVE USER SESSION DATA
        UserSession.email = body["email"];
        UserSession.userName = body["name"];
        UserSession.role = body["role"];

        return {
          "success": true,
          "message": body["message"] ?? "Verification successful",
        };
      }

      return {
        "success": false,
        "message": body["detail"] ?? "Verification failed",
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
            Uri.parse("${ApiConfig.baseUrl}/auth/login"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"email": email, "password": password}),
          )
          .timeout(const Duration(seconds: 20));

      debugPrint("LOGIN STATUS CODE: ${response.statusCode}");
      debugPrint("LOGIN RAW RESPONSE: ${response.body}");

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (decoded.containsKey("unverified") &&
            decoded["unverified"] == true) {
          // Account not verified, return user_id for OTP verification
          return {
            "success": false,
            "unverified": true,
            "user_id": decoded["user_id"],
            "message":
                decoded["message"] ??
                "Account not verified. Please verify your email.",
          };
        }

        // ✅ SAVE USER SESSION DATA
        UserSession.email = decoded["email"];
        UserSession.userName = decoded["name"];
        UserSession.role = decoded["role"];

        // Override role for predefined admin emails
        if (ApiConstants.adminEmails.contains(decoded["email"])) {
          UserSession.role = 'admin';
        }

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
