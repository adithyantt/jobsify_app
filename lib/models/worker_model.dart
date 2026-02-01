class Worker {
  final int id;
  final String name;
  final String role;
  final String phone;
  final int experience;
  final double rating;
  final int reviews;
  final String location;
  final bool isAvailable;
  final bool isVerified;

  Worker({
    required this.id,
    required this.name,
    required this.role,
    required this.phone,
    required this.experience,
    required this.rating,
    required this.reviews,
    required this.location,
    required this.isAvailable,
    required this.isVerified,
  });

  factory Worker.fromJson(Map<String, dynamic> json) {
    return Worker(
      id: json['id'],
      name: json['name'],
      role: json['role'],
      phone: json['phone'],
      experience: json['experience'] ?? 0,
      rating: (json['rating'] ?? 0).toDouble(),
      reviews: json['reviews'] ?? 0,
      location: json['location'] ?? "",
      isAvailable: json['is_available'] ?? true,
      isVerified: json['is_verified'] ?? false,
    );
  }
}
