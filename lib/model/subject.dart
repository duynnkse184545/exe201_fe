class Subject {
  String subjectId;
  String subjectName;
  String? description;

  Subject({
    required this.subjectId,
    required this.subjectName,
    this.description,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      subjectId: json['subjectId'],
      subjectName: json['subjectName'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subjectId': subjectId,
      'subjectName': subjectName,
      'description': description,
    };
  }
}