class Job {
  final int id;
  final String title;
  final String category;
  final String description;
  final String location;
  final String phone;
  final String? latitude;
  final String? longitude;
  final String? userEmail;
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
    this.userEmail,
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
      String? normalizeString(dynamic value) {
        if (value == null) return null;
        final v = value.toString().trim();
        if (v.isEmpty) return null;
        final lower = v.toLowerCase();
        if (lower == 'null' || lower == 'undefined' || lower == '0') return null;
        return v;
      }

      int? readInt(dynamic value) {
        if (value == null) return null;
        if (value is int) return value;
        if (value is num) return value.toInt();
        if (value is String) return int.tryParse(value);
        return null;
      }

      String formatMoney(int value) => value.toString();

      String? buildSalary(dynamic value) {
        final direct = normalizeString(value);
        if (direct != null) return direct;

        final min =
            readInt(json["min_salary"] ?? json["salary_min"] ?? json["minSalary"]);
        final max =
            readInt(json["max_salary"] ?? json["salary_max"] ?? json["maxSalary"]);

        if (min == null && max == null) return null;
        if (min != null && max != null) {
          return "₹${formatMoney(min)} - ₹${formatMoney(max)}";
        }
        if (min != null) return "₹${formatMoney(min)}";
        return "₹${formatMoney(max!)}";
      }

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
        userEmail: json["user_email"]?.toString(),
        verified: json["is_verified"] == true || json["verified"] == true,
        urgent: json["urgent"] == true,
        salary: buildSalary(
          json["salary"] ??
              json["salary_range"] ??
              json["pay"] ??
              json["payment"],
        ),
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
