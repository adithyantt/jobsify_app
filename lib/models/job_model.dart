class Job {
  final int id;
  final String title;
  final String category;
  final String description;
  final String location;
  final String phone;
  final String? latitude;
  final String? longitude;
  final bool verified;
  final bool urgent;
  final String? salary;
  final String? createdAt;
  final bool isSaved;

  Job({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.location,
    required this.phone,
    this.latitude,
    this.longitude,
    required this.verified,
    this.urgent = false,
    this.salary,
    this.createdAt,
    this.isSaved = false,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    try {
      // Handle id as either int or string
      int jobId;
      if (json["id"] is int) {
        jobId = json["id"];
      } else if (json["id"] is String) {
        jobId = int.tryParse(json["id"]) ?? 0;
      } else {
        jobId = 0;
      }

      return Job(
        id: jobId,
        title: json["title"]?.toString() ?? "",
        category: json["category"]?.toString() ?? "",
        description: json["description"]?.toString() ?? "",
        location: json["location"]?.toString() ?? "",
        phone: json["phone"]?.toString() ?? "",
        latitude: json["latitude"]?.toString(),
        longitude: json["longitude"]?.toString(),
        verified: json["is_verified"] == true || json["verified"] == true,
        urgent: json["urgent"] == true,
        salary: json["salary"]?.toString(),
        createdAt: json["created_at"]?.toString(),
      );
    } catch (e) {
      throw FormatException("Failed to parse Job from JSON: $e, data: $json");
    }
  }
}
