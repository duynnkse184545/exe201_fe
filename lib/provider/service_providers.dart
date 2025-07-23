import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../service/financial/services.dart';
import '../service/storage/balance_storage.dart';

part 'service_providers.g.dart';

// Storage provider
@riverpod
BalanceStorage balanceStorage(Ref ref) {
  return BalanceStorage();
}

// Service providers (only the ones we kept)
@riverpod
BalanceService balanceService(Ref ref) {
  return BalanceService();
}

@riverpod
ExpenseCategoryService expenseCategoryService(Ref ref) {
  return ExpenseCategoryService();
}

@riverpod
FinancialAccountService financialAccountService(Ref ref) {
  return FinancialAccountService();
}

@riverpod
MonthlyBalanceService monthlyBalanceService(Ref ref) {
  return MonthlyBalanceService();
}

@riverpod
ExpenseService expenseService(Ref ref) {
  return ExpenseService();
}

@riverpod
BudgetService budgetService(Ref ref) {
  return BudgetService();
}