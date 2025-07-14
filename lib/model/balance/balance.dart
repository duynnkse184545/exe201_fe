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
    @Default([]) List<Expense> recentTransactions,
    @Default([]) List<FinancialAccount> accounts,
    @Default(false) bool isLoading,
    String? error,
  }) = _Balance;

  factory Balance.fromJson(Map<String, dynamic> json) =>
      _$BalanceFromJson(json);
}

extension BalanceExtensions on Balance {
  double get netSavings => monthlyIncome - monthlyExpenses;
  
  List<Expense> getRecentTransactionsForCategory(String categoryId) {
    return recentTransactions
        .where((expense) => expense.exCId == categoryId)
        .take(5)
        .toList();
  }
}