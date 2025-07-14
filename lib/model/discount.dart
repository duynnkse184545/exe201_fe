class Discount {
  final String? discountId;
  final String? discountName;
  final double? discountPercentage;
  final bool? isActive;

  Discount({
    this.discountId,
    required this.discountName,
    required this.discountPercentage,
    required this.isActive,
  });

  factory Discount.fromJson(Map<String, dynamic> json) {
    return Discount(
      discountId: json['discountId'],
      discountName: json['discountName'],
      discountPercentage: (json['discountPercentage'] as num?)?.toDouble(),
      isActive: json['isActive'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'discountId': discountId,
      'discountName': discountName,
      'discountPercentage': discountPercentage,
      'isActive': isActive,
    };
  }
}