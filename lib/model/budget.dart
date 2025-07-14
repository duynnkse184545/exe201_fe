class Budget{
  final String? budgetId;
  final String? categoryId;
  final String? accountId;
  final double? budgetAmount;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? userId;

  Budget({
    this.budgetId,
    required this.categoryId,
    required this.accountId,
    required this.budgetAmount,
    this.startDate,
    this.endDate,
    required this.userId,
  });

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      budgetId: json['budgetId'],
      categoryId: json['categoryId'],
      accountId: json['accountId'],
      budgetAmount: (json['budgetAmount'] as num?)?.toDouble(),
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'budgetId': budgetId,
      'categoryId': categoryId,
      'accountId': accountId,
      'budgetAmount': budgetAmount,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'userId': userId,
    };
  }
}