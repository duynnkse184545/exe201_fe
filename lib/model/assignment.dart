class Assignment{
  final String? assignmentId;
  final String? title;
  final String? description;
  final DateTime? dueDate;
  final DateTime? completedDate;
  final String? status;
  final int priorityId;
  final int? estimatedTime;
  final String? subjectId;
  final String? userId;

  Assignment({
    this.assignmentId,
    required this.title,
    required this.description,
    this.dueDate,
    this.completedDate,
    required this.status,
    required this.priorityId,
    this.estimatedTime,
    this.subjectId,
    this.userId,
  });

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      assignmentId: json['assignmentId'],
      title: json['title'],
      description: json['description'],
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      completedDate: json['completedDate'] != null ? DateTime.parse(json['completedDate']) : null,
      status: json['status'],
      priorityId: json['priorityId'],
      estimatedTime: json['estimatedTime'],
      subjectId: json['subjectId'],
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'assignmentId': assignmentId,
      'title': title,
      'description': description,
      'dueDate': dueDate?.toIso8601String(),
      'completedDate': completedDate?.toIso8601String(),
      'status': status,
      'priorityId': priorityId,
      'estimatedTime': estimatedTime,
      'subjectId': subjectId,
      'userId': userId,
    };
  }
}