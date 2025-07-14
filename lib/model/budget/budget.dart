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
    @Default([]) List<Expense> recentExpenses,
    String? categoryName,
  }) = _Budget;

  factory Budget.fromJson(Map<String, dynamic> json) =>
      _$BudgetFromJson(json);
}

// Extensions for backward compatibility (values now come from backend)
extension BudgetExtensions on Budget {
  // Amount unused (will be added to next month's balance, not budget)
  double get unusedAmount => remainingAmount > 0 ? remainingAmount : 0;
  
  // Check if budget period has ended
  bool get isPeriodEnded => DateTime.now().isAfter(endDate);
}