import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/conversation_model.dart';
import '../models/message_model.dart';
import '../utils/api_endpoints.dart';

class MessagingService {
  static Uri _uri(String path, [Map<String, String>? queryParameters]) {
    return Uri.parse("${ApiEndpoints.baseUrl}$path").replace(
      queryParameters: queryParameters,
    );
  }

  static Future<List<ConversationModel>> fetchConversations(
    String userEmail,
  ) async {
    final response = await http.get(
      _uri("/messages/conversations", {"user_email": userEmail}),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to load conversations");
    }

    final decoded = jsonDecode(response.body) as List<dynamic>;
    return decoded
        .map((item) => ConversationModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static Future<ConversationModel> createOrGetConversation({
    required String senderEmail,
    required String recipientEmail,
    int? workerId,
    String? initialMessage,
  }) async {
    final response = await http.post(
      _uri("/messages/conversations"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "sender_email": senderEmail,
        "recipient_email": recipientEmail,
        "worker_id": workerId,
        "initial_message": initialMessage,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to start conversation");
    }

    return ConversationModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  static Future<ConversationDetailModel> fetchConversationDetail({
    required int conversationId,
    required String userEmail,
  }) async {
    final response = await http.get(
      _uri(
        "/messages/conversations/$conversationId",
        {"user_email": userEmail},
      ),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to load messages");
    }

    return ConversationDetailModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  static Future<MessageModel> sendMessage({
    required int conversationId,
    required String senderEmail,
    required String content,
  }) async {
    final response = await http.post(
      _uri("/messages/conversations/$conversationId"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "sender_email": senderEmail,
        "content": content,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to send message");
    }

    return MessageModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  static Future<void> markConversationAsRead({
    required int conversationId,
    required String userEmail,
  }) async {
    final response = await http.put(
      _uri(
        "/messages/conversations/$conversationId/read",
        {"user_email": userEmail},
      ),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to mark conversation as read");
    }
  }

  static Future<int> getUnreadCount(String userEmail) async {
    final response = await http.get(
      _uri("/messages/unread-count", {"user_email": userEmail}),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode != 200) {
      return 0;
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return decoded["unread_count"] ?? 0;
  }
}
