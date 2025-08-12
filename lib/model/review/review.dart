import 'package:freezed_annotation/freezed_annotation.dart';

part 'review.freezed.dart';
part 'review.g.dart';

@freezed
abstract class Review with _$Review {
  const factory Review({
    required String reviewId,
    required String userId,
    required int rating,
    required String comment,
    required DateTime createdAt,
    required DateTime updatedAt,
    User? user,
  }) = _Review;

  factory Review.fromJson(Map<String, dynamic> json) =>
      _$ReviewFromJson(json);
}

@freezed
abstract class ReviewRequest with _$ReviewRequest {
  const factory ReviewRequest({
    required int rating,
    required String comment,
  }) = _ReviewRequest;

  factory ReviewRequest.fromJson(Map<String, dynamic> json) =>
      _$ReviewRequestFromJson(json);
}

@freezed
abstract class User with _$User {
  const factory User({
    required String userId,
    required String email,
    required String fullName,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) =>
      _$UserFromJson(json);
}