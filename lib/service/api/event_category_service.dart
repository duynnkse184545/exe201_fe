import '../../model/event_category.dart';
import 'base/generic_handler.dart';

class EventCategoryService extends ApiService<EventCategory, String> {
  EventCategoryService() : super(endpoint: '/api/EventCategory');

  @override
  EventCategory fromJson(Map<String, dynamic> json) => EventCategory.fromJson(json);

  @override
  Map<String, dynamic> toJson(dynamic data) {
    if (data is EventCategory) return data.toJson();
    if (data is Map<String, dynamic>) return data;
    throw ArgumentError('Unsupported data type for toJson: ${data.runtimeType}');
  }
} 