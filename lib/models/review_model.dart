class Review {
  final int id;
  final int workerId;
  final String reviewerEmail;
  final String? reviewerName;
  final int rating; // 1-5 stars
  final String? comment;
  final String? createdAt;

  Review({
    required this.id,
    required this.workerId,
    required this.reviewerEmail,
    this.reviewerName,
    required this.rating,
    this.comment,
    this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] ?? 0,
      workerId: json['worker_id'] ?? 0,
      reviewerEmail: json['reviewer_email'] ?? '',
      reviewerName: json['reviewer_name'],
      rating: json['rating'] ?? 0,
      comment: json['comment'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'worker_id': workerId, 'rating': rating, 'comment': comment};
  }

  // Helper to get formatted date
  String get formattedDate {
    if (createdAt == null) return 'Unknown date';
    try {
      final date = DateTime.parse(createdAt!);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return createdAt!;
    }
  }

  // Helper to get initials from reviewer name
  String get reviewerInitials {
    if (reviewerName != null && reviewerName!.isNotEmpty) {
      return reviewerName!.substring(0, 1).toUpperCase();
    }
    return reviewerEmail.substring(0, 1).toUpperCase();
  }
}

class WorkerRatingSummary {
  final double averageRating;
  final int totalReviews;
  final Map<String, int> ratingDistribution;

  WorkerRatingSummary({
    required this.averageRating,
    required this.totalReviews,
    required this.ratingDistribution,
  });

  factory WorkerRatingSummary.fromJson(Map<String, dynamic> json) {
    return WorkerRatingSummary(
      averageRating: (json['average_rating'] ?? 0.0).toDouble(),
      totalReviews: json['total_reviews'] ?? 0,
      ratingDistribution: Map<String, int>.from(
        json['rating_distribution'] ?? {},
      ),
    );
  }
}
