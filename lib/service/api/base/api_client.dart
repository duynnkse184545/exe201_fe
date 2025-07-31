import 'package:dio/dio.dart';
import '../../storage/token_storage.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late Dio dio;
  final TokenStorage _tokenStorage = TokenStorage();

  factory ApiClient() => _instance;

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: 'http://10.0.2.2:5134/',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // Add request interceptor to include authorization header
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStorage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            await handleUnauthorized();
          }
          handler.next(error);
        },
      ),
    );
  }

  Future<void> handleUnauthorized() async {
    // Clear the stored token
    print('ApiClient.handleUnauthorized() - Clearing token due to 401 error');
    await _tokenStorage.clearToken();
    
    // You can add additional logic here like:
    // - Navigate to login screen
    // - Show unauthorized message
    // - Trigger app-wide logout state
    print('Unauthorized access detected. Token cleared.');
  }
}
