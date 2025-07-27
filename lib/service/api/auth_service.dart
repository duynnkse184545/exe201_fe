import 'package:dio/dio.dart';
import 'base/api_client.dart';
import 'dto/auth_request.dart';
import 'dto/auth_response.dart';
import '../storage/token_storage.dart';

class AuthService {
  final Dio _dio = ApiClient().dio;
  final TokenStorage _tokenStorage = TokenStorage();

  Future<AuthResponse> login(AuthRequest request) async {
    try {
      final response = await _dio.post(
        '/api/controller/login',
        data: request.toJson(),
      );

      final authResponse = AuthResponse.fromJson(response.data);
      
      // Automatically save the token
      await _tokenStorage.saveToken(authResponse.token);
      
      return authResponse;
    } on DioException catch (e) {
      throw Exception('Login failed: ${e.response?.data ?? e.message}');
    }
  }

  Future<void> logout() async {
    await _tokenStorage.clearToken();
  }
}
