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
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json["id"],
      title: json["title"],
      category: json["category"],
      description: json["description"],
      location: json["location"],
      phone: json["phone"],
      latitude: json["latitude"],
      longitude: json["longitude"],
      verified: json["is_verified"] ?? false,
    );
  }
}
