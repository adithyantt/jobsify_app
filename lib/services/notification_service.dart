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
      print('📨 NOTIFICATIONS API RESPONSE:');
      print('  Status: ${res.statusCode}');
      print('  Count: ${data.length}');
      if (data.isNotEmpty) {
        print('  First notification: ${data.first}');
      }
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

  static Future<int> getUnreadCount(String userEmail) async {
    try {
      final notifications = await fetchNotifications(userEmail);
      return notifications.where((n) => !n.isRead).length;
    } catch (e) {
      return 0;
    }
  }
}
