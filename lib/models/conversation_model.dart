import 'message_model.dart';

class ConversationModel {
  final int id;
  final String participantEmail;
  final String participantName;
  final int? workerId;
  final String? workerName;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;

  ConversationModel({
    required this.id,
    required this.participantEmail,
    required this.participantName,
    this.workerId,
    this.workerName,
    this.lastMessage,
    this.lastMessageAt,
    required this.unreadCount,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json["id"],
      participantEmail: json["participant_email"],
      participantName: json["participant_name"],
      workerId: json["worker_id"],
      workerName: json["worker_name"],
      lastMessage: json["last_message"],
      lastMessageAt: json["last_message_at"] != null
          ? DateTime.parse(json["last_message_at"]).toLocal()
          : null,
      unreadCount: json["unread_count"] ?? 0,
    );
  }
}

class ConversationDetailModel {
  final int id;
  final String participantEmail;
  final String participantName;
  final int? workerId;
  final String? workerName;
  final List<MessageModel> messages;

  ConversationDetailModel({
    required this.id,
    required this.participantEmail,
    required this.participantName,
    this.workerId,
    this.workerName,
    required this.messages,
  });

  factory ConversationDetailModel.fromJson(Map<String, dynamic> json) {
    return ConversationDetailModel(
      id: json["id"],
      participantEmail: json["participant_email"],
      participantName: json["participant_name"],
      workerId: json["worker_id"],
      workerName: json["worker_name"],
      messages: (json["messages"] as List<dynamic>? ?? [])
          .map((item) => MessageModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
