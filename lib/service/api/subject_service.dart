import '../../model/subject.dart';
import 'base/generic_handler.dart';

class SubjectService extends ApiService<Subject, String> {
  SubjectService() : super(endpoint: '/api/Subject');

  @override
  Subject fromJson(Map<String, dynamic> json) => Subject.fromJson(json);

  @override
  Map<String, dynamic> toJson(dynamic data) {
    if (data is Subject) return data.toJson();
    if (data is Map<String, dynamic>) return data;
    throw ArgumentError('Unsupported data type for toJson: ${data.runtimeType}');
  }
} 