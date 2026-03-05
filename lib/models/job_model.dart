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

  // New fields
  final int requiredWorkers;
  final int hiredCount;
  final bool isHidden;
  final int vacancies;

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
    this.requiredWorkers = 1,
    this.hiredCount = 0,
    this.isHidden = false,
    this.vacancies = 1,
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

      // Parse new fields with defaults
      int requiredWorkers = 1;
      if (json["required_workers"] != null) {
        if (json["required_workers"] is int) {
          requiredWorkers = json["required_workers"];
        } else if (json["required_workers"] is String) {
          requiredWorkers = int.tryParse(json["required_workers"]) ?? 1;
        }
      }

      int hiredCount = 0;
      if (json["hired_count"] != null) {
        if (json["hired_count"] is int) {
          hiredCount = json["hired_count"];
        } else if (json["hired_count"] is String) {
          hiredCount = int.tryParse(json["hired_count"]) ?? 0;
        }
      }

      bool isHidden = false;
      if (json["is_hidden"] != null) {
        isHidden = json["is_hidden"] == true;
      }

      int vacancies = 1;
      if (json["vacancies"] != null) {
        if (json["vacancies"] is int) {
          vacancies = json["vacancies"];
        } else if (json["vacancies"] is String) {
          vacancies = int.tryParse(json["vacancies"]) ?? 1;
        }
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
        requiredWorkers: requiredWorkers,
        hiredCount: hiredCount,
        isHidden: isHidden,
        vacancies: vacancies,
      );
    } catch (e) {
      throw FormatException("Failed to parse Job from JSON: $e, data: $json");
    }
  }
}
