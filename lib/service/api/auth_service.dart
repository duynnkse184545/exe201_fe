import 'package:dio/dio.dart';
import 'base/api_client.dart';
import 'dto/auth_request.dart';
import 'dto/auth_response.dart'; // Your ApiClient singleton

class AuthService {
  final Dio _dio = ApiClient().dio;

  Future<AuthResponse> login(AuthRequest request) async {
    try {
      final response = await _dio.post(
        '/api/controller/login',
        data: request.toJson(),
      );

      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Login failed: ${e.response?.data ?? e.message}');
    }
  }
}
