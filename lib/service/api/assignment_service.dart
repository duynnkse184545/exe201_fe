import '../../model/assignment.dart';
import 'base/generic_handler.dart';

class AssignmentService extends ApiService<Assignment, String> {
  AssignmentService() : super(endpoint: '/api/Assignment');

  @override
  Assignment fromJson(Map<String, dynamic> json) => Assignment.fromJson(json);

  @override
  Map<String, dynamic> toJson(dynamic data) {
    if (data is Assignment) return data.toJson();
    if (data is Map<String, dynamic>) return data;
    throw ArgumentError('Unsupported data type for toJson: ${data.runtimeType}');
  }
  
  Future<Assignment> updateAssignment(Map<String, dynamic> payload) async {
    return update<Map<String, dynamic>>(payload);
  }
  
  // Get upcoming assignments with a specific due date
  Future<List<Assignment>> getUpcomingAssignments(DateTime dueDate) async {
    try {
      print('Fetching assignments due before $dueDate');
      final response = await dio.get(
        '$endpoint/upcoming',
        queryParameters: {
          'dueDate': dueDate.toIso8601String(),
        },
      );
      print('Assignment API response: ${response.data}');
      final List<dynamic> dataList = response.data['data'];
      return dataList.map((e) => fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error fetching upcoming assignments: $e');
      return [];
    }
  }
} 
