import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../model/models.dart';
import '../api/base/generic_handler.dart';
import '../api/base/api_client.dart';

class BalanceService extends ApiService<Balance, String> {
  BalanceService() : super(endpoint: '/api/enhanced-financial-dashboard');

  @override
  Balance fromJson(Map<String, dynamic> json) => Balance.fromJson(json['data'] ?? json);

  @override
  Map<String, dynamic> toJson(dynamic data) {
    if (data is Balance) return data.toJson();
    if (data is ExpenseRequest) return data.toJson();
    if (data is BudgetRequest) return data.toJson();
    if (data is Map<String, dynamic>) return data;
    throw ArgumentError('Unsupported data type for toJson: ${data.runtimeType}');
  }

  // Get complete balance data from backend
  Future<Balance> getCompleteBalanceData(String userId) async {
    try {
      final response = await dio.get('$endpoint/complete-balance/$userId');
      final responseData = response.data['data'] as Map<String, dynamic>;

      // Ensure userId is set for budgets since backend doesn't send it
      if (responseData['budgets'] != null) {
        final budgetsList = responseData['budgets'] as List;
        for (var budget in budgetsList) {
          if (budget is Map<String, dynamic>) {
            budget['userId'] = userId;
          }
        }
      }

      // Ensure userId is set for financial accounts since backend doesn't send it
      if (responseData['accounts'] != null) {
        final accountsList = responseData['accounts'] as List;
        for (var account in accountsList) {
          if (account is Map<String, dynamic>) {
            account['userId'] = userId;
          }
        }
      }

      // Ensure userId is set for the main balance object
      responseData['userId'] = userId;

      return fromJson(responseData);
    } catch (e, stackTrace) {
      debugPrint('ERROR: Failed in getCompleteBalanceData: $e');
      debugPrint('ERROR: Stack trace: $stackTrace');
      throw Exception('Failed to get complete balance data: $e');
    }
  }

  // Add expense
  Future<Expense> addExpense(ExpenseRequest request) async {
    try {
      final response = await dio.post(endpoint, data: toJson(request));
      return Expense.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to add expense: $e');
    }
  }

  // Set budget
  Future<Budget> setBudget(BudgetRequest request) async {
    try {
      final response = await dio.post(endpoint, data: toJson(request));
      return Budget.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to set budget: $e');
    }
  }

  // Get all recent transactions for current month
  Future<List<Expense>> getRecentTransactions(String userId) async {
    try {
      final response = await dio.get('$endpoint/current-month/$userId');
      final List<dynamic> transactionsList = response.data['data'];
      return transactionsList.map((json) => Expense.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Failed to get recent transactions: $e');
    }
  }

  // Filter transactions by category (client-side filtering)
  List<Expense> filterTransactionsByCategory(List<Expense> transactions, String categoryId) {
    return transactions.where((transaction) => transaction.categoryId == categoryId).toList();
  }

  // Get budget health (backend computed)
  Future<Map<String, int>> getBudgetHealth(String userId) async {
    try {
      final response = await dio.get('$endpoint/budget-utilization/$userId');
      final responseData = response.data as Map<String, dynamic>;
      return {
        'overBudget': responseData['overBudgetCount'] ?? 0,
        'nearLimit': responseData['nearLimitCount'] ?? 0,
        'healthy': responseData['healthyCount'] ?? 0,
        'total': responseData['totalBudgets'] ?? 0,
      };
    } catch (e) {
      throw Exception('Failed to get budget health: $e');
    }
  }

  // Toggle budget lock
  Future<Budget> toggleBudgetLock(String budgetId, bool isLocked) async {
    try {
      final response = await dio.put('$endpoint/budget-lock/$budgetId', data: {'isLocked': isLocked});
      return Budget.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to toggle budget lock: $e');
    }
  }
}