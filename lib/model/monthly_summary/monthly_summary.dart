import 'package:freezed_annotation/freezed_annotation.dart';
import '../budget/budget.dart';
import '../expense/expense.dart';

part 'monthly_summary.freezed.dart';
part 'monthly_summary.g.dart';

@freezed
abstract class MonthlySummary with _$MonthlySummary {
  const factory MonthlySummary({
    required String userId,
    required int year,
    required int month,
    required double totalIncome,
    required double totalExpenses,
    required double netAmount,
    required int transactionCount,
    @Default([]) List<Budget> categoryBreakdown, // Using existing Budget model (EnhancedBudgetDto)
    @Default([]) List<Expense> transactions, // Using existing Expense model like Balance
  }) = _MonthlySummary;

  factory MonthlySummary.fromJson(Map<String, dynamic> json) =>
      _$MonthlySummaryFromJson(json);
}

// Extensions for UI logic
extension MonthlySummaryExtensions on MonthlySummary {
  String get monthName {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
  
  bool get hasPositiveNet => netAmount > 0;
  
  double get savingsRate => totalIncome > 0 ? (netAmount / totalIncome) * 100 : 0;
  
  // Get expense categories only (filter out any income categories)
  List<Budget> get expenseCategories => categoryBreakdown
      .where((budget) => budget.spentAmount > 0 || budget.budgetAmount > 0)
      .toList();
}