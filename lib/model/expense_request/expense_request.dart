import 'package:freezed_annotation/freezed_annotation.dart';

part 'expense_request.freezed.dart';
part 'expense_request.g.dart';

@freezed
abstract class ExpenseRequest with _$ExpenseRequest {
  const factory ExpenseRequest({
    required double amount,
    String? description,
    required String exCId, // Category ID determines if income/expense
    required String accountId,
  }) = _ExpenseRequest;

  factory ExpenseRequest.fromJson(Map<String, dynamic> json) =>
      _$ExpenseRequestFromJson(json);
}