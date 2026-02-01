import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // static const String baseUrl = "http://10.137.141.105:8000";
  static const String baseUrl = "http://172.22.39.105:8000"; //A06  hotsopt

  // OR use http://localhost:8000 for emulator

  // ✅ REGISTER
  static Future<bool> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"name": name, "email": email, "password": password}),
      );

      print("REGISTER RESPONSE: ${response.body}");
      return response.statusCode == 200;
    } catch (e) {
      print("REGISTER ERROR: $e");
      return false;
    }
  }

  // ✅ LOGIN (RETURN ROLE)
  static Future<Map<String, dynamic>?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      print("LOGIN RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print("LOGIN ERROR: $e");
      return null;
    }
  }

  // ✅ FETCH LATEST PROFILE (optional; backend may expose this endpoint)
  static Future<Map<String, dynamic>?> fetchProfile({required String email}) async {
    try {
      final uri = Uri.parse("$baseUrl/auth/profile?email=$email");
      final response = await http.get(uri, headers: {"Content-Type": "application/json"});

      print("PROFILE RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print("PROFILE ERROR: $e");
      return null;
    }
  }
}
