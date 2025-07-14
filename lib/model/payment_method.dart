class PaymentMethod {
  final String? methodId;
  final String? methodName;
  final bool? isActive;

  PaymentMethod({
    this.methodId,
    required this.methodName,
    required this.isActive,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      methodId: json['methodId'],
      methodName: json['methodName'],
      isActive: json['isActive'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'methodId': methodId,
      'methodName': methodName,
      'isActive': isActive,
    };
  }
}