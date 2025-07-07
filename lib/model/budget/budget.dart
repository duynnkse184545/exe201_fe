import 'package:freezed_annotation/freezed_annotation.dart';
import '../expense/expense.dart';

part 'budget.freezed.dart';
part 'budget.g.dart';

@freezed
class Budget with _$Budget {
  const factory Budget({
    required String budgetId,
    required String categoryId,
    required String accountId,
    required double budgetAmount,
    required DateTime startDate,
    required DateTime endDate,
    required String userId,
    @Default(0.0) double spentAmount,
    @Default([]) List<Expense> recentExpenses,
    String? categoryName,
  }) = _Budget;

  factory Budget.fromJson(Map<String, dynamic> json) =>
      _$BudgetFromJson(json);
}

extension BudgetExtensions on Budget {
  double get remainingAmount => budgetAmount - spentAmount;
  double get spentPercentage => budgetAmount > 0 ? (spentAmount / budgetAmount) * 100 : 0;
  bool get isOverBudget => spentAmount > budgetAmount;
}