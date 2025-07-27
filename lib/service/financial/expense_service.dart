import 'package:flutter/material.dart';

import '../api/base/generic_handler.dart';
import '../api/base/id_generator.dart';
import '../../model/models.dart';

class ExpenseService extends ApiService<Expense, String> {
  ExpenseService() : super(endpoint: '/api/Expense');

  @override
  Expense fromJson(Map<String, dynamic> json) => Expense.fromJson(json);

  @override
  Map<String, dynamic> toJson(dynamic data) {
    if (data is Expense) return data.toJson();
    if (data is ExpenseRequest) return data.toJson();
    if (data is Map<String, dynamic>) return data;
    throw ArgumentError('Unsupported data type for toJson: ${data.runtimeType}');
  }

  // Get all expenses for a user
  Future<List<Expense>> getUserExpenses(String userId) async {
    try {
      final allExpenses = await getAll();
      return allExpenses.where((expense) => expense.userId == userId).toList();
    } catch (e) {
      throw Exception('Failed to get user expenses: $e');
    }
  }

  // Get recent transactions from specific endpoint
  Future<List<Expense>> getRecentTransactions(String userId) async {
    try {
      final response = await dio.get('$endpoint/recent-transactions/$userId');
      final List<dynamic> transactionsList = response.data['data'];
      debugPrint('recentTrans: $transactionsList');
      return transactionsList.map((json) => fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Failed to get recent transactions: $e');
    }
  }

  // Get expenses by category
  Future<List<Expense>> getExpensesByCategory(String categoryId, String userId) async {
    try {
      final userExpenses = await getUserExpenses(userId);
      return userExpenses.where((expense) => expense.categoryId == categoryId).toList();
    } catch (e) {
      throw Exception('Failed to get expenses by category: $e');
    }
  }

  // Get expenses for a date range
  Future<List<Expense>> getExpensesInDateRange(String userId, DateTime startDate, DateTime endDate) async {
    try {
      final userExpenses = await getUserExpenses(userId);
      return userExpenses.where((expense) => 
        expense.createdDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
        expense.createdDate.isBefore(endDate.add(const Duration(days: 1)))
      ).toList();
    } catch (e) {
      throw Exception('Failed to get expenses in date range: $e');
    }
  }

  // Get expense by ID (inherited method)
  // Future<Expense> getById(String expenseId) is inherited

  // Create new expense (inherited method with domain-specific wrapper)
  Future<Expense> createExpense(ExpenseRequest request) async {
    try {
      return await create<ExpenseRequest>(request);
    } catch (e) {
      throw Exception('Failed to create expense: $e');
    }
  }

  // Update expense (inherited method with domain-specific wrapper)
  Future<Expense> updateExpense(ExpenseRequest updates) async {
    try {
      if (updates.expenseId == null) {
        throw ArgumentError('expensesId is required for update operations');
      }
      return await updateById<ExpenseRequest>(updates.expenseId!, updates);
    } catch (e) {
      throw Exception('Failed to update expense: $e');
    }
  }

  // Delete expense (inherited method)
  // Future<void> delete(String expenseId) is inherited

  // Get recent expenses (last N expenses)
  Future<List<Expense>> getRecentExpenses(String userId, {int limit = 10}) async {
    try {
      final userExpenses = await getUserExpenses(userId);
      userExpenses.sort((a, b) => b.createdDate.compareTo(a.createdDate));
      return userExpenses.take(limit).toList();
    } catch (e) {
      throw Exception('Failed to get recent expenses: $e');
    }
  }

}