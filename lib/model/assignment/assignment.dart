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
    required String status,
    required int priorityId,
    String? priorityName,
    String? priorityColorCode,
    required int estimatedTime,
    required String? subjectId,
    String? subjectName,
    required String userId,
  }) = _Assignment;

  factory Assignment.fromJson(Map<String, dynamic> json) =>
      _$AssignmentFromJson(json);
}

// Request model for creating and updating assignments
@freezed
abstract class AssignmentRequest with _$AssignmentRequest {
  const factory AssignmentRequest({
    required String title,
    String? description,
    required DateTime dueDate,
    required int priorityId,
    required int? estimatedTime,
  }) = _AssignmentRequest;

  factory AssignmentRequest.fromJson(Map<String, dynamic> json) => _$AssignmentRequestFromJson(json);
}