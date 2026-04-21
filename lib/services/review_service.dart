import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/review_model.dart';
import '../utils/api_endpoints.dart';
import 'user_session.dart';

export '../services/connectivity_service.dart' show NoInternetException;

class ReviewService {
  // Get all reviews for a worker
  static Future<List<Review>> getWorkerReviews(int workerId) async {
    // Removed strict connectivity check - now tries API + catches real HTTP errors
    try {
      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}/reviews/worker/$workerId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        List<dynamic> data;

        if (decoded is List) {
          data = decoded;
        } else if (decoded is Map &&
            (decoded.containsKey("reviews") || decoded.containsKey("data"))) {
          data = decoded["reviews"] ?? decoded["data"];
        } else {
          return [];
        }

        return data
            .map((json) => Review.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to load reviews: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching reviews: $e');
    }
  }

  // Get worker rating summary
  static Future<WorkerRatingSummary> getWorkerRatingSummary(
    int workerId,
  ) async {
    // Removed strict connectivity check - now tries API + catches real HTTP errors
    try {
      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}/reviews/worker/$workerId/summary'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return WorkerRatingSummary.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load rating summary: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching rating summary: $e');
    }
  }

  // Add a review (requires authentication)
  static Future<Review> addReview(
    int workerId,
    int rating,
    String? comment,
  ) async {
    if (rating < 1 || rating > 5) {
      throw Exception('Rating must be between 1 and 5');
    }
    // Removed strict connectivity check - now tries API + catches real HTTP errors
    try {
      final headers = {'Content-Type': 'application/json'};
      if (UserSession.safeToken != null) {
        headers['Authorization'] = 'Bearer ${UserSession.safeToken}';
      } else if (UserSession.isLoggedIn && UserSession.email != null) {
        headers['X-User-Email'] = UserSession.email!;
      } else {
        throw Exception('Please login to add review');
      }

      final response = await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}/reviews'),
        headers: headers,
        body: jsonEncode({
          'worker_id': workerId,
          'reviewer_email': UserSession.email!,
          'rating': rating,
          'comment': comment,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Review.fromJson(jsonDecode(response.body));
      } else {
        final error = jsonDecode(response.body);
        throw Exception(
          error['detail'] ??
              'Failed to add review (HTTP ${response.statusCode})',
        );
      }
    } catch (e) {
      throw Exception('Error adding review: $e');
    }
  }

  // Update a review (requires authentication)
  static Future<Review> updateReview(
    int reviewId,
    int rating,
    String? comment,
  ) async {
    // Removed strict connectivity check - now tries API + catches real HTTP errors
    try {
      if (!UserSession.isLoggedIn) {
        throw Exception('Please login to update review');
      }

      final headers = {'Content-Type': 'application/json'};
      if (UserSession.safeToken != null) {
        headers['Authorization'] = 'Bearer ${UserSession.safeToken}';
      } else if (UserSession.isLoggedIn && UserSession.email != null) {
        headers['X-User-Email'] = UserSession.email!;
      } else {
        throw Exception('Please login to update review');
      }

      final response = await http.put(
        Uri.parse('${ApiEndpoints.baseUrl}/reviews/$reviewId'),
        headers: headers,
        body: jsonEncode({
          'reviewer_email': UserSession.email!,
          'rating': rating,
          'comment': comment,
        }),
      );

      if (response.statusCode == 200) {
        return Review.fromJson(jsonDecode(response.body));
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to update review');
      }
    } catch (e) {
      throw Exception('Error updating review: $e');
    }
  }

  // Delete a review (requires authentication)
  static Future<void> deleteReview(int reviewId) async {
    // Removed strict connectivity check - now tries API + catches real HTTP errors
    try {
      if (!UserSession.isLoggedIn) {
        throw Exception('Please login to delete review');
      }

      final headers = {'Content-Type': 'application/json'};
      if (UserSession.safeToken != null) {
        headers['Authorization'] = 'Bearer ${UserSession.safeToken}';
      } else if (UserSession.isLoggedIn && UserSession.email != null) {
        headers['X-User-Email'] = UserSession.email!;
      } else {
        throw Exception('Please login to perform this action');
      }

      final response = await http.delete(
        Uri.parse(
          '${ApiEndpoints.baseUrl}/reviews/$reviewId?reviewer_email=${Uri.encodeComponent(UserSession.email!)}',
        ),
        headers: headers,
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to delete review');
      }
    } catch (e) {
      throw Exception('Error deleting review: $e');
    }
  }

  // Get my reviews (requires authentication)
  static Future<List<Review>> getMyReviews() async {
    // Removed strict connectivity check - now tries API + catches real HTTP errors
    try {
      if (!UserSession.isLoggedIn) {
        throw Exception('Please login to view your reviews');
      }

      final headers = {'Content-Type': 'application/json'};
      if (UserSession.safeToken != null) {
        headers['Authorization'] = 'Bearer ${UserSession.safeToken}';
      } else {
        headers['X-User-Email'] = UserSession.email!;
      }

      final response = await http.get(
        Uri.parse(
          '${ApiEndpoints.baseUrl}/reviews/my?reviewer_email=${Uri.encodeComponent(UserSession.email!)}',
        ),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        List<dynamic> data;

        if (decoded is List) {
          data = decoded;
        } else if (decoded is Map &&
            (decoded.containsKey("reviews") || decoded.containsKey("data"))) {
          data = decoded["reviews"] ?? decoded["data"];
        } else {
          return [];
        }

        return data
            .map((json) => Review.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to load your reviews: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching your reviews: $e');
    }
  }

  // Check if user has already reviewed a worker
  static Future<Review?> getUserReviewForWorker(int workerId) async {
    try {
      final myReviews = await getMyReviews();
      for (var review in myReviews) {
        if (review.workerId == workerId) {
          return review;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
