import 'package:dio/dio.dart';
import 'base/api_client.dart';

class AIServiceApi {
  final Dio _dio = ApiClient().dio;

  Future<Map<String, dynamic>> generateOptions(String message) async {
    final resp = await _dio.post('/api/ai/generate-options', data: {
      'message': message,
      'conversationId': null,
    });
    return resp.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createSelected(Map<String, dynamic> option, {String? conversationId}) async {
    final payload = {
      'selectedOption': option,
      'conversationId': conversationId,
    };
    final resp = await _dio.post('/api/ai/create-selected', data: payload);
    return resp.data as Map<String, dynamic>;
  }
}
