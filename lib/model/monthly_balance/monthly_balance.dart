import 'package:freezed_annotation/freezed_annotation.dart';
import '../budget/budget.dart';

part 'monthly_balance.freezed.dart';
part 'monthly_balance.g.dart';

@freezed
abstract class MonthlyBalance with _$MonthlyBalance {
  const factory MonthlyBalance({
    required String balanceId,
    required String userId,
    required DateTime month, // First day of month (2024-01-01)
    required double initialBalance, // User sets this at start of month
    required double totalBudgetAllocated, // Sum of all budget limits
    required double remainingForSavings, // initialBalance - totalBudgetAllocated
    required double actualSaved, // Calculated at month end
    @Default([]) List<Budget> categoryBudgets, // Budgets for this month
    @Default([]) List<QueuedIncome> queuedIncomes, // Income waiting for next month
    @Default(false) bool isActive, // Current month
    // Backend-calculated values
    @Default(0.0) double totalUnusedBudget, // Provided by backend
    @Default(0.0) double totalCarryOverToNextBalance, // Provided by backend
    @Default(0.0) double nextMonthInitialBalance, // Provided by backend
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _MonthlyBalance;

  factory MonthlyBalance.fromJson(Map<String, dynamic> json) =>
      _$MonthlyBalanceFromJson(json);
}

// Request model for creating and updating monthly balance
@freezed
abstract class MonthlyBalanceRequest with _$MonthlyBalanceRequest {
  const factory MonthlyBalanceRequest({
    String? balanceId, // null for create, required for update
    required DateTime month,
    required double initialBalance,
    required String userId,
    required List<BudgetRequest> budgetAllocations,
  }) = _MonthlyBalanceRequest;

  factory MonthlyBalanceRequest.fromJson(Map<String, dynamic> json) =>
      _$MonthlyBalanceRequestFromJson(json);
}

extension MonthlyBalanceExtensions on MonthlyBalance {
  // Check if month is completed (kept as this is UI logic, not calculation)
  bool get isCompleted {
    final now = DateTime.now();
    final nextMonth = DateTime(month.year, month.month + 1, 1);
    return now.isAfter(nextMonth);
  }
  
  // Note: totalUnusedBudget, totalCarryOverToNextBalance, and nextMonthInitialBalance 
  // are now provided directly by backend as model properties
}

@freezed
abstract class QueuedIncome with _$QueuedIncome {
  const factory QueuedIncome({
    required String incomeId,
    required double amount,
    required String description,
    required String incomeCategoryId,
    required DateTime receivedDate,
    required String userId,
    @Default(false) bool isProcessed, // Added to next month's balance
  }) = _QueuedIncome;

  factory QueuedIncome.fromJson(Map<String, dynamic> json) =>
      _$QueuedIncomeFromJson(json);
}

// Request model for creating and updating queued income
@freezed
abstract class QueuedIncomeRequest with _$QueuedIncomeRequest {
  const factory QueuedIncomeRequest({
    String? incomeId, // null for create, required for update
    required double amount,
    required String description,
    required String incomeCategoryId,
    required String userId,
  }) = _QueuedIncomeRequest;

  factory QueuedIncomeRequest.fromJson(Map<String, dynamic> json) =>
      _$QueuedIncomeRequestFromJson(json);
}

// Request model for adding income (alias for QueuedIncomeRequest)
typedef AddIncomeRequest = QueuedIncomeRequest;