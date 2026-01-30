class Job {
  final int? id;
  final String title;
  final String category;
  final String location;
  final String? description;
  final String phone; // ✅ ADD THIS

  Job({
    this.id,
    required this.title,
    required this.category,
    required this.location,
    this.description,
    required this.phone, // ✅ ADD THIS
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'],
      title: json['title'],
      category: json['category'],
      location: json['location'],
      description: json['description'],
      phone: json['phone'],
    );
  }
}
