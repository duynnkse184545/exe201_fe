class Invoice {
  final String? invoiceId;
  final double? amount;
  final double? taxAmount;
  final double? discountAmount;
  final double? totalAmount;
  final String? paymentMethodId;
  final String? gatewayTransactionId;
  final DateTime? createdDate;
  final DateTime? updatedDate;
  final String? invoiceStatus;
  final String? userId;
  final String? discountId;
  final String? membershipPlanId;

  Invoice({
    this.invoiceId,
    required this.amount,
    required this.taxAmount,
    required this.discountAmount,
    required this.totalAmount,
    required this.paymentMethodId,
    this.gatewayTransactionId,
    this.createdDate,
    this.updatedDate,
    required this.invoiceStatus,
    required this.userId,
    this.discountId,
    this.membershipPlanId,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      invoiceId: json['invoiceId'],
      amount: (json['amount'] as num?)?.toDouble(),
      taxAmount: (json['taxAmount'] as num?)?.toDouble(),
      discountAmount: (json['discountAmount'] as num?)?.toDouble(),
      totalAmount: (json['totalAmount'] as num?)?.toDouble(),
      paymentMethodId: json['paymentMethodId'],
      gatewayTransactionId: json['gatewayTransactionId'],
      createdDate: json['createdDate'] != null ? DateTime.parse(json['createdDate']) : null,
      updatedDate: json['updatedDate'] != null ? DateTime.parse(json['updatedDate']) : null,
      invoiceStatus: json['invoiceStatus'],
      userId: json['userId'],
      discountId: json['discountId'],
      membershipPlanId: json['membershipPlanId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'invoiceId': invoiceId,
      'amount': amount,
      'taxAmount': taxAmount,
      'discountAmount': discountAmount,
      'totalAmount': totalAmount,
      'paymentMethodId': paymentMethodId,
      'gatewayTransactionId': gatewayTransactionId,
      'createdDate': createdDate?.toIso8601String(),
      'updatedDate': updatedDate?.toIso8601String(),
      'invoiceStatus': invoiceStatus,
      'userId': userId,
      'discountId': discountId,
      'membershipPlanId': membershipPlanId,
    };
  }
}