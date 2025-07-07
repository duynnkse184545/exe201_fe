import 'package:freezed_annotation/freezed_annotation.dart';
import '../expense/expense.dart';

part 'expense_request.freezed.dart';
part 'expense_request.g.dart';

@freezed
class ExpenseRequest with _$ExpenseRequest {
  const factory ExpenseRequest({
    required double amount,
    String? description,
    required ExpenseType type,
    @Default(ExpenseFrequency.once) ExpenseFrequency frequency,
    DateTime? nextDueDate,
    required String exCId,
    required String accountId,
  }) = _ExpenseRequest;

  factory ExpenseRequest.fromJson(Map<String, dynamic> json) =>
      _$ExpenseRequestFromJson(json);
}