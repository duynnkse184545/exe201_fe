import 'package:dio/dio.dart';
import 'dto/auth_request.dart';
import 'dto/auth_response.dart';
import 'exceptions/auth_exceptions.dart';
import '../storage/token_storage.dart';
import '../google_sign_in_service.dart';
import 'base/api_client.dart';

class AuthService {
  final Dio dio = ApiClient().dio;
  final TokenStorage _tokenStorage = TokenStorage();

  Future<AuthResponse> login(AuthRequest request) async {
    try {
      final response = await dio.post(
        '/api/controller/login',
        data: request.toJson(),
      );

      final authResponse = AuthResponse.fromJson(response.data);

      if (authResponse.token.isNotEmpty) {
        await _tokenStorage.saveToken(authResponse.token);
      }
      
      return authResponse;
    } on DioException catch (e) {
      final errorMessage = _formatError(e);
      
      // Check if the error indicates unverified email
      if (errorMessage.contains('You do not have access!') || 
          errorMessage.contains('not verified') ||
          errorMessage.contains('verify')) {
        throw UnverifiedEmailException('Email verification required', request.username);
      }
      
      throw Exception('Login failed: $errorMessage');
    }
  }

  Future<void> logout() async {
    try {
      // Sign out from Google Sign-In first
      await GoogleSignInService.signOut();
    } catch (e) {
      // Continue even if Google Sign-In logout fails
      print('Google Sign-In logout failed: $e');
    }
    
    // Always clear local token storage
    await _tokenStorage.clearToken();
  }

  String _formatError(DioException e) {
    if (e.response != null) {
      // Server responded with an error status
      final statusCode = e.response!.statusCode;
      final responseData = e.response!.data;

      if (statusCode == 400) {
        // Bad Request - often contains validation errors
        if (responseData is Map) {
          return 'Bad Request (400): ${responseData.toString()}';
        } else if (responseData is String) {
          return 'Bad Request (400): $responseData';
        } else {
          return 'Bad Request (400): Invalid request data';
        }
      }

      return 'HTTP $statusCode: ${responseData ?? e.message}';
    } else {
      // Network error or no response
      return e.message ?? 'Network error';
    }
  }
}
