class PriorityLevel {
  final int? priorityId;
  final String? levelName;
  final String? colorCode;

  PriorityLevel({
    this.priorityId,
    required this.levelName,
    required this.colorCode,
  });

  factory PriorityLevel.fromJson(Map<String, dynamic> json) {
    return PriorityLevel(
      priorityId: json['priorityId'],
      levelName: json['levelName'],
      colorCode: json['colorCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'priorityId': priorityId,
      'levelName': levelName,
      'colorCode': colorCode,
    };
  }
}