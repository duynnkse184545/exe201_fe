import 'package:freezed_annotation/freezed_annotation.dart';

part 'assignment.freezed.dart';
part 'assignment.g.dart';

@freezed
abstract class Assignment with _$Assignment {
  const factory Assignment({
    required String assignmentId,
    required String title,
    String? description,
    required DateTime dueDate,
    DateTime? completedDate,
    required String status,
    required int priorityId,
    String? priorityName,
    String? priorityColorCode,
    int? estimatedTime,
    required String subjectId,
    String? subjectName,
    required String userId,
  }) = _Assignment;

  factory Assignment.fromJson(Map<String, dynamic> json) =>
      _$AssignmentFromJson(json);
}