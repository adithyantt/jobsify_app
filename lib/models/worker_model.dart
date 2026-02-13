class Worker {
  final int id;
  final String name;
  final String role;
  final String phone;
  final int experience;
  final String location;
  final String? latitude;
  final String? longitude;
  final bool isVerified;
  final bool isAvailable;
  final String? availabilityType; // everyday | selected_days | not_available
  final String? availableDays; // Comma-separated: "Mon,Tue,Wed"
  final double? rating;
  final int? reviews;

  Worker({
    required this.id,
    required this.name,
    required this.role,
    required this.phone,
    required this.experience,
    required this.location,
    this.latitude,
    this.longitude,
    required this.isVerified,
    required this.isAvailable,
    this.availabilityType,
    this.availableDays,
    this.rating,
    this.reviews,
  });

  factory Worker.fromJson(Map<String, dynamic> json) {
    return Worker(
      id: json["id"],
      name: json["name"],
      role: json["role"],
      phone: json["phone"],
      experience: json["experience"],
      location: json["location"],
      latitude: json["latitude"],
      longitude: json["longitude"],
      isVerified: json["is_verified"] ?? false,
      isAvailable: json["is_available"] ?? true,
      availabilityType: json["availability_type"],
      availableDays: json["available_days"],
      rating: json["rating"] != null
          ? (json["rating"] as num).toDouble()
          : null,
      reviews: json["reviews"],
    );
  }
}
