import 'package:freezed_annotation/freezed_annotation.dart';

part 'budget_request.freezed.dart';
part 'budget_request.g.dart';

@freezed
class BudgetRequest with _$BudgetRequest {
  const factory BudgetRequest({
    required String categoryId,
    required String accountId,
    required double budgetAmount,
    required DateTime startDate,
    required DateTime endDate,
  }) = _BudgetRequest;

  factory BudgetRequest.fromJson(Map<String, dynamic> json) =>
      _$BudgetRequestFromJson(json);
}