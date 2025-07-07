import 'package:freezed_annotation/freezed_annotation.dart';

part 'financial_account.freezed.dart';
part 'financial_account.g.dart';

@freezed
class FinancialAccount with _$FinancialAccount {
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