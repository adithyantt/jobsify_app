class MessageModel {
  final int id;
  final int conversationId;
  final String senderEmail;
  final String recipientEmail;
  final String content;
  final bool isRead;
  final DateTime createdAt;

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderEmail,
    required this.recipientEmail,
    required this.content,
    required this.isRead,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json["id"],
      conversationId: json["conversation_id"],
      senderEmail: json["sender_email"],
      recipientEmail: json["recipient_email"],
      content: json["content"],
      isRead: json["is_read"] ?? false,
      createdAt: DateTime.parse(json["created_at"]).toLocal(),
    );
  }
}
