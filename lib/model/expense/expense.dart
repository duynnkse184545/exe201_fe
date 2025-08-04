import 'package:freezed_annotation/freezed_annotation.dart';

part 'expense.freezed.dart';
part 'expense.g.dart';

@freezed
abstract class Expense with _$Expense {
  const factory Expense({
    required String expensesId,
    required double amount,
    String? description,
    required DateTime createdDate,
    required String exCid,
    required String accountId,
    required String userId,
    String? categoryName,
  }) = _Expense;

  factory Expense.fromJson(Map<String, dynamic> json) =>
      _$ExpenseFromJson(json);
}

// Request model for creating and updating expenses
@freezed
abstract class ExpenseRequest with _$ExpenseRequest {
  const factory ExpenseRequest({
    String? expensesId,
    required double amount,
    String? description,
    required String exCid,
    required String accountId,
  }) = _ExpenseRequest;

  factory ExpenseRequest.fromJson(Map<String, dynamic> json) =>
      _$ExpenseRequestFromJson(json);
}