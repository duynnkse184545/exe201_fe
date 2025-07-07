import '../api/base/generic_handler.dart';
import '../../model/models.dart';

class BudgetService {
  late final ApiService<Budget, String> _apiService;

  BudgetService() {
    _apiService = ApiService<Budget, String>(
      endpoint: '/api/budgets',
      fromJson: (json) => Budget.fromJson(json),
    );
  }

  // Get all budgets for a user
  Future<List<Budget>> getUserBudgets(String userId) async {
    try {
      final allBudgets = await _apiService.getAll();
      return allBudgets.where((budget) => budget.userId == userId).toList();
    } catch (e) {
      throw Exception('Failed to get user budgets: $e');
    }
  }

  // Get active budgets (current date within budget period)
  Future<List<Budget>> getActiveBudgets(String userId) async {
    try {
      final budgets = await getUserBudgets(userId);
      final now = DateTime.now();
      return budgets.where((budget) => 
        budget.startDate.isBefore(now) && budget.endDate.isAfter(now)
      ).toList();
    } catch (e) {
      throw Exception('Failed to get active budgets: $e');
    }
  }

  // Get budget by category
  Future<Budget?> getBudgetByCategory(String userId, String categoryId) async {
    try {
      final budgets = await getActiveBudgets(userId);
      return budgets.where((budget) => budget.categoryId == categoryId).firstOrNull;
    } catch (e) {
      throw Exception('Failed to get budget by category: $e');
    }
  }

  // Create/Set spending limit (budget)
  Future<Budget> setBudget(BudgetRequest request, String userId) async {
    try {
      final budgetData = request.toJson();
      budgetData['userId'] = userId;
      budgetData['budgetId'] = _generateId();
      
      return await _apiService.create(budgetData);
    } catch (e) {
      throw Exception('Failed to set budget: $e');
    }
  }

  // Update budget
  Future<Budget> updateBudget(String budgetId, Map<String, dynamic> updates) async {
    try {
      return await _apiService.update(budgetId, updates);
    } catch (e) {
      throw Exception('Failed to update budget: $e');
    }
  }

  // Delete budget
  Future<void> deleteBudget(String budgetId) async {
    try {
      await _apiService.delete(budgetId);
    } catch (e) {
      throw Exception('Failed to delete budget: $e');
    }
  }

  // Calculate spent amount for a budget (requires ExpenseService)
  Future<double> calculateSpentAmount(Budget budget, List<Expense> expenses) async {
    try {
      return expenses
          .where((expense) =>
            expense.userId == budget.userId &&
            expense.exCId == budget.categoryId &&
            expense.type == ExpenseType.expense &&
            expense.createdDate.isAfter(budget.startDate) &&
            expense.createdDate.isBefore(budget.endDate.add(const Duration(days: 1))))
          .fold<double>(0.0, (sum, expense) => sum + expense.amount);
    } catch (e) {
      throw Exception('Failed to calculate spent amount: $e');
    }
  }

  // Get budget with calculated spent amount
  Future<Budget> getBudgetWithSpentAmount(Budget budget, List<Expense> expenses) async {
    try {
      final spentAmount = await calculateSpentAmount(budget, expenses);
      return budget.copyWith(spentAmount: spentAmount);
    } catch (e) {
      throw Exception('Failed to get budget with spent amount: $e');
    }
  }

  // Get all budgets with spent amounts
  Future<List<Budget>> getBudgetsWithSpentAmounts(String userId, List<Expense> expenses) async {
    try {
      final budgets = await getUserBudgets(userId);
      final budgetsWithSpent = <Budget>[];
      
      for (final budget in budgets) {
        final budgetWithSpent = await getBudgetWithSpentAmount(budget, expenses);
        budgetsWithSpent.add(budgetWithSpent);
      }
      
      return budgetsWithSpent;
    } catch (e) {
      throw Exception('Failed to get budgets with spent amounts: $e');
    }
  }

  // Check if budget is over limit
  bool isBudgetOverLimit(Budget budget) {
    return budget.spentAmount > budget.budgetAmount;
  }

  // Get budget utilization percentage
  double getBudgetUtilization(Budget budget) {
    if (budget.budgetAmount <= 0) return 0.0;
    return (budget.spentAmount / budget.budgetAmount) * 100;
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}