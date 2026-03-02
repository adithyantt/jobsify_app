import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../utils/api_config.dart';
import '../utils/api_constants.dart';
import '../services/user_session.dart';

class AuthService {
  // ================= REGISTER =================
  static Future<Map<String, dynamic>> registerUser({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse("${ApiConfig.baseUrl}/auth/register"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "first_name": firstName,
              "last_name": lastName,
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
        // Build full name from first_name and last_name for atomicity
        final firstName = body["first_name"] ?? "";
        final lastName = body["last_name"] ?? "";
        final fullName = (firstName.isNotEmpty && lastName.isNotEmpty)
            ? "$firstName $lastName"
            : (body["name"] ?? "User");

        // ✅ SAVE USER SESSION DATA
        UserSession.email = body["email"];
        UserSession.userName = fullName;
        UserSession.role = body["role"];
        UserSession.token = body["access_token"];

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

  // ================= LOGIN =================
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
          // Account not verified, return user_id and name for OTP verification
          final firstName = decoded["first_name"] ?? "";
          final lastName = decoded["last_name"] ?? "";
          final fullName = (firstName.isNotEmpty && lastName.isNotEmpty)
              ? "$firstName $lastName"
              : (decoded["name"] ?? "User");

          return {
            "success": false,
            "unverified": true,
            "user_id": decoded["user_id"],
            "name": fullName,
            "first_name": firstName,
            "last_name": lastName,
            "message":
                decoded["message"] ??
                "Account not verified. Please verify your email.",
          };
        }

        // Build full name from first_name and last_name for atomicity
        final firstName = decoded["first_name"] ?? "";
        final lastName = decoded["last_name"] ?? "";
        final fullName = (firstName.isNotEmpty && lastName.isNotEmpty)
            ? "$firstName $lastName"
            : (decoded["name"] ?? "User");

        // ✅ SAVE USER SESSION DATA
        UserSession.email = decoded["email"];
        UserSession.userName = fullName;
        UserSession.role = decoded["role"];
        UserSession.token = decoded["access_token"];

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
