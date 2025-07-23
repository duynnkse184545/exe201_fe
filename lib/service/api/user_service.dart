import 'base/generic_handler.dart';
import '../../model/user.dart';

class UserService {
  late final ApiService<User, String> _apiService;

  UserService() {
    _apiService = ApiService<User, String>(
      endpoint: '/api/User',
      fromJson: (json) => User.fromJson(json),
      toJson: (user) => user.toJson(),
    );
  }

  // Create new user
  Future<User> createUser(User user) async {
    try {
      return await _apiService.create(user);
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  // Get user by ID
  Future<User> getUserById(String userId) async {
    try {
      return await _apiService.getById(userId);
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  // Update user
  Future<User> updateUser(String userId, Map<String, dynamic> updates) async {
    try {
      return await _apiService.updateById<Map<String, dynamic>>(userId, updates);
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  // Delete user
  Future<void> deleteUser(String userId) async {
    try {
      await _apiService.delete(userId);
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }
}