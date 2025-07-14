class Goal {
  final String? goalId;
  final String? goalName;
  final String? description;
  final DateTime? targetDate;
  final String? status;
  final String? userId;

  Goal({
    this.goalId,
    required this.goalName,
    this.description,
    this.targetDate,
    required this.status,
    required this.userId,
  });

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      goalId: json['goalId'],
      goalName: json['goalName'],
      description: json['description'],
      targetDate: json['targetDate'] != null ? DateTime.parse(json['targetDate']) : null,
      status: json['status'],
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'goalId': goalId,
      'goalName': goalName,
      'description': description,
      'targetDate': targetDate?.toIso8601String(),
      'status': status,
      'userId': userId,
    };
  }
}