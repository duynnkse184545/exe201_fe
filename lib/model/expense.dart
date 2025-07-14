class Expense {
  final String? expenseId;
  final double? amount;
  final String? description;
  final DateTime? createdDate;
  final String? type;
  final String? frequency;
  final DateTime? nextDueDate;
  final String? exCid;
  final String? accountId;
  final String? userId;

  Expense({
    this.expenseId,
    required this.amount,
    this.description,
    this.createdDate,
    required this.type,
    required this.frequency,
    this.nextDueDate,
    required this.exCid,
    required this.accountId,
    required this.userId,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      expenseId: json['expenseId'],
      amount: (json['amount'] as num?)?.toDouble(),
      description: json['description'],
      createdDate: json['createdDate'] != null ? DateTime.parse(json['createdDate']) : null,
      type: json['type'],
      frequency: json['frequency'],
      nextDueDate: json['nextDueDate'] != null ? DateTime.parse(json['nextDueDate']) : null,
      exCid: json['exCid'],
      accountId: json['accountId'],
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'expenseId': expenseId,
      'amount': amount,
      'description': description,
      'createdDate': createdDate?.toIso8601String(),
      'type': type,
      'frequency': frequency,
      'nextDueDate': nextDueDate?.toIso8601String(),
      'exCid': exCid,
      'accountId': accountId,
      'userId': userId,
    };
  }
}