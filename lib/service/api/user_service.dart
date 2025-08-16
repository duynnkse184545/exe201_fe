import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:io';
import 'base/generic_handler.dart';
import '../../model/user/user.dart';
import 'dto/auth_response.dart';
import '../storage/token_storage.dart';

class UserService extends ApiService<User, String> {
  UserService() : super(endpoint: '/api/User');
  final TokenStorage _tokenStorage = TokenStorage();

  @override
  User fromJson(Map<String, dynamic> json) => User.fromJson(json);

  @override
  Map<String, dynamic> toJson(dynamic data) {
    if (data is User) return data.toJson();
    if (data is UserRequest) return data.toJson();
    if (data is Map<String, dynamic>) return data;
    throw ArgumentError('Unsupported data type for toJson: ${data.runtimeType}');
  }

  // Create new user (inherited method with domain-specific wrapper)
  Future<User> createUser(UserRequest user) async {
    try {
      return await create(user, customPath: 'create-user');
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  Future<User> updateUser(UserRequest updates) async {
    try {
      var formData = FormData();

      if (updates.userId != null) {
        formData.fields.add(MapEntry('userId', updates.userId!));
      }
      if (updates.fullName != null) {
        formData.fields.add(MapEntry('fullName', updates.fullName!));
      }
      if (updates.email != null) {
        formData.fields.add(MapEntry('email', updates.email!));
      }
      if (updates.doB != null) {
        formData.fields.add(MapEntry('doB', updates.doB!.toIso8601String()));
      }
      if (updates.img != null) {
        formData.files.add(MapEntry(
            'img',
            await MultipartFile.fromFile(
              updates.img!.path,
              filename: updates.img!.path.split('/').last,
              contentType: MediaType('image', 'jpeg'),
        )));
      }
      print('formData ${formData}');
      // Now you can use the generic update method with FormData
      return await update(formData, customPath: 'update-account');
    } catch (e) {
      print(e.toString());
      throw Exception('Failed to update user: $e');
    }
  }


  Future<User> getUserData() async {
    try {
      final response = await dio.get('$endpoint/logged-in-user');
      print('rara: ${response.data['data']}');
      return fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to get user by email: $e');
    }
  }

  Future<List<User>> getAllUsers() async {
    try {
      return await getAll();
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }
  /// Get user by ID (available in backend)
  Future<User> getUserById(String userId) async {
    try {
      final response = await dio.get('$endpoint/$userId');
      return fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e, stackTrace) {
      print('ERROR: Failed in getUserById: $e');
      print('ERROR: Stack trace: $stackTrace');
      throw Exception('Failed to get user by ID: $e');
    }
  }

  /// Calculate user statistics from invoice data (since invoices contain userId)
  Future<Map<String, dynamic>> calculateUserStatisticsFromInvoices() async {
    try {
      // Get all invoices to extract user information
      final response = await dio.get('/api/Invoice');
      final List<dynamic> invoiceList = response.data['data'];
      
      if (invoiceList.isEmpty) {
        return {
          'totalUsers': 0,
          'activeUsers': 0,
          'newUsersThisMonth': 0,
          'userGrowthPercentage': 0.0,
        };
      }

      // Extract unique user IDs from invoices
      final Set<String> uniqueUserIds = {};
      final Set<String> activeUserIds = {}; // Users with invoices in last 30 days
      final Set<String> newUsersThisMonth = {}; // Users with first invoice this month
      final Map<String, DateTime> userFirstInvoice = {};

      final now = DateTime.now();
      final thirtyDaysAgo = now.subtract(const Duration(days: 30));
      final currentMonth = now.month;
      final currentYear = now.year;

      for (final invoiceData in invoiceList) {
        final userId = invoiceData['userId'] as String?;
        final createdDateStr = invoiceData['createdDate'] as String?;
        
        if (userId != null && createdDateStr != null) {
          uniqueUserIds.add(userId);
          final createdDate = DateTime.parse(createdDateStr);
          
          // Track first invoice date for each user
          if (!userFirstInvoice.containsKey(userId) || 
              createdDate.isBefore(userFirstInvoice[userId]!)) {
            userFirstInvoice[userId] = createdDate;
          }
          
          // Active users (invoices in last 30 days)
          if (createdDate.isAfter(thirtyDaysAgo)) {
            activeUserIds.add(userId);
          }
          
          // New users this month (first invoice this month)
          if (createdDate.month == currentMonth && createdDate.year == currentYear) {
            final firstInvoice = userFirstInvoice[userId]!;
            if (firstInvoice.month == currentMonth && firstInvoice.year == currentYear) {
              newUsersThisMonth.add(userId);
            }
          }
        }
      }

      // Calculate growth percentage (mock calculation)
      final growthPercentage = newUsersThisMonth.isNotEmpty ?
          (newUsersThisMonth.length / uniqueUserIds.length * 100) : 0.0;

      return {
        'totalUsers': uniqueUserIds.length,
        'activeUsers': activeUserIds.length,
        'newUsersThisMonth': newUsersThisMonth.length,
        'userGrowthPercentage': growthPercentage,
      };
    } catch (e) {
      print('ERROR: Failed to calculate user statistics: $e');
      return {
        'totalUsers': 0,
        'activeUsers': 0,
        'newUsersThisMonth': 0,
        'userGrowthPercentage': 0.0,
      };
    }
  }

  /// Calculate user growth data from invoice data
  Future<List<Map<String, dynamic>>> calculateUserGrowthFromInvoices() async {
    try {
      final response = await dio.get('/api/Invoice');
      final List<dynamic> invoiceList = response.data['data'];
      
      // Track first invoice date for each user by month
      final Map<String, DateTime> userFirstInvoice = {};
      final Map<int, Set<String>> newUsersByMonth = {};

      // Initialize months
      for (int i = 1; i <= 12; i++) {
        newUsersByMonth[i] = <String>{};
      }

      for (final invoiceData in invoiceList) {
        final userId = invoiceData['userId'] as String?;
        final createdDateStr = invoiceData['createdDate'] as String?;
        
        if (userId != null && createdDateStr != null) {
          final createdDate = DateTime.parse(createdDateStr);
          
          // Track first invoice date for each user
          if (!userFirstInvoice.containsKey(userId) || 
              createdDate.isBefore(userFirstInvoice[userId]!)) {
            userFirstInvoice[userId] = createdDate;
          }
        }
      }

      // Count new users by month based on first invoice
      for (final firstInvoiceDate in userFirstInvoice.values) {
        final month = firstInvoiceDate.month;
        final userId = userFirstInvoice.entries
            .firstWhere((entry) => entry.value == firstInvoiceDate)
            .key;
        newUsersByMonth[month]?.add(userId);
      }

      // Generate cumulative user count
      int cumulativeUsers = 0;
      return List.generate(12, (index) {
        final month = index + 1;
        cumulativeUsers += newUsersByMonth[month]?.length ?? 0;
        return {
          'month': month,
          'users': cumulativeUsers,
        };
      });
    } catch (e) {
      print('ERROR: Failed to calculate user growth: $e');
      return List.generate(12, (index) => {
        'month': index + 1,
        'users': 0,
      });
    }
  }


  // Email verification methods with simple parameters and debug logging
  Future<String> verifyEmail(String email, String code) async {
    try {
      final url = '$endpoint/verify';
      final requestData = {
        'email': email,
        'code': code,
      };

      print('DEBUG - Verify Email Request:');
      print('URL: $url');
      print('Data: $requestData');

      final response = await dio.post(url, data: requestData);

      print('DEBUG - Verify Email Response:');
      print('Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');

      return response.data['message'] ?? 'Email verified successfully';
    } catch (e) {
      print('DEBUG - Verify Email Error:');
      print('Error: $e');
      if (e is DioException) {
        print('Status Code: ${e.response?.statusCode}');
        print('Response Data: ${e.response?.data}');
        print('Request URL: ${e.requestOptions.uri}');
        print('Request Data: ${e.requestOptions.data}');
      }
      throw Exception('Email verification failed: $e');
    }
  }

  Future<String> resendVerificationCode(String email) async {
    try {
      final url = '$endpoint/resend-verification';
      final requestData = {
        'email': email,
      };

      print('DEBUG - Resend Verification Request:');
      print('URL: $url');
      print('Data: $requestData');

      final response = await dio.post(url, data: requestData);

      print('DEBUG - Resend Verification Response:');
      print('Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');

      return response.data['message'] ?? 'Verification code sent successfully';
    } catch (e) {
      print('DEBUG - Resend Verification Error:');
      print('Error: $e');
      if (e is DioException) {
        print('Status Code: ${e.response?.statusCode}');
        print('Response Data: ${e.response?.data}');
        print('Request URL: ${e.requestOptions.uri}');
        print('Request Data: ${e.requestOptions.data}');
      }
      throw Exception('Resend verification failed: $e');
    }
  }

  Future<String> sendForgotPasswordCode(String email) async {
    try {
      final url = '$endpoint/forgot-password/send-code';
      final requestData = {
        'email': email,
      };

      print('DEBUG - Send Forgot Password Code Request:');
      print('URL: $url');
      print('Data: $requestData');

      final response = await dio.post(url, data: requestData);

      print('DEBUG - Send Forgot Password Code Response:');
      print('Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');

      return response.data['message'] ?? 'Verification code sent to your email';
    } catch (e) {
      print('DEBUG - Send Forgot Password Code Error:');
      print('Error: $e');
      if (e is DioException) {
        print('Status Code: ${e.response?.statusCode}');
        print('Response Data: ${e.response?.data}');
        print('Request URL: ${e.requestOptions.uri}');
        print('Request Data: ${e.requestOptions.data}');
      }
      throw Exception('Send forgot password code failed: $e');
    }
  }

  Future<String> resetPasswordWithCode(String email, String code, String newPassword) async {
    try {
      final url = '$endpoint/forgot-password/reset';
      final requestData = {
        'email': email,
        'code': code,
        'newPassword': newPassword,
      };

      print('DEBUG - Reset Password With Code Request:');
      print('URL: $url');
      print('Data: $requestData');

      final response = await dio.post(url, data: requestData);

      print('DEBUG - Reset Password With Code Response:');
      print('Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');

      return response.data['message'] ?? 'Password reset successfully';
    } catch (e) {
      print('DEBUG - Reset Password With Code Error:');
      print('Error: $e');
      if (e is DioException) {
        print('Status Code: ${e.response?.statusCode}');
        print('Response Data: ${e.response?.data}');
        print('Request URL: ${e.requestOptions.uri}');
        print('Request Data: ${e.requestOptions.data}');
      }
      throw Exception('Reset password with code failed: $e');
    }
  }

  Future<AuthResponse> loginWithGoogle(String idToken) async {
    try {
      final url = '$endpoint/login-google';
      final requestData = {'idToken': idToken};

      print('DEBUG - Google Login Request:');
      print('URL: $url');
      print('Data: $requestData');

      final response = await dio.post(url, data: requestData);

      print('DEBUG - Google Login Response:');
      print('Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');

      final authResponse = AuthResponse.fromJson(response.data);

      if (authResponse.token.isNotEmpty) {
        await _tokenStorage.saveToken(authResponse.token);
      }

      return authResponse;
    } catch (e) {
      print('DEBUG - Google Login Error:');
      print('Error: $e');
      if (e is DioException) {
        print('Status Code: ${e.response?.statusCode}');
        print('Response Data: ${e.response?.data}');
        print('Request URL: ${e.requestOptions.uri}');
        print('Request Data: ${e.requestOptions.data}');
      }
      throw Exception('Google login failed: $e');
    }
  }
}