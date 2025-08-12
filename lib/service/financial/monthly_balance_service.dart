import '../api/base/generic_handler.dart';
import '../api/base/id_generator.dart';
import '../../model/models.dart';

class MonthlyBalanceService extends ApiService<MonthlyBalance, String> {
  MonthlyBalanceService() : super(endpoint: '/api/monthly-balances');

  @override
  MonthlyBalance fromJson(Map<String, dynamic> json) => MonthlyBalance.fromJson(json);

  @override
  Map<String, dynamic> toJson(dynamic data) {
    if (data is MonthlyBalance) return data.toJson();
    if (data is MonthlyBalanceRequest) return data.toJson();
    if (data is Map<String, dynamic>) return data;
    throw ArgumentError('Unsupported data type for toJson: ${data.runtimeType}');
  }

  // Get current active monthly balance for user
  Future<MonthlyBalance?> getCurrentMonthlyBalance(String userId) async {
    try {
      final allBalances = await getAll();
      return allBalances
          .where((balance) => balance.userId == userId && balance.isActive)
          .firstOrNull;
    } catch (e) {
      throw Exception('Failed to get current monthly balance: $e');
    }
  }

  // Get monthly balance for specific month
  Future<MonthlyBalance?> getMonthlyBalance(String userId, DateTime month) async {
    try {
      final allBalances = await getAll();
      final targetMonth = DateTime(month.year, month.month, 1);
      return allBalances
          .where((balance) => 
            balance.userId == userId && 
            balance.month.year == targetMonth.year &&
            balance.month.month == targetMonth.month)
          .firstOrNull;
    } catch (e) {
      throw Exception('Failed to get monthly balance: $e');
    }
  }

  // Create new monthly balance (inherited method with domain-specific wrapper)
  Future<MonthlyBalance> createMonthlyBalance(MonthlyBalanceRequest request) async {
    try {
      return await create<MonthlyBalanceRequest>(request);
    } catch (e) {
      throw Exception('Failed to create monthly balance: $e');
    }
  }

  // Process month end - calculate savings and prepare for next month
  Future<MonthlyBalance> processMonthEnd(String userId, DateTime month) async {
    try {
      final monthlyBalance = await getMonthlyBalance(userId, month);
      if (monthlyBalance == null) {
        throw Exception('Monthly balance not found for month: $month');
      }

      // Calculate actual saved amount (now provided by backend)
      final actualSaved = monthlyBalance.totalCarryOverToNextBalance;
      
      // Create update request with all required fields
      final updateRequest = MonthlyBalanceRequest(
        balanceId: monthlyBalance.balanceId,
        month: monthlyBalance.month,
        initialBalance: monthlyBalance.initialBalance,
        userId: monthlyBalance.userId,
        budgetAllocations: monthlyBalance.categoryBudgets
            .map((budget) => BudgetRequest(
                  budgetId: budget.budgetId,
                  categoryId: budget.categoryId,
                  accountId: budget.accountId,
                  budgetAmount: budget.budgetAmount,
                  isLocked: budget.isLocked,
                ))
            .toList(),
      );
      
      return await updateMonthlyBalance(updateRequest);
    } catch (e) {
      throw Exception('Failed to process month end: $e');
    }
  }

  // Create next month's balance based on current month
  Future<MonthlyBalance> createNextMonthBalance(String userId, DateTime currentMonth, List<BudgetRequest> newBudgetAllocations) async {
    try {
      final currentBalance = await getMonthlyBalance(userId, currentMonth);
      if (currentBalance == null) {
        throw Exception('Current monthly balance not found');
      }

      // Get next month's initial balance (provided by backend)
      final nextMonthInitialBalance = currentBalance.nextMonthInitialBalance;
      
      // Create next month
      final nextMonth = DateTime(currentMonth.year, currentMonth.month + 1, 1);
      
      final request = MonthlyBalanceRequest(
        month: nextMonth,
        initialBalance: nextMonthInitialBalance,
        userId: userId,
        budgetAllocations: newBudgetAllocations,
      );
      
      return await createMonthlyBalance(request);
    } catch (e) {
      throw Exception('Failed to create next month balance: $e');
    }
  }

  // Add income to queue for next month
  Future<QueuedIncome> addIncomeToQueue(QueuedIncomeRequest request) async {
    try {
      // This would typically be a separate API endpoint for queued income
      // For now, we'll assume it's handled within the monthly balance update
      return QueuedIncome.fromJson(request.toJson());
    } catch (e) {
      throw Exception('Failed to add income to queue: $e');
    }
  }

  // Get user's monthly balance history
  Future<List<MonthlyBalance>> getMonthlyBalanceHistory(String userId, {int limit = 12}) async {
    try {
      final allBalances = await getAll();
      final userBalances = allBalances
          .where((balance) => balance.userId == userId)
          .toList();
      
      // Sort by month (newest first)
      userBalances.sort((a, b) => b.month.compareTo(a.month));
      
      return userBalances.take(limit).toList();
    } catch (e) {
      throw Exception('Failed to get monthly balance history: $e');
    }
  }

  // Update monthly balance (inherited method with domain-specific wrapper)
  Future<MonthlyBalance> updateMonthlyBalance(MonthlyBalanceRequest updates) async {
    try {
      if (updates.balanceId == null) {
        throw ArgumentError('balanceId is required for update operations');
      }
      return await updateById<MonthlyBalanceRequest>(updates.balanceId!, updates);
    } catch (e) {
      throw Exception('Failed to update monthly balance: $e');
    }
  }

  // Delete monthly balance (inherited method)
  // Future<void> delete(String balanceId) is inherited

  // Generate locked budgets for next month based on current month
  Future<List<BudgetRequest>> generateLockedBudgetAllocations(String userId, DateTime currentMonth) async {
    try {
      final currentBalance = await getMonthlyBalance(userId, currentMonth);
      if (currentBalance == null) return [];

      return currentBalance.categoryBudgets
          .where((budget) => budget.isLocked)
          .map((budget) => BudgetRequest(
            categoryId: budget.categoryId,
            accountId: budget.accountId,
            budgetAmount: budget.budgetAmount,
            isLocked: true,
          ))
          .toList();
    } catch (e) {
      throw Exception('Failed to generate locked budget allocations: $e');
    }
  }

}