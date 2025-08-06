import '../../model/models.dart';
import 'base/generic_handler.dart';
import 'base/id_generator.dart';

class AssignmentService extends ApiService<Assignment, String> {
  AssignmentService() : super(endpoint: '/api/Assignment');

  @override
  Assignment fromJson(Map<String, dynamic> json) => Assignment.fromJson(json);

  @override
  Map<String, dynamic> toJson(dynamic data) {
    if (data is Assignment) return data.toJson();
    if (data is AssignmentRequest) return data.toJson();
    if (data is Map<String, dynamic>) return data;
    throw ArgumentError('Unsupported data type for toJson: ${data.runtimeType}');
  }
  
  // Get all assignments (inherited method with domain-specific wrapper)
  Future<List<Assignment>> getAllAssignments() async {
    try {
      return await getAll();
    } catch (e) {
      throw Exception('Failed to get assignments: $e');
    }
  }


  // Create assignment from request
  Future<Assignment> createAssignmentFromRequest(AssignmentRequest request) async {
    try {
      return await create<AssignmentRequest>(request);
    } catch (e) {
      throw Exception('Failed to create assignment from request: $e');
    }
  }

  // Update assignment (inherited method with domain-specific wrapper)
  Future<Assignment> updateAssignment(AssignmentRequest updates) async {
    try {
      return await update<AssignmentRequest>(updates);
    } catch (e) {
      throw Exception('Failed to update assignment: $e');
    }
  }

  // Update assignment with map payload (legacy support)
  Future<Assignment> updateAssignmentWithMap(Map<String, dynamic> payload) async {
    return update<Map<String, dynamic>>(payload);
  }

  // Delete assignment (inherited method)
  // Future<void> delete(String assignmentId) is inherited

  // Get assignments for a specific user
  Future<List<Assignment>> getUserAssignments(String userId) async {
    try {
      final allAssignments = await getAllAssignments();
      return allAssignments.where((assignment) => assignment.userId == userId).toList();
    } catch (e) {
      throw Exception('Failed to get user assignments: $e');
    }
  }

  // Get assignments for a specific subject
  Future<List<Assignment>> getAssignmentsBySubject(String subjectId) async {
    try {
      final allAssignments = await getAllAssignments();
      return allAssignments.where((assignment) => assignment.subjectId == subjectId).toList();
    } catch (e) {
      throw Exception('Failed to get assignments by subject: $e');
    }
  }

  // Get assignments by status
  Future<List<Assignment>> getAssignmentsByStatus(String status, String userId) async {
    try {
      final userAssignments = await getUserAssignments(userId);
      return userAssignments.where((assignment) => assignment.status == status).toList();
    } catch (e) {
      throw Exception('Failed to get assignments by status: $e');
    }
  }

  // Get assignments by priority
  Future<List<Assignment>> getAssignmentsByPriority(int priorityId, String userId) async {
    try {
      final userAssignments = await getUserAssignments(userId);
      return userAssignments.where((assignment) => assignment.priorityId == priorityId).toList();
    } catch (e) {
      throw Exception('Failed to get assignments by priority: $e');
    }
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

  // Get assignments due within a date range
  Future<List<Assignment>> getAssignmentsForDateRange(DateTime startDate, DateTime endDate, String userId) async {
    try {
      final userAssignments = await getUserAssignments(userId);
      return userAssignments.where((assignment) => 
        assignment.dueDate.isAfter(startDate) && 
        assignment.dueDate.isBefore(endDate)
      ).toList()..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    } catch (e) {
      throw Exception('Failed to get assignments for date range: $e');
    }
  }

  // Get assignments due on a specific date
  Future<List<Assignment>> getAssignmentsForDate(DateTime date, String userId) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
      
      final userAssignments = await getUserAssignments(userId);
      return userAssignments.where((assignment) => 
        assignment.dueDate.isAfter(startOfDay) && 
        assignment.dueDate.isBefore(endOfDay)
      ).toList();
    } catch (e) {
      throw Exception('Failed to get assignments for date: $e');
    }
  }

  // Get overdue assignments
  Future<List<Assignment>> getOverdueAssignments(String userId) async {
    try {
      final now = DateTime.now();
      final userAssignments = await getUserAssignments(userId);
      return userAssignments.where((assignment) => 
        assignment.dueDate.isBefore(now) && 
        assignment.status != 'completed'
      ).toList()..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    } catch (e) {
      throw Exception('Failed to get overdue assignments: $e');
    }
  }

  // Get completed assignments
  Future<List<Assignment>> getCompletedAssignments(String userId) async {
    try {
      return await getAssignmentsByStatus('completed', userId);
    } catch (e) {
      throw Exception('Failed to get completed assignments: $e');
    }
  }

  // Get pending assignments
  Future<List<Assignment>> getPendingAssignments(String userId) async {
    try {
      return await getAssignmentsByStatus('pending', userId);
    } catch (e) {
      throw Exception('Failed to get pending assignments: $e');
    }
  }

  // Mark assignment as completed
  Future<Assignment> markAsCompleted(String assignmentId) async {
    try {
      final completedData = {
        'assignmentId': assignmentId,
        'status': 'completed',
        'completedDate': DateTime.now().toIso8601String(),
      };
      return await updateById<Map<String, dynamic>>(assignmentId, completedData);
    } catch (e) {
      throw Exception('Failed to mark assignment as completed: $e');
    }
  }

  // Update assignment status
  Future<Assignment> updateAssignmentStatus(String assignmentId, String status) async {
    try {
      final statusData = {
        'assignmentId': assignmentId,
        'status': status,
        if (status == 'completed') 'completedDate': DateTime.now().toIso8601String(),
      };
      return await updateById<Map<String, dynamic>>(assignmentId, statusData);
    } catch (e) {
      throw Exception('Failed to update assignment status: $e');
    }
  }

  // Search assignments by title
  Future<List<Assignment>> searchAssignments(String searchTerm, String userId) async {
    try {
      final userAssignments = await getUserAssignments(userId);
      return userAssignments
          .where((assignment) => 
            assignment.title.toLowerCase().contains(searchTerm.toLowerCase()) ||
            (assignment.description?.toLowerCase().contains(searchTerm.toLowerCase()) ?? false))
          .toList();
    } catch (e) {
      throw Exception('Failed to search assignments: $e');
    }
  }

  // Get assignments with estimated time
  Future<List<Assignment>> getAssignmentsWithEstimatedTime(String userId) async {
    try {
      final userAssignments = await getUserAssignments(userId);
      return userAssignments.where((assignment) => assignment.estimatedTime != null && assignment.estimatedTime! > 0).toList();
    } catch (e) {
      throw Exception('Failed to get assignments with estimated time: $e');
    }
  }

  // Get total estimated time for pending assignments
  Future<int> getTotalEstimatedTime(String userId) async {
    try {
      final pendingAssignments = await getPendingAssignments(userId);
      int totalTime = 0;
      for (final assignment in pendingAssignments) {
        totalTime += assignment.estimatedTime ?? 0;
      }
      return totalTime;
    } catch (e) {
      throw Exception('Failed to get total estimated time: $e');
    }
  }
} 
