import '../api/base/generic_handler.dart';
import '../../model/models.dart';

class ExpenseService {
  late final ApiService<Expense, String> _apiService;

  ExpenseService() {
    _apiService = ApiService<Expense, String>(
      endpoint: '/api/expenses',
      fromJson: (json) => Expense.fromJson(json),
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

  // Get expenses for a specific month
  Future<List<Expense>> getUserExpensesForMonth(String userId, DateTime month) async {
    try {
      final allExpenses = await getUserExpenses(userId);
      return allExpenses.where((expense) => 
        expense.createdDate.year == month.year &&
        expense.createdDate.month == month.month
      ).toList();
    } catch (e) {
      throw Exception('Failed to get monthly expenses: $e');
    }
  }

  // Get expenses by category
  Future<List<Expense>> getExpensesByCategory(String userId, String categoryId) async {
    try {
      final allExpenses = await getUserExpenses(userId);
      return allExpenses.where((expense) => expense.exCId == categoryId).toList();
    } catch (e) {
      throw Exception('Failed to get expenses by category: $e');
    }
  }

  // Get recent expenses (last N)
  Future<List<Expense>> getRecentExpenses(String userId, {int limit = 10}) async {
    try {
      final allExpenses = await getUserExpenses(userId);
      allExpenses.sort((a, b) => b.createdDate.compareTo(a.createdDate));
      return allExpenses.take(limit).toList();
    } catch (e) {
      throw Exception('Failed to get recent expenses: $e');
    }
  }

  // Add new expense
  Future<Expense> addExpense(ExpenseRequest request, String userId) async {
    try {
      final expenseData = request.toJson();
      expenseData['userId'] = userId;
      expenseData['expensesId'] = _generateId();
      expenseData['createdDate'] = DateTime.now().toIso8601String();
      
      return await _apiService.create(expenseData);
    } catch (e) {
      throw Exception('Failed to add expense: $e');
    }
  }

  // Update expense
  Future<Expense> updateExpense(String expenseId, Map<String, dynamic> updates) async {
    try {
      return await _apiService.update(expenseId, updates);
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

  // Calculate total income for period
  Future<double> calculateTotalIncome(String userId, DateTime startDate, DateTime endDate) async {
    try {
      final expenses = await getUserExpenses(userId);
      return expenses
          .where((expense) =>
            expense.type == ExpenseType.income &&
            expense.createdDate.isAfter(startDate) &&
            expense.createdDate.isBefore(endDate))
          .fold<double>(0.0, (sum, expense) => sum + expense.amount);
    } catch (e) {
      throw Exception('Failed to calculate total income: $e');
    }
  }

  // Calculate total expenses for period
  Future<double> calculateTotalExpenses(String userId, DateTime startDate, DateTime endDate) async {
    try {
      final expenses = await getUserExpenses(userId);
      return expenses
          .where((expense) => 
            expense.type == ExpenseType.expense &&
            expense.createdDate.isAfter(startDate) &&
            expense.createdDate.isBefore(endDate))
          .fold<double>(0.0, (sum, expense) => sum + expense.amount);
    } catch (e) {
      throw Exception('Failed to calculate total expenses: $e');
    }
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}