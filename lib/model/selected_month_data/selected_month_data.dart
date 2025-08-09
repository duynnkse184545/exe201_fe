import 'package:freezed_annotation/freezed_annotation.dart';
import '../balance/balance.dart';
import '../budget/budget.dart';
import '../expense/expense.dart';
import '../monthly_summary/monthly_summary.dart';

part 'selected_month_data.freezed.dart';
part 'selected_month_data.g.dart';

// Data class to unify balance and summary data for selected month
@freezed
abstract class SelectedMonthData with _$SelectedMonthData {
  const factory SelectedMonthData({
    required int year,
    required int month,
    required bool isCurrentMonth,
    required double availableBalance,
    required double totalBudgetAllocated,
    required double initialBalance,
    required List<Budget> budgets,
    required List<Expense> transactions,
    required double totalIncome,
    required double totalExpenses,
    required double netAmount,
  }) = _SelectedMonthData;
  
  factory SelectedMonthData.fromJson(Map<String, dynamic> json) =>
      _$SelectedMonthDataFromJson(json);
  
  factory SelectedMonthData.fromBalance(Balance balance, {required bool isCurrentMonth}) {
    // Calculate initial balance from all accounts
    final initialBalance = balance.accounts.fold<double>(0.0, (sum, account) => sum + account.balance);
    
    // Calculate total allocated from all budgets
    final totalBudgetAllocated = balance.budgets.fold<double>(0.0, (sum, budget) => sum + budget.budgetAmount);
    
    return SelectedMonthData(
      year: DateTime.now().year,
      month: DateTime.now().month,
      isCurrentMonth: isCurrentMonth,
      availableBalance: balance.availableBalance,
      totalBudgetAllocated: totalBudgetAllocated,
      initialBalance: initialBalance,
      budgets: balance.budgets,
      transactions: balance.expenses,
      totalIncome: balance.monthlyIncome,
      totalExpenses: balance.monthlyExpenses,
      netAmount: balance.netSavings,
    );
  }
  
  factory SelectedMonthData.fromSummary(MonthlySummary summary, {required bool isCurrentMonth}) {
    return SelectedMonthData(
      year: summary.year,
      month: summary.month,
      isCurrentMonth: isCurrentMonth,
      availableBalance: 0.0, // Always 0 for non-current months
      totalBudgetAllocated: summary.categoryBreakdown.fold(0.0, (sum, budget) => sum + budget.budgetAmount),
      initialBalance: 0.0, // Historical, not relevant
      budgets: summary.categoryBreakdown,
      transactions: summary.transactions,
      totalIncome: summary.totalIncome,
      totalExpenses: summary.totalExpenses,
      netAmount: summary.netAmount,
    );
  }
  
  factory SelectedMonthData.empty(int year, int month) {
    return SelectedMonthData(
      year: year,
      month: month,
      isCurrentMonth: false,
      availableBalance: 0.0,
      totalBudgetAllocated: 0.0,
      initialBalance: 0.0,
      budgets: [],
      transactions: [],
      totalIncome: 0.0,
      totalExpenses: 0.0,
      netAmount: 0.0,
    );
  }
}

// Helper extensions
extension SelectedMonthDataExtensions on SelectedMonthData {
  String get monthName {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
  
  bool get hasData => budgets.isNotEmpty || transactions.isNotEmpty;
  
  bool get isPastMonth {
    final now = DateTime.now();
    final selectedDate = DateTime(year, month);
    final currentDate = DateTime(now.year, now.month);
    return selectedDate.isBefore(currentDate);
  }
  
  bool get isFutureMonth {
    final now = DateTime.now();
    final selectedDate = DateTime(year, month);
    final currentDate = DateTime(now.year, now.month);
    return selectedDate.isAfter(currentDate);
  }
}