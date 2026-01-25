class Job {
  final int id;
  final String title;
  final String category;
  final String location;
  final String? description;

  Job({
    required this.id,
    required this.title,
    required this.category,
    required this.location,
    this.description,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'],
      title: json['title'],
      category: json['category'],
      location: json['location'],
      description: json['description'],
    );
  }
}
