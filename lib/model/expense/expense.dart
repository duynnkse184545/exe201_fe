import 'package:freezed_annotation/freezed_annotation.dart';

part 'expense.freezed.dart';
part 'expense.g.dart';

@freezed
class Expense with _$Expense {
  const factory Expense({
    required String expensesId,
    required double amount,
    String? description,
    required DateTime createdDate,
    required ExpenseType type,
    @Default(ExpenseFrequency.once) ExpenseFrequency frequency,
    DateTime? nextDueDate,
    required String exCId,
    required String accountId,
    required String userId,
    String? categoryName,
  }) = _Expense;

  factory Expense.fromJson(Map<String, dynamic> json) =>
      _$ExpenseFromJson(json);
}

enum ExpenseType {
  @JsonValue('income')
  income,
  @JsonValue('expense')
  expense,
}

enum ExpenseFrequency {
  @JsonValue('once')
  once,
  @JsonValue('daily')
  daily,
  @JsonValue('weekly')
  weekly,
  @JsonValue('monthly')
  monthly,
}