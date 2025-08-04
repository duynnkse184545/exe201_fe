import 'package:freezed_annotation/freezed_annotation.dart';

part 'event_category.freezed.dart';
part 'event_category.g.dart';

@freezed
abstract class EventCategory with _$EventCategory {
  const factory EventCategory({
    required String evCategoryId,
    required String categoryName,
    String? description,
    required String userId,
  }) = _EventCategory;

  factory EventCategory.fromJson(Map<String, dynamic> json) =>
      _$EventCategoryFromJson(json);
}