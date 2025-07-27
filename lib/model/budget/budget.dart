import 'package:freezed_annotation/freezed_annotation.dart';
import '../expense/expense.dart';

part 'budget.freezed.dart';
part 'budget.g.dart';

@freezed
abstract class Budget with _$Budget {
  const factory Budget({
    required String budgetId,
    required String categoryId,
    required String accountId,
    required double budgetAmount,
    required DateTime startDate,
    required DateTime endDate,
    required String userId,
    @Default(0.0) double spentAmount, // Calculated by backend
    @Default(0.0) double remainingAmount, // Calculated by backend
    @Default(0.0) double spentPercentage, // Calculated by backend
    @Default(false) bool isOverBudget, // Calculated by backend
    @Default(false) bool isLocked, // User can lock budget amount for next month
    String? categoryName,
  }) = _Budget;

  factory Budget.fromJson(Map<String, dynamic> json) =>
      _$BudgetFromJson(json);
}

// Request model for creating and updating budgets
@freezed
abstract class BudgetRequest with _$BudgetRequest {
  const factory BudgetRequest({
    String? budgetId,
    required String? categoryId,
    required String? accountId,
    required double budgetAmount,
    required String? userId,
    @Default(false) bool isLocked,
  }) = _BudgetRequest;

  factory BudgetRequest.fromJson(Map<String, dynamic> json) =>
      _$BudgetRequestFromJson(json);
}

// Extensions for UI logic only (calculations now come from backend)
extension BudgetExtensions on Budget {
  // Check if budget period has ended (kept as this is UI logic, not calculation)
  bool get isPeriodEnded => DateTime.now().isAfter(endDate);
  
  // Note: unusedAmount is now just remainingAmount from backend
  // spentPercentage, isOverBudget are provided directly by backend
}