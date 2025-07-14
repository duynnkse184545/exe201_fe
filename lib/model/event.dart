class Event {
  final String? eventId;
  final String? title;
  final DateTime? startDateTime;
  final DateTime? endDateTime;
  final String? description;
  final String? recurrencePattern;
  final DateTime? recurrenceEndDate;
  final String? evCategoryId;
  final String? userId;

  Event({
    this.eventId,
    required this.title,
    required this.startDateTime,
    required this.endDateTime,
    this.description,
    this.recurrencePattern,
    this.recurrenceEndDate,
    required this.evCategoryId,
    required this.userId,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      eventId: json['eventId'],
      title: json['title'],
      startDateTime: json['startDateTime'] != null ? DateTime.parse(json['startDateTime']) : null,
      endDateTime: json['endDateTime'] != null ? DateTime.parse(json['endDateTime']) : null,
      description: json['description'],
      recurrencePattern: json['recurrencePattern'],
      recurrenceEndDate: json['recurrenceEndDate'] != null ? DateTime.parse(json['recurrenceEndDate']) : null,
      evCategoryId: json['evCategoryId'],
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'title': title,
      'startDateTime': startDateTime?.toIso8601String(),
      'endDateTime': endDateTime?.toIso8601String(),
      'description': description,
      'recurrencePattern': recurrencePattern,
      'recurrenceEndDate': recurrenceEndDate?.toIso8601String(),
      'evCategoryId': evCategoryId,
      'userId': userId,
    };
  }
}