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
  
  // Get upcoming assignments with a specific due date
  Future<List<Assignment>> getUpcomingAssignments(DateTime dueDate) async {
    try {
      print('Fetching assignments due before $dueDate');
      
      // For testing purposes, let's create mock assignments to ensure the UI works
      // Comment this out when the API is working
      // return [
      //   Assignment(
      //     assignmentId: '1',
      //     title: 'API Design Project',
      //     dueDate: DateTime.now().add(const Duration(days: 15)),
      //     status: 'in_progress',
      //     priorityId: 1,
      //     subjectId: '1',
      //     subjectName: 'Subject API Design',
      //     userId: 'current-user',
      //     estimatedTime: 36,
      //   ),
      //   Assignment(
      //     assignmentId: '2',
      //     title: 'Database Implementation',
      //     dueDate: DateTime.now().add(const Duration(days: 5)),
      //     status: 'not_started',
      //     priorityId: 2,
      //     subjectId: '2',
      //     subjectName: 'Database Systems',
      //     userId: 'current-user',
      //     estimatedTime: 20,
      //   ),
      // ];
      
      // Uncomment when API is ready
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