class FinancialAccount {
  final String? accountId;
  final String? accountName;
  final double? balance;
  final String? currencyCode;
  final String? userId;
  final bool? isDefault;

  FinancialAccount({
    this.accountId,
    required this.accountName,
    required this.balance,
    required this.currencyCode,
    required this.userId,
    required this.isDefault,
  });

  factory FinancialAccount.fromJson(Map<String, dynamic> json) {
    return FinancialAccount(
      accountId: json['accountId'],
      accountName: json['accountName'],
      balance: (json['balance'] as num?)?.toDouble(),
      currencyCode: json['currencyCode'],
      userId: json['userId'],
      isDefault: json['isDefault'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accountId': accountId,
      'accountName': accountName,
      'balance': balance,
      'currencyCode': currencyCode,
      'userId': userId,
      'isDefault': isDefault,
    };
  }
}