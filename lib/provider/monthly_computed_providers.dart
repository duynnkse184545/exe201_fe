import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../model/models.dart';
import 'monthly_balance_provider.dart';
import 'service_providers.dart';

part 'monthly_computed_providers.g.dart';

// Available balance (simplified name for easier migration)
@riverpod
double availableBalance(Ref ref, String userId) {
  final monthlyBalanceAsync = ref.watch(currentMonthlyBalanceNotifierProvider(userId));
  return monthlyBalanceAsync.when(
    data: (data) => data?.remainingForSavings ?? 0.0,
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
}

// Current month's available balance (detailed name)
@riverpod
double currentMonthAvailableBalance(Ref ref, String userId) {
  final monthlyBalanceAsync = ref.watch(currentMonthlyBalanceNotifierProvider(userId));
  return monthlyBalanceAsync.when(
    data: (data) => data?.remainingForSavings ?? 0.0,
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
}

// Current month's total budget allocated
@riverpod
double currentMonthTotalBudgetAllocated(Ref ref, String userId) {
  final monthlyBalanceAsync = ref.watch(currentMonthlyBalanceNotifierProvider(userId));
  return monthlyBalanceAsync.when(
    data: (data) => data?.totalBudgetAllocated ?? 0.0,
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
}

// Current month's initial balance
@riverpod
double currentMonthInitialBalance(Ref ref, String userId) {
  final monthlyBalanceAsync = ref.watch(currentMonthlyBalanceNotifierProvider(userId));
  return monthlyBalanceAsync.when(
    data: (data) => data?.initialBalance ?? 0.0,
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
}

// Current month's budgets
@riverpod
List<Budget> currentMonthBudgets(Ref ref, String userId) {
  final monthlyBalanceAsync = ref.watch(currentMonthlyBalanceNotifierProvider(userId));
  return monthlyBalanceAsync.when(
    data: (data) => data?.categoryBudgets ?? [],
    loading: () => [],
    error: (_, __) => [],
  );
}

// Current month's locked budgets (for next month)
@riverpod
List<Budget> lockedBudgets(Ref ref, String userId) {
  final budgets = ref.watch(currentMonthBudgetsProvider(userId));
  return budgets.where((budget) => budget.isLocked).toList();
}

// Current month's unlocked budgets
@riverpod
List<Budget> unlockedBudgets(Ref ref, String userId) {
  final budgets = ref.watch(currentMonthBudgetsProvider(userId));
  return budgets.where((budget) => !budget.isLocked).toList();
}

// Budget for specific category
@riverpod
Budget? budgetForCategory(Ref ref, String userId, String categoryId) {
  final budgets = ref.watch(currentMonthBudgetsProvider(userId));
  try {
    return budgets.firstWhere((budget) => budget.categoryId == categoryId);
  } catch (e) {
    return null;
  }
}

// Current month's queued income
@riverpod
List<QueuedIncome> currentMonthQueuedIncome(Ref ref, String userId) {
  final monthlyBalanceAsync = ref.watch(currentMonthlyBalanceNotifierProvider(userId));
  return monthlyBalanceAsync.when(
    data: (data) => data?.queuedIncomes ?? [],
    loading: () => [],
    error: (_, __) => [],
  );
}

// Total queued income amount
@riverpod
double totalQueuedIncomeAmount(Ref ref, String userId) {
  final queuedIncomes = ref.watch(currentMonthQueuedIncomeProvider(userId));
  final unprocessedIncomes = queuedIncomes.where((income) => !income.isProcessed);
  double total = 0.0;
  for (final income in unprocessedIncomes) {
    total += income.amount;
  }
  return total;
}

// Next month's projected initial balance (from backend)
@riverpod
double nextMonthProjectedBalance(Ref ref, String userId) {
  final monthlyBalanceAsync = ref.watch(currentMonthlyBalanceNotifierProvider(userId));
  return monthlyBalanceAsync.when(
    data: (data) => data?.nextMonthInitialBalance ?? 0.0,
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
}

// Current month's total unused budget amount (from backend)
@riverpod
double totalUnusedBudgetAmount(Ref ref, String userId) {
  final monthlyBalanceAsync = ref.watch(currentMonthlyBalanceNotifierProvider(userId));
  return monthlyBalanceAsync.when(
    data: (data) => data?.totalUnusedBudget ?? 0.0,
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
}

// Current month's carry over amount to next balance
@riverpod
double carryOverToNextBalance(Ref ref, String userId) {
  final monthlyBalanceAsync = ref.watch(currentMonthlyBalanceNotifierProvider(userId));
  return monthlyBalanceAsync.when(
    data: (data) => data?.totalCarryOverToNextBalance ?? 0.0,
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
}

// Budget health for current month - now uses backend data
@riverpod
Future<Map<String, int>> currentMonthBudgetHealth(Ref ref, String userId) async {
  final balanceService = ref.watch(balanceServiceProvider);
  return await balanceService.getBudgetHealth(userId);
}

// Check if current month is completed
@riverpod
bool isCurrentMonthCompleted(Ref ref, String userId) {
  final monthlyBalanceAsync = ref.watch(currentMonthlyBalanceNotifierProvider(userId));
  return monthlyBalanceAsync.when(
    data: (data) => data?.isCompleted ?? false,
    loading: () => false,
    error: (_, __) => false,
  );
}

// Monthly savings history (last 6 months)
@riverpod
List<double> monthlySavingsHistory(Ref ref, String userId) {
  final historyAsync = ref.watch(monthlyBalanceHistoryNotifierProvider(userId));
  return historyAsync.when(
    data: (history) => history
        .take(6)
        .map((balance) => balance.actualSaved)
        .toList(),
    loading: () => [],
    error: (_, _) => [],
  );
}