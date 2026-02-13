import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/review_model.dart';
import '../utils/api_config.dart';
import 'user_session.dart';

class ReviewService {
  // Get all reviews for a worker
  static Future<List<Review>> getWorkerReviews(int workerId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/reviews/worker/$workerId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Review.fromJson(json)).toList();
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
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/reviews/worker/$workerId/summary'),
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
    try {
      final token = UserSession.token;
      if (token == null) {
        throw Exception('Please login to add a review');
      }

      print('DEBUG: Adding review - workerId: $workerId, rating: $rating');
      print('DEBUG: Token: ${token.substring(0, 20)}...');

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/reviews'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'worker_id': workerId,
          'rating': rating,
          'comment': comment,
        }),
      );

      print('DEBUG: Response status: ${response.statusCode}');
      print('DEBUG: Response body: ${response.body}');

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
      print('DEBUG: Error in addReview: $e');
      throw Exception('Error adding review: $e');
    }
  }

  // Update a review (requires authentication)
  static Future<Review> updateReview(
    int reviewId,
    int rating,
    String? comment,
  ) async {
    try {
      final token = UserSession.token;
      if (token == null) {
        throw Exception('Please login to update review');
      }

      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/reviews/$reviewId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'worker_id': 0, // Not needed for update but required by schema
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
    try {
      final token = UserSession.token;
      if (token == null) {
        throw Exception('Please login to delete review');
      }

      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/reviews/$reviewId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
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
    try {
      final token = UserSession.token;
      if (token == null) {
        throw Exception('Please login to view your reviews');
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/reviews/my'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Review.fromJson(json)).toList();
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
