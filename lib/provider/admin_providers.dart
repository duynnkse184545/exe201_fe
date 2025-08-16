import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../model/models.dart';
import 'service_providers.dart';

part 'admin_providers.g.dart';

// Base Users Provider - fetches all users once and caches them
@riverpod
class AdminUsersBaseNotifier extends _$AdminUsersBaseNotifier {
  @override
  Future<List<User>> build() async {
    final userService = ref.watch(userServiceProvider);

    try {
      final allUser = await userService.getAll();

      // Get current logged-in user ID to exclude from list
      final tokenStorage = ref.watch(tokenStorageProvider);
      final currentUserId = await tokenStorage.getUserId();

      // Filter out current user
      final filteredUsers = allUser.where((user) {
        // Exclude current logged-in user
        if (currentUserId != null && user.userId == currentUserId) {
          return false;
        }
        return true;
      }).toList();

      return filteredUsers;
    } catch (e) {
      print('Failed to load users: $e');
      throw e;
    }
  }

  Future<void> deleteUser(String userId) async {
    // Mock delete - in real implementation, use backend delete endpoint
    print('Mock: Deleting user $userId');
    ref.invalidateSelf();
  }
}

// Users Provider (calculated from invoice data to get real user IDs) - Keep for backward compatibility
@riverpod
class AdminUsersNotifier extends _$AdminUsersNotifier {
  @override
  Future<Map<String, dynamic>> build({
    int page = 1,
    int limit = 50,
    String? search,
    int? roleFilter,
    bool? verifiedFilter,
  }) async {
    final userService = ref.watch(userServiceProvider);

    try {
      final allUser = await userService.getAll();

      // Get current logged-in user ID to exclude from list
      final tokenStorage = ref.watch(tokenStorageProvider);
      final currentUserId = await tokenStorage.getUserId();

      // Apply filters
      var filteredUsers = allUser.where((user) {
        // Exclude current logged-in user
        if (currentUserId != null && user.userId == currentUserId) {
          return false;
        }

        if (search != null && search.isNotEmpty) {
          final searchLower = search.toLowerCase();
          if (!user.fullName.toLowerCase().contains(searchLower) &&
              !user.email.toLowerCase().contains(searchLower) &&
              !user.userName.toLowerCase().contains(searchLower)) {
            return false;
          }
        }

        if (roleFilter != null && user.roleId != roleFilter) {
          return false;
        }

        if (verifiedFilter != null && user.isVerified != verifiedFilter) {
          return false;
        }

        return true;
      }).toList();

      // Apply pagination
      final startIndex = (page - 1) * limit;
      final endIndex = (startIndex + limit).clamp(0, filteredUsers.length);
      final paginatedUsers = filteredUsers.sublist(startIndex, endIndex);

      return {
        'users': paginatedUsers,
        'totalCount': filteredUsers.length,
        'totalPages': (filteredUsers.length / limit).ceil(),
        'currentPage': page,
      };
    } catch (e) {
      print('Failed to load users from invoice data: $e');
      return {
        'users': <User>[],
        'totalCount': 0,
        'totalPages': 1,
        'currentPage': 1,
      };
    }
  }

  Future<void> deleteUser(String userId) async {
    // Mock delete - in real implementation, use backend delete endpoint
    print('Mock: Deleting user $userId');
    ref.invalidateSelf();
  }
}

// User Statistics Provider (calculated from invoice data)
@riverpod
class UserStatisticsNotifier extends _$UserStatisticsNotifier {
  @override
  Future<Map<String, dynamic>> build() async {
    final userService = ref.watch(userServiceProvider);
    try {
      return await userService.calculateUserStatisticsFromInvoices();
    } catch (e) {
      print('Failed to load user statistics: $e');
      return {
        'totalUsers': 0,
        'activeUsers': 0,
        'newUsersThisMonth': 0,
        'userGrowthPercentage': 0.0,
      };
    }
  }
}

// User Growth Data Provider (calculated from invoice data)
@riverpod
class UserGrowthDataNotifier extends _$UserGrowthDataNotifier {
  @override
  Future<List<Map<String, dynamic>>> build() async {
    final userService = ref.watch(userServiceProvider);
    try {
      return await userService.calculateUserGrowthFromInvoices();
    } catch (e) {
      print('Failed to load user growth data: $e');
      return [];
    }
  }
}

