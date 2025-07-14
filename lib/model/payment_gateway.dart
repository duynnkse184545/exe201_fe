class PaymentGateway {
  final String? gatewayId;
  final String? gatewayName;
  final String? apiKey;
  final bool? isActive;

  PaymentGateway({
    this.gatewayId,
    required this.gatewayName,
    required this.apiKey,
    required this.isActive,
  });

  factory PaymentGateway.fromJson(Map<String, dynamic> json) {
    return PaymentGateway(
      gatewayId: json['gatewayId'],
      gatewayName: json['gatewayName'],
      apiKey: json['apiKey'],
      isActive: json['isActive'],
    );
  }
}