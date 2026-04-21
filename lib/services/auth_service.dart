import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../services/user_session.dart';
import '../utils/api_constants.dart';
import '../utils/api_endpoints.dart';

class AuthService {
  static String _buildDisplayName(
    Map<String, dynamic> data, {
    String fallback = "User",
  }) {
    final firstName = (data["first_name"] ?? "").toString().trim();
    final lastName = (data["last_name"] ?? "").toString().trim();
    final fullName = [firstName, lastName]
        .where((part) => part.isNotEmpty)
        .join(" ");

    if (fullName.isNotEmpty) {
      return fullName;
    }

    final email = (data["email"] ?? "").toString().trim();
    if (email.contains("@")) {
      return email.split("@").first;
    }

    return fallback;
  }

  static Future<Map<String, dynamic>> registerUser({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    final registerUri = Uri.parse(ApiEndpoints.register);
    try {
      final response = await http
          .post(
            registerUri,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "first_name": firstName,
              "last_name": lastName,
              "email": email.toLowerCase(),
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
      debugPrint("REGISTER ERROR: timeout calling $registerUri");
      return {
        "success": false,
        "message":
            "Registration request timed out. Check that the backend is running at ${ApiEndpoints.baseUrl}.",
      };
    } on http.ClientException catch (e) {
      debugPrint("REGISTER ERROR: client error calling $registerUri: $e");
      return {
        "success": false,
        "message":
            "Unable to reach the backend at ${ApiEndpoints.baseUrl}. If you are on the Android emulator, use 10.0.2.2 or pass --dart-define=API_BASE_URL=http://10.0.2.2:8000.",
      };
    } catch (e) {
      debugPrint("REGISTER ERROR: $e");
      return {
        "success": false,
        "message":
            "Registration failed: ${kDebugMode ? e.toString() : "Unable to connect to server"}",
      };
    }
  }

  static Future<Map<String, dynamic>> verifyOtp({
    required int userId,
    required String otp,
  }) async {
    final verifyOtpUri = Uri.parse(ApiEndpoints.verifyOtp);
    try {
      final response = await http
          .post(
            verifyOtpUri,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"user_id": userId, "otp": otp}),
          )
          .timeout(const Duration(seconds: 20));

      final body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final fullName = _buildDisplayName(body);

        UserSession.email = body["email"];
        UserSession.userName = fullName;
        UserSession.role = body["role"];
        UserSession.token = body["access_token"]?.toString();
        UserSession.phone = body["phone"];

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
      debugPrint("VERIFY OTP ERROR: timeout calling $verifyOtpUri");
      return {
        "success": false,
        "message":
            "OTP verification timed out. Check that the backend is running at ${ApiEndpoints.baseUrl}.",
      };
    } on http.ClientException catch (e) {
      debugPrint("VERIFY OTP ERROR: client error calling $verifyOtpUri: $e");
      return {
        "success": false,
        "message":
            "Unable to reach the backend at ${ApiEndpoints.baseUrl}.",
      };
    } catch (e) {
      debugPrint("VERIFY OTP ERROR: $e");
      return {
        "success": false,
        "message":
            "Verification failed: ${kDebugMode ? e.toString() : "Unable to connect to server"}",
      };
    }
  }

