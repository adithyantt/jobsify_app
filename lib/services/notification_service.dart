import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/notification_model.dart';
import '../utils/api_endpoints.dart';

export 'connectivity_service.dart' show NoInternetException;

class NotificationService {
  static Future<List<Notification>> fetchNotifications(String userEmail) async {
    // Removed strict connectivity check - now tries API + catches real HTTP errors
    final res = await http.get(
      Uri.parse("${ApiEndpoints.baseUrl}/notifications?user_email=$userEmail"),
      headers: {"Content-Type": "application/json"},
    );

    if (res.statusCode == 200) {
      final dynamic decoded = jsonDecode(res.body);
      List<dynamic> data;

      if (decoded is List) {
        data = decoded;
      } else if (decoded is Map &&
          (decoded.containsKey("notifications") ||
              decoded.containsKey("data"))) {
        data = decoded["notifications"] ?? decoded["data"];
      } else {
        return [];
      }

      return data
          .map((e) => Notification.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception("Failed to load notifications");
    }
  }

  static Future<void> markAsRead(int notificationId) async {
    // Removed strict connectivity check - now tries API + catches real HTTP errors
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
