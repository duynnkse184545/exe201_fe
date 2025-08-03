import '../../model/event.dart';
import 'base/generic_handler.dart';

class EventService extends ApiService<Event, String> {
  EventService() : super(endpoint: '/api/Event');

  @override
  Event fromJson(Map<String, dynamic> json) => Event.fromJson(json);

  @override
  Map<String, dynamic> toJson(dynamic data) {
    if (data is Event) return data.toJson();
    if (data is Map<String, dynamic>) return data;
    throw ArgumentError('Unsupported data type for toJson: ${data.runtimeType}');
  }
  
  Future<Event> updateEvent(Map<String, dynamic> payload) async {
    return update<Map<String, dynamic>>(payload);
  }
  
  // Get events for a specific date range
  Future<List<Event>> getEventsForDateRange(DateTime startDate, DateTime endDate) async {
    try {
      print('Fetching events from $startDate to $endDate');
      final response = await dio.get(
        '$endpoint/upcoming',
        queryParameters: {
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
        },
      );
      print('Event API response: ${response.data}');
      final List<dynamic> dataList = response.data['data'];
      return dataList.map((e) => fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error fetching events for date range: $e');
      return [];
    }
  }
} 