  static Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    final loginUri = Uri.parse("${ApiEndpoints.baseUrl}/auth/login");
    try {
      final response = await http
          .post(
            loginUri,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "email": email.toLowerCase(),
              "password": password,
            }),
          )
          .timeout(const Duration(seconds: 20));

      debugPrint("LOGIN STATUS CODE: ${response.statusCode}");
      debugPrint("LOGIN RAW RESPONSE: ${response.body}");

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (decoded.containsKey("unverified") &&
            decoded["unverified"] == true) {
          return {
            "success": false,
            "unverified": true,
            "user_id": decoded["user_id"],
            "first_name": decoded["first_name"],
            "last_name": decoded["last_name"],
            "message":
                decoded["message"] ??
                "Account not verified. Please verify your email.",
          };
        }

        final fullName = _buildDisplayName(decoded);

        UserSession.email = decoded["email"];
        UserSession.userName = fullName;
        UserSession.role = decoded["role"];
        UserSession.token = decoded["access_token"]?.toString();
        UserSession.phone = decoded["phone"];

        if (ApiConstants.adminEmails.contains(decoded["email"])) {
          UserSession.role = 'admin';
        }

        return {"success": true};
      }

      return {
        "success": false,
        "message": decoded["detail"] ?? "Invalid credentials",
      };
    } on TimeoutException {
      debugPrint("LOGIN ERROR: timeout calling $loginUri");
      return {
        "success": false,
        "message":
            "Login request timed out. Check that the backend is running at ${ApiEndpoints.baseUrl}.",
      };
    } on http.ClientException catch (e) {
      debugPrint("LOGIN ERROR: client error calling $loginUri: $e");
      return {
        "success": false,
        "message":
            "Unable to reach the backend at ${ApiEndpoints.baseUrl}. Start the server or update API_BASE_URL.",
      };
    } catch (e) {
      debugPrint("LOGIN ERROR: $e");
      return {
        "success": false,
        "message":
            "Login failed: ${kDebugMode ? e.toString() : "Unable to connect to server"}",
      };
    }
  }

  static Future<Map<String, dynamic>> requestPasswordReset({
    required String email,
  }) async {
    final forgotPasswordRequestUri = Uri.parse(ApiEndpoints.forgotPasswordRequest);
    try {
      final response = await http
          .post(
            forgotPasswordRequestUri,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"email": email.toLowerCase()}),
          )
          .timeout(const Duration(seconds: 20));

      final body = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {
          "success": true,
          "message": body["message"] ?? "Reset OTP sent successfully",
        };
      }

      return {
        "success": false,
        "message": body["detail"] ?? "Unable to send reset OTP",
      };
    } on TimeoutException {
      debugPrint(
        "FORGOT PASSWORD REQUEST ERROR: timeout calling $forgotPasswordRequestUri",
      );
      return {
        "success": false,
        "message":
            "Password reset request timed out. Check that the backend is running at ${ApiEndpoints.baseUrl}.",
      };
    } on http.ClientException catch (e) {
      debugPrint(
        "FORGOT PASSWORD REQUEST ERROR: client error calling $forgotPasswordRequestUri: $e",
      );
      return {
        "success": false,
        "message":
            "Unable to reach the backend at ${ApiEndpoints.baseUrl}.",
      };
    } catch (e) {
      debugPrint("FORGOT PASSWORD REQUEST ERROR: $e");
      return {
        "success": false,
        "message":
            "Unable to send reset OTP: ${kDebugMode ? e.toString() : "Unable to connect to server"}",
      };
    }
  }

  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    final forgotPasswordResetUri = Uri.parse(ApiEndpoints.forgotPasswordReset);
    try {
      final response = await http
          .post(
            forgotPasswordResetUri,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "email": email.toLowerCase(),
              "otp": otp,
              "new_password": newPassword,
            }),
          )
          .timeout(const Duration(seconds: 20));

      final body = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {
          "success": true,
          "message": body["message"] ?? "Password reset successful",
        };
      }

      return {
        "success": false,
        "message": body["detail"] ?? "Unable to reset password",
      };
    } on TimeoutException {
      debugPrint(
        "FORGOT PASSWORD RESET ERROR: timeout calling $forgotPasswordResetUri",
      );
      return {
        "success": false,
        "message":
            "Password reset timed out. Check that the backend is running at ${ApiEndpoints.baseUrl}.",
      };
    } on http.ClientException catch (e) {
      debugPrint(
        "FORGOT PASSWORD RESET ERROR: client error calling $forgotPasswordResetUri: $e",
      );
      return {
        "success": false,
        "message":
            "Unable to reach the backend at ${ApiEndpoints.baseUrl}.",
      };
    } catch (e) {
      debugPrint("FORGOT PASSWORD RESET ERROR: $e");
      return {
        "success": false,
        "message":
            "Password reset failed: ${kDebugMode ? e.toString() : "Unable to connect to server"}",
      };
    }
  }
}
