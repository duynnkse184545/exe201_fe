import 'base/generic_handler.dart';
import '../../model/user/user.dart';

class UserService extends ApiService<User, String> {
  UserService() : super(endpoint: '/api/User');

  @override
  User fromJson(Map<String, dynamic> json) => User.fromJson(json);

  @override
  Map<String, dynamic> toJson(dynamic data) {
    if (data is User) return data.toJson();
    if (data is Map<String, dynamic>) return data;
    throw ArgumentError('Unsupported data type for toJson: ${data.runtimeType}');
  }

  // Create new user (inherited method with domain-specific wrapper)
  Future<User> createUser(UserRequest user) async {
    try {
      return await create(user, customPath: 'create-user');
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  // Get user by ID (inherited method)
  // Future<User> getById(String userId) is inherited

  // Update user (inherited method with domain-specific wrapper)
  Future<User> updateUser(String userId, Map<String, dynamic> updates) async {
    try {
      return await updateById<Map<String, dynamic>>(userId, updates);
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  // Delete user (inherited method)
  // Future<void> delete(String userId) is inherited

  // Get user by email (domain-specific method)
  Future<User?> getUserByEmail(String email) async {
    try {
      final response = await dio.get('$endpoint/email/$email');
      if (response.data != null) {
        return fromJson(response.data);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user by email: $e');
    }
  }

  // Update user profile (domain-specific method)
  Future<User> updateUserProfile(String userId, {
    String? displayName,
    String? email,
    String? phoneNumber,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (displayName != null) updates['displayName'] = displayName;
      if (email != null) updates['email'] = email;
      if (phoneNumber != null) updates['phoneNumber'] = phoneNumber;
      
      return await updateUser(userId, updates);
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }
}