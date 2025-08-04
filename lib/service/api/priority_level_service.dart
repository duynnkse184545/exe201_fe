import '../../model/priority_level.dart';
import 'base/generic_handler.dart';

class PriorityLevelService extends ApiService<PriorityLevel, int> {
  PriorityLevelService() : super(endpoint: '/api/PriorityLevel');

  @override
  PriorityLevel fromJson(Map<String, dynamic> json) => PriorityLevel.fromJson(json);

  @override
  Map<String, dynamic> toJson(dynamic data) {
    if (data is PriorityLevel) return {
      'priorityId': data.priorityId,
      'levelName': data.levelName,
      'colorCode': data.colorCode,
    };
    if (data is Map<String, dynamic>) return data;
    throw ArgumentError('Unsupported data type for toJson: ${data.runtimeType}');
  }
}
