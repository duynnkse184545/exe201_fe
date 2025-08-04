import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../model/models.dart';
import 'service_providers.dart';

part 'monthly_balance_provider.g.dart';

// Current monthly balance provider
@riverpod
class CurrentMonthlyBalanceNotifier extends _$CurrentMonthlyBalanceNotifier {
  @override
  Future<MonthlyBalance?> build(String userId) async {
    final service = ref.watch(monthlyBalanceServiceProvider);
    return await service.getCurrentMonthlyBalance(userId);
  }

  // Create new monthly balance for current month
  Future<void> createMonthlyBalance({
    required String userId,
    required double initialBalance,
    required List<BudgetRequest> budgetAllocations,
  }) async {
    try {
      final service = ref.read(monthlyBalanceServiceProvider);
      final request = MonthlyBalanceRequest(
        month: DateTime.now(),
        initialBalance: initialBalance,
        userId: userId,
        budgetAllocations: budgetAllocations,
      );
      
      final newBalance = await service.createMonthlyBalance(request);
      state = AsyncData(newBalance);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  // Add income to queue for next month
  Future<void> addIncomeToQueue({
    required String userId,
    required double amount,
    required String description,
    required String incomeCategoryId,
  }) async {
    try {
      final service = ref.read(monthlyBalanceServiceProvider);
      final request = AddIncomeRequest(
        userId: userId,
        amount: amount,
        description: description,
        incomeCategoryId: incomeCategoryId,
      );
      
      await service.addIncomeToQueue(request);
      
      // Refresh current balance to show queued income
      await refresh();
    } catch (e) {
      final currentData = state.value;
      if (currentData != null) {
        state = AsyncData(currentData.copyWith(
          // Note: We'd need to add error field to MonthlyBalance model
        ));
      }
    }
  }

  // Process month end and create next month
  Future<void> processMonthEnd({
    required String userId,
    required List<BudgetRequest> nextMonthBudgetAllocations,
  }) async {
    try {
      final service = ref.read(monthlyBalanceServiceProvider);
      final currentMonth = DateTime.now();
      
      // Process current month end
      await service.processMonthEnd(userId, currentMonth);
      
      // Create next month's balance
      final nextMonthBalance = await service.createNextMonthBalance(
        userId, 
        currentMonth, 
        nextMonthBudgetAllocations
      );
      
      state = AsyncData(nextMonthBalance);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  // Update budget allocation for current month
  Future<void> updateBudgetAllocation({
    required String userId,
    required String categoryId,
    required double newAmount,
  }) async {
    final currentData = state.value;
    if (currentData == null) return;

    try {
      // Find and update the specific budget
      final updatedBudgets = currentData.categoryBudgets.map((budget) {
        if (budget.categoryId == categoryId) {
          return budget.copyWith(budgetAmount: newAmount);
        }
        return budget;
      }).toList();

      // Recalculate totals
      double totalAllocated = 0.0;
      for (final budget in updatedBudgets) {
        totalAllocated += budget.budgetAmount;
      }
      final remainingForSavings = currentData.initialBalance - totalAllocated;

      final updatedData = currentData.copyWith(
        categoryBudgets: updatedBudgets,
        totalBudgetAllocated: totalAllocated,
        remainingForSavings: remainingForSavings,
        updatedAt: DateTime.now(),
      );

      state = AsyncData(updatedData);

      // Update in backend
      final service = ref.read(monthlyBalanceServiceProvider);
      final updateRequest = MonthlyBalanceRequest(
        balanceId: currentData.balanceId,
        month: currentData.month,
        initialBalance: currentData.initialBalance,
        userId: userId,
        budgetAllocations: updatedBudgets
            .map((budget) => BudgetRequest(
                  budgetId: budget.budgetId,
                  categoryId: budget.categoryId,
                  accountId: budget.accountId,
                  budgetAmount: budget.budgetAmount,
                  isLocked: budget.isLocked,
                ))
            .toList(),
      );
      await service.updateMonthlyBalance(updateRequest);
    } catch (e) {
      // Revert on error
      state = AsyncData(currentData);
    }
  }

  // Toggle budget lock for next month
  Future<void> toggleBudgetLock({
    required String userId,
    required String budgetId,
    required bool isLocked,
  }) async {
    final currentData = state.value;
    if (currentData == null) return;

    try {
      // Optimistic update
      final updatedBudgets = currentData.categoryBudgets.map((budget) {
        if (budget.budgetId == budgetId) {
          return budget.copyWith(isLocked: isLocked);
        }
        return budget;
      }).toList();

      final updatedData = currentData.copyWith(categoryBudgets: updatedBudgets);
      state = AsyncData(updatedData);

      // Update in backend using balance service
      final balanceService = ref.read(balanceServiceProvider);
      await balanceService.toggleBudgetLock(budgetId, isLocked);
    } catch (e) {
      // Revert on error
      state = AsyncData(currentData);
    }
  }

  // Refresh current monthly balance
  Future<void> refresh() async {
    final currentData = state.value;
    if (currentData == null) return;

    state = const AsyncLoading();
    try {
      final service = ref.read(monthlyBalanceServiceProvider);
      final freshData = await service.getCurrentMonthlyBalance(currentData.userId);
      state = AsyncData(freshData);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}

// Monthly balance history provider
@riverpod
class MonthlyBalanceHistoryNotifier extends _$MonthlyBalanceHistoryNotifier {
  @override
  Future<List<MonthlyBalance>> build(String userId) async {
    final service = ref.watch(monthlyBalanceServiceProvider);
    return await service.getMonthlyBalanceHistory(userId);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final service = ref.read(monthlyBalanceServiceProvider);
      final history = await service.getMonthlyBalanceHistory(state.value?.first.userId ?? '');
      state = AsyncData(history);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}