import 'package:freezed_annotation/freezed_annotation.dart';

part 'financial_account.freezed.dart';
part 'financial_account.g.dart';

@freezed
abstract class FinancialAccount with _$FinancialAccount {
  const factory FinancialAccount({
    required String accountId,
    required String accountName,
    required double balance,
    @Default('VND') String currencyCode,
    required String userId,
    @Default(false) bool isDefault,
  }) = _FinancialAccount;

  factory FinancialAccount.fromJson(Map<String, dynamic> json) =>
      _$FinancialAccountFromJson(json);
}

// Request model for creating and updating financial accounts
@freezed
abstract class FinancialAccountRequest with _$FinancialAccountRequest {
  const factory FinancialAccountRequest({
    String? accountId, // null for create, required for update
    required String accountName,
    required double balance,
    @Default('VND') String currencyCode,
    required String userId,
    @Default(false) bool isDefault,
  }) = _FinancialAccountRequest;

  factory FinancialAccountRequest.fromJson(Map<String, dynamic> json) =>
      _$FinancialAccountRequestFromJson(json);
}