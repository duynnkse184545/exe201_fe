import 'package:dio/dio.dart';
import 'package:exe201/service/api/base/generic_handler.dart';
import '../../model/models.dart';
import '../api/base/api_client.dart';

class MonthlySummaryService extends ApiService<MonthlySummary, String>{
    MonthlySummaryService() : super(endpoint: '/api/enhanced-financial-dashboard/enhanced-monthly-summary');

    @override
    MonthlySummary fromJson(Map<String, dynamic> json) => MonthlySummary.fromJson(json);

    @override
    Map<String, dynamic> toJson(dynamic data) {
      if (data is MonthlySummary) return data.toJson();
      throw ArgumentError(
          'Unsupported data type for toJson: ${data.runtimeType}');
    }

  Future<MonthlySummary> getMonthlySummary(int year, int month) async {
    try {
      final response = await dio.get('/api/enhanced-financial-dashboard/enhanced-monthly-summary', queryParameters: {
        'year': year,
        'month': month,
      });

      if (response.data['isSuccess'] == true) {
        // Manual construction to handle the enhanced budget structure
        final responseData = response.data['data'] as Map<String, dynamic>;
        return MonthlySummary.fromJson(responseData);
      } else {
        throw Exception('API Error: ${response.data['message'] ?? 'Unknown error'}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to get monthly summary: ${_formatError(e)}');
    }
  }

  String _formatError(DioException e) {
    if (e.response != null) {
      final statusCode = e.response!.statusCode;
      final responseData = e.response!.data;

      if (statusCode == 400) {
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
      return e.message ?? 'Network error';
    }
  }
}