// Admin Invoices Provider
@riverpod
class AdminInvoicesNotifier extends _$AdminInvoicesNotifier {
  @override
  Future<List<Invoice>> build({required String period}) async {
    final invoiceService = ref.watch(invoiceServiceProvider);
    try {
      final invoices = await invoiceService.getAllInvoices();

      final now = DateTime.now();
      DateTime startDate;

      switch (period) {
        case "Daily":
          startDate = DateTime(now.year, now.month, now.day);
          break;
        case "Weekly":
          startDate = now.subtract(Duration(days: now.weekday - 1)); // Monday
          break;
        case "Monthly":
          startDate = DateTime(now.year, now.month, 1);
          break;
        case "Yearly":
          startDate = DateTime(now.year, 1, 1);
          break;
        default:
          startDate = DateTime(1970);
      }

      return invoices.where((invoice) {
        return invoice.createdDate!.isAfter(startDate);
      }).toList();
    } catch (e) {
      print('Failed to load admin invoices: $e');
      return <Invoice>[];
    }
  }
}

// Revenue Statistics Provider (calculated from invoices)
@riverpod
class RevenueStatisticsNotifier extends _$RevenueStatisticsNotifier {
  @override
  Future<Map<String, dynamic>> build({required String period}) async {
    final invoiceService = ref.watch(invoiceServiceProvider);
    try {
      final invoices = await invoiceService.getAllInvoices();

      final filteredInvoices = _filterInvoicesByPeriod(invoices, period);
      return invoiceService.calculateRevenueStatistics(filteredInvoices);
    } catch (e) {
      print('Failed to load revenue statistics: $e');
      return {
        'totalRevenue': 0.0,
        'monthlyRecurringRevenue': 0.0,
        'averageRevenuePerUser': 0.0,
        'revenueGrowthPercentage': 0.0,
      };
    }
  }

  List<Invoice> _filterInvoicesByPeriod(List<Invoice> invoices, String period) {
    final now = DateTime.now();
    DateTime startDate;

    switch (period) {
      case "Daily":
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case "Weekly":
        startDate = now.subtract(Duration(days: now.weekday - 1));
        break;
      case "Monthly":
        startDate = DateTime(now.year, now.month, 1);
        break;
      case "Yearly":
        startDate = DateTime(now.year, 1, 1);
        break;
      default:
        startDate = DateTime(1970);
    }

    return invoices.where((inv) {
      return inv.createdDate!.isAfter(startDate);
    }).toList();
  }
}

// Revenue Growth Data Provider (calculated from invoices)
@riverpod
class RevenueGrowthDataNotifier extends _$RevenueGrowthDataNotifier {
  @override
  Future<List<Map<String, dynamic>>> build() async {
    final invoiceService = ref.watch(invoiceServiceProvider);
    try {
      final invoices = await invoiceService.getAllInvoices();
      return invoiceService.calculateRevenueGrowthData(invoices);
    } catch (e) {
      print('Failed to load revenue growth data: $e');
      return [];
    }
  }
}

// Financial Metrics Provider (calculated from invoices)
@riverpod
class FinancialMetricsNotifier extends _$FinancialMetricsNotifier {
  @override
  Future<Map<String, dynamic>> build() async {
    final invoiceService = ref.watch(invoiceServiceProvider);
    try {
      final invoices = await invoiceService.getAllInvoices();
      return invoiceService.calculateFinancialMetrics(invoices);
    } catch (e) {
      print('Failed to load financial metrics: $e');
      return {
        'averageRevenuePerUser': 0.0,
        'customerLifetimeValue': 0.0,
        'monthlyRecurringRevenue': 0.0,
        'churnRate': 0.0,
      };
    }
  }
}

// Combined Admin Dashboard Data Provider
@riverpod
Future<Map<String, dynamic>> adminDashboardData(Ref ref) async {
  try {
    final userStats = await ref.watch(userStatisticsNotifierProvider.future);
    final revenueStats = await ref.watch(revenueStatisticsNotifierProvider(period: "Monthly").future);
    final financialMetrics = await ref.watch(financialMetricsNotifierProvider.future);

    return {
      'userStats': userStats,
      'revenueStats': revenueStats,
      'financialMetrics': financialMetrics,
    };
  } catch (e) {
    print('Failed to load admin dashboard data: $e');
    return {
      'userStats': {},
      'revenueStats': {},
      'financialMetrics': {},
    };
  }
}