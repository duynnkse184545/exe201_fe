import 'dart:convert';
import 'package:dio/dio.dart';
import 'dto/auth_request.dart';
import 'dto/auth_response.dart';
import '../storage/token_storage.dart';

class AuthService {
  final TokenStorage _tokenStorage = TokenStorage();

  Future<AuthResponse> login(AuthRequest request) async {
    final loginDio = Dio(
      BaseOptions(
        baseUrl: 'http://exe202.runasp.net/',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    try {
      final response = await loginDio.post(
        '/api/controller/login',
        data: jsonEncode(request.toJson()),
      );

      final authResponse = AuthResponse.fromJson(response.data);

      if (authResponse.token.isNotEmpty) {
        await _tokenStorage.saveToken(authResponse.token);
      }
      
      return authResponse;
    } on DioException catch (e) {
      throw Exception('Login failed: ${e.response?.data ?? e.message}');
    }
  }

  Future<void> logout() async {
    await _tokenStorage.clearToken();
  }
}
