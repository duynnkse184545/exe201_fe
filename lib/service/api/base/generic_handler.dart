import 'package:dio/dio.dart';
import 'api_client.dart';

class ApiService<T, ID> {
  final Dio _dio = ApiClient().dio;

  final String endpoint;
  final T Function(Map<String, dynamic>) fromJson;

  ApiService({required this.endpoint, required this.fromJson});

  Future<List<T>> getAll() async {
    try {
      final response = await _dio.get(endpoint);
      return (response.data as List).map((e) => fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception('GET failed: ${_formatError(e)}');
    }
  }

  Future<T> getById(ID id) async {
    try {
      final response = await _dio.get('$endpoint/$id');
      return fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('GET by ID failed: ${_formatError(e)}');
    }
  }

  Future<T> create(Map<String, dynamic> data) async {
    try {
      // Add debug logging
      print('Creating with data: $data');
      print('Endpoint: $endpoint');

      final response = await _dio.post(endpoint, data: data);
      print('Response: ${response.data}');
      return fromJson(response.data);
    } on DioException catch (e) {
      // Enhanced error logging for debugging
      print('POST Error Details:');
      print('Status Code: ${e.response?.statusCode}');
      print('Response Data: ${e.response?.data}');
      print('Request Data: $data');

      throw Exception('POST failed: ${_formatError(e)}');
    }
  }

  Future<T> update(ID id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('$endpoint/$id', data: data);
      return fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('PUT failed: ${_formatError(e)}');
    }
  }

  Future<void> delete(ID id) async {
    try {
      await _dio.delete('$endpoint/$id');
    } on DioException catch (e) {
      throw Exception('DELETE failed: ${_formatError(e)}');
    }
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