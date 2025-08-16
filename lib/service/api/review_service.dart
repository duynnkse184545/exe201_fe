import 'base/generic_handler.dart';
import '../../model/review/review.dart';

class ReviewService extends ApiService<Review, String> {
  ReviewService() : super(endpoint: '/api/Review');

  @override
  Review fromJson(Map<String, dynamic> json) => Review.fromJson(json);

  @override
  Map<String, dynamic> toJson(dynamic data) {
    if (data is Review) return data.toJson();
    if (data is ReviewRequest) return data.toJson();
    if (data is Map<String, dynamic>) return data;
    throw ArgumentError('Unsupported data type for toJson: ${data.runtimeType}');
  }

  // Create new review/feedback
  Future<Review> createReview(ReviewRequest reviewRequest) async {
    try {
      return await create(reviewRequest, customPath: 'create');
    } catch (e) {
      throw Exception('Failed to create review: $e');
    }
  }

  // Get all reviews (admin/public)
  Future<List<Review>> getAllReviews() async {
    try {
      return await getAll(customPath: 'all');
    } catch (e) {
      throw Exception('Failed to get all reviews: $e');
    }
  }

  // Get user's reviews
  Future<List<Review>> getUserReviews() async {
    try {
      final response = await dio.get('$endpoint/user');
      final List<dynamic> dataList = response.data['data'];
      return dataList.map((e) => fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
      throw Exception('Failed to get user reviews: $e');
    }
  }

  // Update review
  Future<Review> updateReview(String reviewId, ReviewRequest reviewRequest) async {
    try {
      return await updateById(reviewId, reviewRequest);
    } catch (e) {
      throw Exception('Failed to update review: $e');
    }
  }

  // Delete review
  Future<void> deleteReview(String reviewId) async {
    try {
      await delete(reviewId);
    } catch (e) {
      throw Exception('Failed to delete review: $e');
    }
  }
}