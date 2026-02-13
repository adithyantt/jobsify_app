class Notification {
  final int id;
  final String userEmail;
  final String title;
  final String message;
  final String? type; // job, worker, report, account
  final int? referenceId; // ID of related content
  final bool isRead;
  final DateTime createdAt;

  Notification({
    required this.id,
    required this.userEmail,
    required this.title,
    required this.message,
    this.type,
    this.referenceId,
    required this.isRead,
    required this.createdAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'],
      userEmail: json['user_email'],
      title: json['title'],
      message: json['message'],
      type: json['type'],
      referenceId: json['reference_id'],
      isRead: json['is_read'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
