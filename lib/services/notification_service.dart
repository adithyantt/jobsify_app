import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/notification_model.dart';
import '../utils/api_endpoints.dart';

class NotificationService {
  static Future<List<Notification>> fetchNotifications(String userEmail) async {
    final res = await http.get(
      Uri.parse("${ApiEndpoints.notifications}?user_email=$userEmail"),
      headers: {"Content-Type": "application/json"},
    );

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => Notification.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load notifications");
    }
  }

  static Future<void> markAsRead(int notificationId) async {
    final res = await http.put(
      Uri.parse("${ApiEndpoints.notifications}/$notificationId/read"),
      headers: {"Content-Type": "application/json"},
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to mark notification as read");
    }
  }
}
