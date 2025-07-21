import 'package:flutter/material.dart';
import '../../model/models.dart';
import '../api/base/generic_handler.dart';
import '../api/base/id_generator.dart';

class BalanceService {
  late final ApiService<Balance, String> _balanceApiService;
  late final ApiService<Map<String, dynamic>, String> _rawApiService;

  BalanceService() {
    _balanceApiService = ApiService<Balance, String>(
      endpoint: '/api/enhanced-financial-dashboard',
      fromJson: (json) => Balance.fromJson(json['data'] ?? json),
    );
    _rawApiService = ApiService<Map<String, dynamic>, String>(
      endpoint: '/api/enhanced-financial-dashboard',
      fromJson: (json) => json,
    );
  }

  // Get complete balance data from backend using fromJson
  Future<Balance> getCompleteBalanceData(String userId) async {
    try {
      final response = await _rawApiService.getById('complete-balance/$userId');

      if (response['budgets'] != null) {
        final budgetsList = response['budgets'] as List;
        for (var budget in budgetsList) {
          if (budget is Map<String, dynamic>) {
            budget['userId'] = userId;
          }
        }
      }

      if (response['accounts'] != null) {
        final accountsList = response['accounts'] as List;
        for (var account in accountsList) {
          if (account is Map<String, dynamic>) {
            account['userId'] = userId;
          }
        }
      }

      return Balance.fromJson(response as Map<String, dynamic>);
    } catch (e, stackTrace) {
      debugPrint('ERROR: Failed in getCompleteBalanceData: $e');
      debugPrint('ERROR: Stack trace: $stackTrace');
      throw Exception('Failed to get complete balance data: $e');
    }
  }


  // Add expense using fromJson
  Future<Expense> addExpense(ExpenseRequest request) async {
    try {
      final response = await _rawApiService.create(request.toJson());
      return Expense.fromJson(response);
    } catch (e) {
      throw Exception('Failed to add expense: $e');
    }
  }

  // Set budget using fromJson
  Future<Budget> setBudget(BudgetRequest request) async {
    try {
      final response = await _rawApiService.create(request.toJson());
      return Budget.fromJson(response);
    } catch (e) {
      throw Exception('Failed to set budget: $e');
    }
  }

  // Get all recent transactions for current month (no limit, no category filter)
  Future<List<Expense>> getRecentTransactions(String userId) async {
    try {
      final response = await _rawApiService.getById('recent-transactions/$userId');
      final List<dynamic> transactionsList = response as List<dynamic>;
      return transactionsList.map((json) => Expense.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Failed to get recent transactions: $e');
    }
  }

  // Filter transactions by category (client-side filtering)
  List<Expense> filterTransactionsByCategory(List<Expense> transactions, String categoryId) {
    return transactions.where((transaction) => transaction.exCid == categoryId).toList();
  }

  // Get budget health (backend computed)
  Future<Map<String, int>> getBudgetHealth(String userId) async {
    try {
      final response = await _rawApiService.getById('budget-utilization/$userId');
      return {
        'overBudget': response['overBudgetCount'] ?? 0,
        'nearLimit': response['nearLimitCount'] ?? 0,
        'healthy': response['healthyCount'] ?? 0,
        'total': response['totalBudgets'] ?? 0,
      };
    } catch (e) {
      throw Exception('Failed to get budget health: $e');
    }
  }

  // Toggle budget lock using fromJson
  Future<Budget> toggleBudgetLock(String budgetId, bool isLocked) async {
    try {
      final response = await _rawApiService.updateById('budget-lock/$budgetId', {'isLocked': isLocked});
      return Budget.fromJson(response);
    } catch (e) {
      throw Exception('Failed to toggle budget lock: $e');
    }
  }
}