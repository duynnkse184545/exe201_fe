import '../api/base/generic_handler.dart';
import '../api/base/id_generator.dart';
import '../../model/models.dart';

class ExpenseService {
  late final ApiService<Expense, String> _apiService;

  ExpenseService() {
    _apiService = ApiService<Expense, String>(
      endpoint: '/api/Expenses',
      fromJson: (json) => Expense.fromJson(json),
      toJson: (expense) => expense.toJson(),
    );
  }

  // Get all expenses for a user
  Future<List<Expense>> getUserExpenses(String userId) async {
    try {
      final allExpenses = await _apiService.getAll();
      return allExpenses.where((expense) => expense.userId == userId).toList();
    } catch (e) {
      throw Exception('Failed to get user expenses: $e');
    }
  }

  // Get expenses for a specific account
  Future<List<Expense>> getAccountExpenses(String accountId) async {
    try {
      final allExpenses = await _apiService.getAll();
      return allExpenses.where((expense) => expense.accountId == accountId).toList();
    } catch (e) {
      throw Exception('Failed to get account expenses: $e');
    }
  }

  // Get expenses by category
  Future<List<Expense>> getExpensesByCategory(String categoryId, String userId) async {
    try {
      final userExpenses = await getUserExpenses(userId);
      return userExpenses.where((expense) => expense.exCid == categoryId).toList();
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

  // Get expense by ID
  Future<Expense> getExpenseById(String expenseId) async {
    try {
      return await _apiService.getById(expenseId);
    } catch (e) {
      throw Exception('Failed to get expense: $e');
    }
  }

  // Create new expense
  Future<Expense> createExpense(ExpenseRequest request) async {
    try {
      return await _apiService.create<ExpenseRequest>(request);
    } catch (e) {
      throw Exception('Failed to create expense: $e');
    }
  }

  // Update expense
  Future<Expense> updateExpense(ExpenseRequest updates) async {
    try {
      if (updates.expensesId == null) {
        throw ArgumentError('expensesId is required for update operations');
      }
      return await _apiService.updateById<ExpenseRequest>(updates.expensesId!, updates);
    } catch (e) {
      throw Exception('Failed to update expense: $e');
    }
  }

  // Delete expense
  Future<void> deleteExpense(String expenseId) async {
    try {
      await _apiService.delete(expenseId);
    } catch (e) {
      throw Exception('Failed to delete expense: $e');
    }
  }

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