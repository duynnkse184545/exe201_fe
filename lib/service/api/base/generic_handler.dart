import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'api_client.dart';

abstract class ApiService<T, ID> {
  final Dio dio = ApiClient().dio;
  final String endpoint;

  ApiService({required this.endpoint});

  T fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson(dynamic data);

  Future<List<T>> getAll() async {
    try {
      final response = await dio.get(endpoint);
      final List<dynamic> dataList = response.data['data'];
      return dataList.map((e) => fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw Exception('GET failed: ${_formatError(e)}');
    } catch (e) {
      debugPrint(e.toString());
      throw Exception('Failed to parse response: $e');
    }
  }

  Future<T> getById(ID id) async {
    try {
      final response = await dio.get('$endpoint/$id');
      final Map<String, dynamic> responseMap = response.data as Map<String, dynamic>;
      debugPrint(responseMap.toString());
      if (responseMap['isSuccess'] == true) {
        return fromJson(responseMap['data'] as Map<String, dynamic>);
      } else {
        throw Exception('API Error: ${responseMap['message'] ?? 'Unknown error'}');
      }
    } on DioException catch (e) {
      throw Exception('GET by ID failed: ${_formatError(e)}');
    }
  }

  Future<T> create<TRequest>(TRequest data, {String? customPath}) async {
    final path = customPath != null? '$endpoint/$customPath' : endpoint;
    try {
      print('path $path');
      final jsonData = toJson(data);
      debugPrint(jsonData.toString());
      final response = await dio.post(path, data: jsonData);
      print('Response: ${response.data['data']}');
      return fromJson(response.data['data']);
    } on DioException catch (e) {
      // Enhanced error logging for debugging
      print('POST Error Details:');
      print('Status Code: ${e.response?.statusCode}');
      print('Response Data: ${e.response?.data}');
      print('Request Data: $data');

      throw Exception('POST failed: ${_formatError(e)}');
    }
  }

  Future<T> update<TRequest>(TRequest data) async {
    try {
      final jsonData = toJson(data);
      final response = await dio.put(endpoint, data: jsonData);
      return fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception('PUT failed: ${_formatError(e)}');
    }
  }

  Future<T> updateById<TRequest>(ID id, TRequest data) async {
    try {
      final jsonData = toJson(data);
      final response = await dio.put('$endpoint/$id', data: jsonData);
      return fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception('PUT failed: ${_formatError(e)}');
    }
  }

  Future<void> delete(ID id) async {
    try {
      await dio.delete('$endpoint/$id');
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