import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/job_model.dart';

class JobService {
  // Android Emulator backend URL
  static const String baseUrl = "http://172.22.39.105:8000";

  static Future<List<Job>> fetchJobs() async {
    final uri = Uri.parse("$baseUrl/jobs");
    print("🚀 Fetching jobs from: $uri");

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 5));

      print("✅ Status Code: ${response.statusCode}");
      print("📦 Body: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print("🧩 Jobs count: ${data.length}");

        return data.map((e) => Job.fromJson(e)).toList();
      } else {
        throw Exception("Server error ${response.statusCode}");
      }
    } on http.ClientException catch (e) {
      print("❌ CLIENT ERROR: $e");
      throw Exception("Client error");
    } on FormatException catch (e) {
      print("❌ JSON FORMAT ERROR: $e");
      throw Exception("Invalid JSON");
    } catch (e) {
      print("🔥 UNKNOWN ERROR: $e");
      throw Exception("Unexpected error");
    }
  }
}
