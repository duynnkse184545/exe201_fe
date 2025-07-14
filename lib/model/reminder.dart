class Reminder {
  String reminderId;
  DateTime reminderTime;
  String status;
  String notificationChannel;
  String? eventId;
  String? assignmentId;
  String? userId;
  String? templateId;

  Reminder({
    required this.reminderId,
    required this.reminderTime,
    required this.status,
    required this.notificationChannel,
    this.eventId,
    this.assignmentId,
    this.userId,
    this.templateId,
  });

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      reminderId: json['reminderId'],
      reminderTime: DateTime.parse(json['reminderTime']),
      status: json['status'],
      notificationChannel: json['notificationChannel'],
      eventId: json['eventId'],
      assignmentId: json['assignmentId'],
      userId: json['userId'],
      templateId: json['templateId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reminderId': reminderId,
      'reminderTime': reminderTime.toIso8601String(),
      'status': status,
      'notificationChannel': notificationChannel,
      'eventId': eventId,
      'assignmentId': assignmentId,
      'userId': userId,
      'templateId': templateId,
    };
  }
}