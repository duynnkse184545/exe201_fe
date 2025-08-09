import 'package:dio/dio.dart';
import 'base/generic_handler.dart';
import '../../model/user/user.dart';
import 'dto/auth_response.dart';
import '../storage/token_storage.dart';

class UserService extends ApiService<User, String> {
  UserService() : super(endpoint: '/api/User');
  final TokenStorage _tokenStorage = TokenStorage();

  @override
  User fromJson(Map<String, dynamic> json) => User.fromJson(json);

  @override
  Map<String, dynamic> toJson(dynamic data) {
    if (data is User) return data.toJson();
    if (data is UserRequest) return data.toJson();
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

  // Email verification methods with simple parameters and debug logging
  Future<String> verifyEmail(String email, String code) async {
    try {
      final url = '$endpoint/verify';
      final requestData = {
        'email': email,
        'code': code,
      };
      
      print('DEBUG - Verify Email Request:');
      print('URL: $url');
      print('Data: $requestData');
      
      final response = await dio.post(url, data: requestData);
      
      print('DEBUG - Verify Email Response:');
      print('Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');
      
      return response.data['message'] ?? 'Email verified successfully';
    } catch (e) {
      print('DEBUG - Verify Email Error:');
      print('Error: $e');
      if (e is DioException) {
        print('Status Code: ${e.response?.statusCode}');
        print('Response Data: ${e.response?.data}');
        print('Request URL: ${e.requestOptions.uri}');
        print('Request Data: ${e.requestOptions.data}');
      }
      throw Exception('Email verification failed: $e');
    }
  }

  Future<String> resendVerificationCode(String email) async {
    try {
      final url = '$endpoint/resend-verification';
      final requestData = {
        'email': email,
      };
      
      print('DEBUG - Resend Verification Request:');
      print('URL: $url');
      print('Data: $requestData');
      
      final response = await dio.post(url, data: requestData);
      
      print('DEBUG - Resend Verification Response:');
      print('Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');
      
      return response.data['message'] ?? 'Verification code sent successfully';
    } catch (e) {
      print('DEBUG - Resend Verification Error:');
      print('Error: $e');
      if (e is DioException) {
        print('Status Code: ${e.response?.statusCode}');
        print('Response Data: ${e.response?.data}');
        print('Request URL: ${e.requestOptions.uri}');
        print('Request Data: ${e.requestOptions.data}');
      }
      throw Exception('Resend verification failed: $e');
    }
  }

  Future<String> sendForgotPasswordCode(String email) async {
    try {
      final url = '$endpoint/forgot-password/send-code';
      final requestData = {
        'email': email,
      };
      
      print('DEBUG - Send Forgot Password Code Request:');
      print('URL: $url');
      print('Data: $requestData');
      
      final response = await dio.post(url, data: requestData);
      
      print('DEBUG - Send Forgot Password Code Response:');
      print('Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');
      
      return response.data['message'] ?? 'Verification code sent to your email';
    } catch (e) {
      print('DEBUG - Send Forgot Password Code Error:');
      print('Error: $e');
      if (e is DioException) {
        print('Status Code: ${e.response?.statusCode}');
        print('Response Data: ${e.response?.data}');
        print('Request URL: ${e.requestOptions.uri}');
        print('Request Data: ${e.requestOptions.data}');
      }
      throw Exception('Send forgot password code failed: $e');
    }
  }

  Future<String> resetPasswordWithCode(String email, String code, String newPassword) async {
    try {
      final url = '$endpoint/forgot-password/reset';
      final requestData = {
        'email': email,
        'code': code,
        'newPassword': newPassword,
      };
      
      print('DEBUG - Reset Password With Code Request:');
      print('URL: $url');
      print('Data: $requestData');
      
      final response = await dio.post(url, data: requestData);
      
      print('DEBUG - Reset Password With Code Response:');
      print('Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');
      
      return response.data['message'] ?? 'Password reset successfully';
    } catch (e) {
      print('DEBUG - Reset Password With Code Error:');
      print('Error: $e');
      if (e is DioException) {
        print('Status Code: ${e.response?.statusCode}');
        print('Response Data: ${e.response?.data}');
        print('Request URL: ${e.requestOptions.uri}');
        print('Request Data: ${e.requestOptions.data}');
      }
      throw Exception('Reset password with code failed: $e');
    }
  }

  Future<AuthResponse> loginWithGoogle(String idToken) async {
    try {
      final url = '$endpoint/login-google';
      final requestData = {'idToken': idToken};
      
      print('DEBUG - Google Login Request:');
      print('URL: $url');
      print('Data: $requestData');
      
      final response = await dio.post(url, data: requestData);
      
      print('DEBUG - Google Login Response:');
      print('Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');

      final authResponse = AuthResponse.fromJson(response.data);

      if (authResponse.token.isNotEmpty) {
        await _tokenStorage.saveToken(authResponse.token);
      }
      
      return authResponse;
    } catch (e) {
      print('DEBUG - Google Login Error:');
      print('Error: $e');
      if (e is DioException) {
        print('Status Code: ${e.response?.statusCode}');
        print('Response Data: ${e.response?.data}');
        print('Request URL: ${e.requestOptions.uri}');
        print('Request Data: ${e.requestOptions.data}');
      }
      throw Exception('Google login failed: $e');
    }
  }
}