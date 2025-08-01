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
  
  // Get events for a specific date range
  Future<List<Event>> getEventsForDateRange(DateTime startDate, DateTime endDate) async {
    try {
      print('Fetching events from $startDate to $endDate');
      
      // For testing purposes, let's create mock events to ensure the UI works
      // Comment this out when the API is working
      // return [
      //   Event(
      //     eventId: '1',
      //     title: 'Team Meeting',
      //     startDateTime: DateTime.now(),
      //     endDateTime: DateTime.now().add(const Duration(hours: 1)),
      //     evCategoryId: '1',
      //     userId: 'current-user',
      //   ),
      //   Event(
      //     eventId: '2',
      //     title: 'Project Review',
      //     startDateTime: DateTime.now().add(const Duration(days: 2)),
      //     endDateTime: DateTime.now().add(const Duration(days: 2, hours: 1)),
      //     evCategoryId: '2',
      //     userId: 'current-user',
      //   ),
      // ];
      
      // Uncomment when API is ready
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
      //
    } catch (e) {
      print('Error fetching events for date range: $e');
      return [];
    }
  }
} 