class Worker {
  final int id;
  final String? firstName;
  final String? lastName;
  final String name;
  final String role;
  final String phone;
  final int experience;
  final String location;
  final String? latitude;
  final String? longitude;
  final String? userEmail;
  final bool isVerified;
  final bool isAvailable;
  final String? availabilityType; // everyday | selected_days | not_available
  final String? availableDays; // Comma-separated: "Mon,Tue,Wed"
  final double? rating;
  final int? reviews;
  final bool isOwner;
  final bool canMessage;

  Worker({
    required this.id,
    this.firstName,
    this.lastName,
    required this.name,
    required this.role,
    required this.phone,
    required this.experience,
    required this.location,
    this.latitude,
    this.longitude,
    this.userEmail,
    required this.isVerified,
    required this.isAvailable,
    this.availabilityType,
    this.availableDays,
    this.rating,
    this.reviews,
    this.isOwner = false,
    this.canMessage = true,
  });

  factory Worker.fromJson(Map<String, dynamic> json) {
    bool? parseBool(dynamic value) {
      if (value == null) return null;
      if (value is bool) return value;
      if (value is num) return value != 0;
      if (value is String) {
        final v = value.trim().toLowerCase();
        if (v == 'true' || v == '1' || v == 'yes') return true;
        if (v == 'false' || v == '0' || v == 'no') return false;
      }
      return null;
    }

    String? parseString(dynamic value) {
      if (value == null) return null;
      final v = value.toString().trim();
      if (v.isEmpty || v.toLowerCase() == 'null') return null;
      return v;
    }

    final firstName = parseString(json["first_name"]);
    final lastName = parseString(json["last_name"]);
    final nameValue =
        parseString(json["name"]) ??
        [firstName, lastName].where((v) => v != null && v.isNotEmpty).join(' ');

    final availabilityType = parseString(
      json["availability_type"] ??
          json["availabilityType"] ??
          json["availability"],
    );

    String? availableDays;
    final daysRaw = json["available_days"] ?? json["availableDays"];
    if (daysRaw is List) {
      availableDays = daysRaw.map((d) => d.toString().trim()).join(',');
    } else {
      availableDays = parseString(daysRaw);
    }

    final parsedIsAvailable = parseBool(
      json["is_available"] ?? json["isAvailable"],
    );
    final resolvedIsAvailable =
        parsedIsAvailable ??
        (availabilityType == 'not_available' ? false : true);

    return Worker(
      id: json["id"],
      firstName: firstName,
      lastName: lastName,
      name: nameValue.isNotEmpty ? nameValue : "Worker",
      role: json["role"],
      phone: json["phone"],
      experience: json["experience"],
      location: json["location"],
      latitude: json["latitude"],
      longitude: json["longitude"],
      userEmail: json["user_email"],
      isVerified: json["is_verified"] ?? false,
      isAvailable: resolvedIsAvailable,
      availabilityType: availabilityType,
      availableDays: availableDays,
      rating: json["rating"] != null
          ? (json["rating"] as num).toDouble()
          : null,
      reviews: json["reviews"],
      isOwner: json["is_owner"] ?? false,
      canMessage: json["can_message"] ?? true,
    );
  }
}
