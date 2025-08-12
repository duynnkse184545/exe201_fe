import '../api/base/generic_handler.dart';
import '../api/base/id_generator.dart';
import '../../model/budget/budget.dart';

class BudgetService extends ApiService<Budget, String> {
  BudgetService() : super(endpoint: '/api/Budget');

  @override
  Budget fromJson(Map<String, dynamic> json) => Budget.fromJson(json);

  @override
  Map<String, dynamic> toJson(dynamic data) {
    if (data is Budget) return data.toJson();
    if (data is BudgetRequest) return data.toJson();
    if (data is Map<String, dynamic>) return data;
    throw ArgumentError('Unsupported data type for toJson: ${data.runtimeType}');
  }

  // Get all budgets for a user
  Future<List<Budget>> getUserBudgets(String userId) async {
    try {
      final allBudgets = await getAll();
      return allBudgets.where((budget) => budget.userId == userId).toList();
    } catch (e) {
      throw Exception('Failed to get user budgets: $e');
    }
  }

  // Get budgets for a specific account
  Future<List<Budget>> getAccountBudgets(String accountId) async {
    try {
      final allBudgets = await getAll();
      return allBudgets.where((budget) => budget.accountId == accountId).toList();
    } catch (e) {
      throw Exception('Failed to get account budgets: $e');
    }
  }

  // Get budget by category
  Future<Budget?> getBudgetByCategory(String categoryId, String userId) async {
    try {
      final userBudgets = await getUserBudgets(userId);
      return userBudgets.where((budget) => budget.categoryId == categoryId).firstOrNull;
    } catch (e) {
      throw Exception('Failed to get budget by category: $e');
    }
  }

  // Get active budgets (current period)
  Future<List<Budget>> getActiveBudgets(String userId) async {
    try {
      final userBudgets = await getUserBudgets(userId);
      final now = DateTime.now();
      return userBudgets.where((budget) => 
        now.isAfter(budget.startDate) && now.isBefore(budget.endDate)
      ).toList();
    } catch (e) {
      throw Exception('Failed to get active budgets: $e');
    }
  }

  // Get budgets for a specific month
  Future<List<Budget>> getMonthlyBudgets(String userId, DateTime month) async {
    try {
      final userBudgets = await getUserBudgets(userId);
      return userBudgets.where((budget) => 
        budget.startDate.year == month.year && budget.startDate.month == month.month
      ).toList();
    } catch (e) {
      throw Exception('Failed to get monthly budgets: $e');
    }
  }

  // Get budget by ID (inherited method)
  // Future<Budget> getById(String budgetId) is inherited

  // Create new budget (inherited method with domain-specific wrapper)
  Future<Budget> createBudget(BudgetRequest request) async {
    try {
      return await create<BudgetRequest>(request);
    } catch (e) {
      throw Exception('Failed to create budget: $e');
    }
  }

  // Update budget (inherited method with domain-specific wrapper)
  Future<Budget> updateBudget(BudgetRequest updates) async {
    try {
      if (updates.budgetId == null) {
        throw ArgumentError('budgetId is required for update operations');
      }
      return await update<BudgetRequest>(updates);
    } catch (e) {
      throw Exception('Failed to update budget: $e');
    }
  }

  // Update budget amount
  Future<Budget> updateBudgetAmount(String budgetId, double newAmount) async {
    try {
      return await updateById<Map<String, dynamic>>(budgetId, {'budgetAmount': newAmount});
    } catch (e, stack) {
      throw Exception('Failed to update budget amount: $e, $stack');
    }
  }

  // Toggle budget lock
  Future<Budget> toggleBudgetLock(String budgetId, bool isLocked) async {
    try {
      final response = await dio.put('$endpoint/lock/$budgetId', data: {'isLocked': isLocked});
      return fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to toggle budget lock: $e');
    }
  }

  // Delete budget (inherited method)
  // Future<void> delete(String budgetId) is inherited

  // Get over-budget categories
  Future<List<Budget>> getOverBudgetCategories(String userId) async {
    try {
      final activeBudgets = await getActiveBudgets(userId);
      return activeBudgets.where((budget) => budget.isOverBudget).toList();
    } catch (e) {
      throw Exception('Failed to get over-budget categories: $e');
    }
  }

  // Get locked budgets (for next month planning)
  Future<List<Budget>> getLockedBudgets(String userId) async {
    try {
      final userBudgets = await getUserBudgets(userId);
      return userBudgets.where((budget) => budget.isLocked).toList();
    } catch (e) {
      throw Exception('Failed to get locked budgets: $e');
    }
  }

  // Create budget from previous month (for locked budgets)
  Future<Budget> createBudgetFromPrevious(Budget previousBudget) async {
    try {
      final request = BudgetRequest(
        categoryId: previousBudget.categoryId,
        accountId: previousBudget.accountId,
        budgetAmount: previousBudget.budgetAmount,
        isLocked: previousBudget.isLocked,
      );
      return await createBudget(request);
    } catch (e) {
      throw Exception('Failed to create budget from previous: $e');
    }
  }

  // Get total budget amount for a user
  Future<double> getTotalBudgetAmount(String userId) async {
    try {
      final activeBudgets = await getActiveBudgets(userId);
      double total = 0.0;
      for (final budget in activeBudgets) {
        total += budget.budgetAmount;
      }
      return total;
    } catch (e) {
      throw Exception('Failed to get total budget amount: $e');
    }
  }

  // Get total spent amount across all budgets
  Future<double> getTotalSpentAmount(String userId) async {
    try {
      final activeBudgets = await getActiveBudgets(userId);
      double total = 0.0;
      for (final budget in activeBudgets) {
        total += budget.spentAmount;
      }
      return total;
    } catch (e) {
      throw Exception('Failed to get total spent amount: $e');
    }
  }

}