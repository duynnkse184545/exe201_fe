
import 'dart:convert';
import 'package:exe201/model/membership_plan.dart';
import 'package:http/http.dart' as http;


class MembershipPlanService {
  static const String baseUrl = 'http://exe202.runasp.net/api';
  static const String endpoint = '/MembershipPlan';

  // Get all membership plans
  Future<ApiResponse<List<MembershipPlan>>> getAllPlans() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(
        Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        
        // Handle different response structures
        List<dynamic> plansData;
        
        if (jsonResponse is Map<String, dynamic>) {
          // If response has wrapper structure
          if (jsonResponse.containsKey('data')) {
            plansData = jsonResponse['data'] as List<dynamic>;
          } else if (jsonResponse.containsKey('result')) {
            plansData = jsonResponse['result'] as List<dynamic>;
          } else {
            // If the whole response is the data
            plansData = [jsonResponse];
          }
        } else if (jsonResponse is List) {
          // If response is directly a list
          plansData = jsonResponse;
        } else {
          throw Exception('Unexpected response format');
        }

        List<MembershipPlan> plans = plansData
            .map((planJson) => MembershipPlan.fromJson(planJson))
            .toList();

        return ApiResponse<List<MembershipPlan>>(
          success: true,
          code: response.statusCode,
          message: 'Success',
          data: plans,
        );
      } else {
        // Handle error response
        String errorMessage = 'Failed to load plans';
        
        try {
          final errorJson = json.decode(response.body);
          errorMessage = errorJson['message'] ?? errorJson['error'] ?? errorMessage;
        } catch (e) {
          // If response body is not JSON, use status code message
          errorMessage = 'HTTP ${response.statusCode}: ${response.reasonPhrase}';
        }

        return ApiResponse<List<MembershipPlan>>(
          success: false,
          code: response.statusCode,
          message: errorMessage,
          data: null,
        );
      }
    } catch (e) {
      print('API Error: $e');
      return ApiResponse<List<MembershipPlan>>(
        success: false,
        code: 500,
        message: 'Network error: ${e.toString()}',
        data: null,
      );
    }
  }

  // Get plan by ID (if needed)
  Future<ApiResponse<MembershipPlan>> getPlanById(String planId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint/$planId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        
        MembershipPlan plan;
        if (jsonResponse is Map<String, dynamic>) {
          if (jsonResponse.containsKey('data')) {
            plan = MembershipPlan.fromJson(jsonResponse['data']);
          } else {
            plan = MembershipPlan.fromJson(jsonResponse);
          }
        } else {
          throw Exception('Unexpected response format');
        }

        return ApiResponse<MembershipPlan>(
          success: true,
          code: response.statusCode,
          message: 'Success',
          data: plan,
        );
      } else {
        String errorMessage = 'Failed to load plan';
        
        try {
          final errorJson = json.decode(response.body);
          errorMessage = errorJson['message'] ?? errorJson['error'] ?? errorMessage;
        } catch (e) {
          errorMessage = 'HTTP ${response.statusCode}: ${response.reasonPhrase}';
        }

        return ApiResponse<MembershipPlan>(
          success: false,
          code: response.statusCode,
          message: errorMessage,
          data: null,
        );
      }
    } catch (e) {
      return ApiResponse<MembershipPlan>(
        success: false,
        code: 500,
        message: 'Network error: ${e.toString()}',
        data: null,
      );
    }
  }
}

// models/api_response.dart
class ApiResponse<T> {
  final bool success;
  final int code;
  final String? message;
  final T? data;

  ApiResponse({
    required this.success,
    required this.code,
    this.message,
    this.data,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? (json['code'] >= 200 && json['code'] < 300),
      code: json['code'] ?? json['statusCode'] ?? 200,
      message: json['message'] ?? json['msg'],
      data: json['data'] != null && fromJsonT != null 
          ? fromJsonT(json['data']) 
          : json['data'] as T?,
    );
  }

  // For list responses
  factory ApiResponse.fromJsonList(
    Map<String, dynamic> json,
    T Function(List<dynamic>)? fromJsonList,
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? (json['code'] >= 200 && json['code'] < 300),
      code: json['code'] ?? json['statusCode'] ?? 200,
      message: json['message'] ?? json['msg'],
      data: json['data'] != null && fromJsonList != null 
          ? fromJsonList(json['data'] as List<dynamic>) 
          : json['data'] as T?,
    );
  }
}