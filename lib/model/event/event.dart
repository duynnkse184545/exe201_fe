import 'package:freezed_annotation/freezed_annotation.dart';

part 'event.freezed.dart';
part 'event.g.dart';

@freezed
abstract class Event with _$Event {
  const factory Event({
    required String eventId,
    required String title,
    String? description,
    required DateTime startDateTime,
    required DateTime endDateTime,
    String? recurrencePattern,
    DateTime? recurrenceEndDate,
    required String evCategoryId,
    String? categoryName,
    required String userId,
    @Default(false) bool isRecurring,
    String? originalEventId,
    DateTime? occurrenceDate,
  }) = _Event;

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);
}

// Request model for creating and updating events
@freezed
abstract class EventRequest with _$EventRequest {
  const factory EventRequest({
    required String title,
    String? description,
    required DateTime startDateTime,
    required DateTime endDateTime,
    String? recurrencePattern,
    DateTime? recurrenceEndDate,
  }) = _EventRequest;

  factory EventRequest.fromJson(Map<String, dynamic> json) => _$EventRequestFromJson(json);
}