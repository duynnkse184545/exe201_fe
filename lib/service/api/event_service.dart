import '../../model/models.dart';
import 'base/generic_handler.dart';
import 'base/id_generator.dart';

class EventService extends ApiService<Event, String> {
  EventService() : super(endpoint: '/api/Event');

  @override
  Event fromJson(Map<String, dynamic> json) => Event.fromJson(json);

  @override
  Map<String, dynamic> toJson(dynamic data) {
    if (data is Event) return data.toJson();
    if (data is EventRequest) return data.toJson();
    if (data is Map<String, dynamic>) return data;
    throw ArgumentError('Unsupported data type for toJson: ${data.runtimeType}');
  }
  
  // Get all events (inherited method with domain-specific wrapper)
  Future<List<Event>> getAllEvents() async {
    try {
      return await getAll();
    } catch (e) {
      throw Exception('Failed to get events: $e');
    }
  }

  // Create event from request
  Future<Event> createEventFromRequest(EventRequest request) async {
    try {
      return await create<EventRequest>(request);
    } catch (e) {
      print(e.toString());
      throw Exception('Failed to create event from request: $e');
    }
  }

  // Update event (inherited method with domain-specific wrapper)
  Future<Event> updateEvent(EventRequest updates) async {
    try {
      return await update<EventRequest>(updates);
    } catch (e) {
      throw Exception('Failed to update event: $e');
    }
  }

  // Update event with map payload (legacy support)
  Future<Event> updateEventWithMap(Map<String, dynamic> payload) async {
    return update<Map<String, dynamic>>(payload);
  }

  // Delete event (inherited method)
  // Future<void> delete(String eventId) is inherited

  // Get events for a specific user
  Future<List<Event>> getUserEvents(String userId) async {
    try {
      final allEvents = await getAllEvents();
      return allEvents.where((event) => event.userId == userId).toList();
    } catch (e) {
      throw Exception('Failed to get user events: $e');
    }
  }

  // Get events for a specific category
  Future<List<Event>> getEventsByCategory(String categoryId) async {
    try {
      final allEvents = await getAllEvents();
      return allEvents.where((event) => event.evCategoryId == categoryId).toList();
    } catch (e) {
      throw Exception('Failed to get events by category: $e');
    }
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

  // Get events for a specific date
  Future<List<Event>> getEventsForDate(DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
      
      final userEvents = await getUserEvents('current_user_id'); // You might want to pass userId as parameter
      return userEvents.where((event) => 
        event.startDateTime.isAfter(startOfDay) && 
        event.startDateTime.isBefore(endOfDay)
      ).toList();
    } catch (e) {
      throw Exception('Failed to get events for date: $e');
    }
  }

  // Get upcoming events
  Future<List<Event>> getUpcomingEvents(String userId, {int days = 7}) async {
    try {
      final now = DateTime.now();
      final futureDate = now.add(Duration(days: days));
      
      final userEvents = await getUserEvents(userId);
      return userEvents.where((event) => 
        event.startDateTime.isAfter(now) && 
        event.startDateTime.isBefore(futureDate)
      ).toList()..sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
    } catch (e) {
      throw Exception('Failed to get upcoming events: $e');
    }
  }

  // Get recurring events
  Future<List<Event>> getRecurringEvents(String userId) async {
    try {
      final userEvents = await getUserEvents(userId);
      return userEvents.where((event) => event.isRecurring).toList();
    } catch (e) {
      throw Exception('Failed to get recurring events: $e');
    }
  }

  // Search events by title
  Future<List<Event>> searchEvents(String searchTerm, String userId) async {
    try {
      final userEvents = await getUserEvents(userId);
      return userEvents
          .where((event) => 
            event.title.toLowerCase().contains(searchTerm.toLowerCase()) ||
            (event.description?.toLowerCase().contains(searchTerm.toLowerCase()) ?? false))
          .toList();
    } catch (e) {
      throw Exception('Failed to search events: $e');
    }
  }
} 
