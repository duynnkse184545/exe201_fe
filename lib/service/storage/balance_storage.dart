import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../model/models.dart';

class BalanceStorage {
  static const String _balanceDataKey = 'balance_data_';
  static const String _lastSyncKey = 'last_sync_';
  static const String _pendingExpensesKey = 'pending_expenses';
  static const String _pendingBudgetsKey = 'pending_budgets';

  // Save complete balance data to local storage
  Future<void> saveBalanceData(Balance balanceData) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_balanceDataKey${balanceData.userId}';
    final jsonString = jsonEncode(balanceData.toJson());
    await prefs.setString(key, jsonString);
    await prefs.setString('$_lastSyncKey${balanceData.userId}', DateTime.now().toIso8601String());
  }

  // Get cached balance data
  Future<Balance?> getBalanceData(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_balanceDataKey$userId';
    final jsonString = prefs.getString(key);
    
    if (jsonString == null) return null;
    
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return Balance.fromJson(json);
    } catch (e) {
      // If parsing fails, return null
      return null;
    }
  }

  // Check if cached data is still valid
  Future<bool> isCacheValid(String userId, {Duration maxAge = const Duration(hours: 1)}) async {
    final prefs = await SharedPreferences.getInstance();
    final lastSyncString = prefs.getString('$_lastSyncKey$userId');
    
    if (lastSyncString == null) return false;
    
    final lastSync = DateTime.parse(lastSyncString);
    return DateTime.now().difference(lastSync) < maxAge;
  }

  // Save pending expense for offline support
  Future<void> savePendingExpense(ExpenseRequest expense, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final existingJson = prefs.getString(_pendingExpensesKey) ?? '[]';
    final List<dynamic> existing = jsonDecode(existingJson);
    
    final expenseWithUser = expense.toJson();
    expenseWithUser['userId'] = userId;
    expenseWithUser['timestamp'] = DateTime.now().toIso8601String();
    
    existing.add(expenseWithUser);
    await prefs.setString(_pendingExpensesKey, jsonEncode(existing));
  }

  // Get pending expenses
  Future<List<Map<String, dynamic>>> getPendingExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_pendingExpensesKey) ?? '[]';
    
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.cast<Map<String, dynamic>>();
  }

  // Clear pending expenses after successful sync
  Future<void> clearPendingExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pendingExpensesKey);
  }

  // Save pending budget for offline support
  Future<void> savePendingBudget(BudgetRequest budget, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final existingJson = prefs.getString(_pendingBudgetsKey) ?? '[]';
    final List<dynamic> existing = jsonDecode(existingJson);
    
    final budgetWithUser = budget.toJson();
    budgetWithUser['userId'] = userId;
    budgetWithUser['timestamp'] = DateTime.now().toIso8601String();
    
    existing.add(budgetWithUser);
    await prefs.setString(_pendingBudgetsKey, jsonEncode(existing));
  }

  // Get pending budgets
  Future<List<Map<String, dynamic>>> getPendingBudgets() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_pendingBudgetsKey) ?? '[]';
    
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.cast<Map<String, dynamic>>();
  }

  // Clear pending budgets after successful sync
  Future<void> clearPendingBudgets() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pendingBudgetsKey);
  }

  // Save recent transactions for a specific category (for quick access)
  Future<void> saveRecentTransactionsForCategory(String userId, String categoryId, List<Expense> transactions) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'recent_transactions_${userId}_$categoryId';
    final jsonList = transactions.map((transaction) => transaction.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await prefs.setString(key, jsonString);
  }

  // Get cached recent transactions for a specific category
  Future<List<Expense>?> getRecentTransactionsForCategory(String userId, String categoryId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'recent_transactions_${userId}_$categoryId';
    final jsonString = prefs.getString(key);
    
    if (jsonString == null) return null;
    
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => Expense.fromJson(json)).toList();
    } catch (e) {
      return null;
    }
  }

  // Clear all cached data for a user
  Future<void> clearUserCache(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    
    for (final key in keys) {
      if (key.contains(userId)) {
        await prefs.remove(key);
      }
    }
  }

  // Clear all cached data
  Future<void> clearAllCache() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    
    for (final key in keys) {
      if (key.startsWith(_balanceDataKey) ||
          key.startsWith(_lastSyncKey) ||
          key.startsWith('recent_transactions_') ||
          key == _pendingExpensesKey ||
          key == _pendingBudgetsKey) {
        await prefs.remove(key);
      }
    }
  }

  // Sync pending data (call this when internet connection is restored)
  Future<void> syncPendingData() async {
    // This would be implemented to sync pending expenses and budgets
    // when the app comes back online
    // For now, just clear the pending data
    await clearPendingExpenses();
    await clearPendingBudgets();
  }
}