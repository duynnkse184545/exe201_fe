import 'package:freezed_annotation/freezed_annotation.dart';
import '../budget/budget.dart';
import '../expense/expense.dart';
import '../financial_account/financial_account.dart';

part 'balance.freezed.dart';
part 'balance.g.dart';

@freezed
abstract class Balance with _$Balance {
  const factory Balance({
    required String userId,
    required double availableBalance,
    required double monthlyIncome,
    required double monthlyExpenses,
    required DateTime lastUpdated,
    @Default([]) List<Budget> budgets,
    @Default([]) List<FinancialAccount> accounts,
    @Default([]) List<Expense> expenses,
    @Default(false) bool isLoading,
    String? error,
  }) = _Balance;

  factory Balance.fromJson(Map<String, dynamic> json) =>
      _$BalanceFromJson(json);
}

extension BalanceExtensions on Balance {
  double get netSavings => monthlyIncome - monthlyExpenses;
  
  // Note: recentTransactions removed from backend response
  // Use BalanceService.getRecentTransactions() and filterTransactionsByCategory() instead
}