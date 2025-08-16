import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../service/api/assignment_service.dart';
import '../service/api/event_category_service.dart';
import '../service/api/event_service.dart';
import '../service/api/subject_service.dart';
import '../service/api/priority_level_service.dart';
import '../service/api/ai_service.dart';
import '../service/financial/services.dart';
import '../service/storage/balance_storage.dart';
import '../service/api/user_service.dart';
import '../service/storage/token_storage.dart';
import '../service/api/invoice_service.dart';

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

@riverpod
MonthlySummaryService monthlySummaryService(Ref ref) {
  return MonthlySummaryService();
}

@riverpod
EventService eventService(Ref ref) {
  return EventService();
}

@riverpod
AssignmentService assignmentService(Ref ref) {
  return AssignmentService();
}

@riverpod
EventCategoryService eventCategoryService(Ref ref) {
  return EventCategoryService();
}

@riverpod
SubjectService subjectService(Ref ref) {
  return SubjectService();
}

@riverpod
PriorityLevelService priorityLevelService(Ref ref) {
  return PriorityLevelService();
}

@riverpod
AIServiceApi aiService(Ref ref) {
  return AIServiceApi();
}

@riverpod
UserService userService(Ref ref) {
  return UserService();
}

@riverpod
InvoiceService invoiceService(Ref ref) {
  return InvoiceService();
}

@riverpod
TokenStorage tokenStorage(Ref ref) {
  return TokenStorage();
}
