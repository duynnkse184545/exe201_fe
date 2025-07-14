class Investment {
  final String? investmentId;
  final String? investmentName;
  final double? amount;
  final DateTime? investmentDate;
  final DateTime? maturityDate;
  final double? interestRate;
  final String? userId;

  Investment({
    this.investmentId,
    required this.investmentName,
    required this.amount,
    this.investmentDate,
    this.maturityDate,
    required this.interestRate,
    required this.userId,
  });

  factory Investment.fromJson(Map<String, dynamic> json) {
    return Investment(
      investmentId: json['investmentId'],
      investmentName: json['investmentName'],
      amount: (json['amount'] as num?)?.toDouble(),
      investmentDate: json['investmentDate'] != null ? DateTime.parse(json['investmentDate']) : null,
      maturityDate: json['maturityDate'] != null ? DateTime.parse(json['maturityDate']) : null,
      interestRate: (json['interestRate'] as num?)?.toDouble(),
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'investmentId': investmentId,
      'investmentName': investmentName,
      'amount': amount,
      'investmentDate': investmentDate?.toIso8601String(),
      'maturityDate': maturityDate?.toIso8601String(),
      'interestRate': interestRate,
      'userId': userId,
    };
  }
}