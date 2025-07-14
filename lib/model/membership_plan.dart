class MembershipPlan {
  final String? mPid;
  final String? planName;
  final double? price;
  final int? durationDays;

  MembershipPlan({
    this.mPid,
    required this.planName,
    required this.price,
    required this.durationDays,
  });

  factory MembershipPlan.fromJson(Map<String, dynamic> json) {
    return MembershipPlan(
      mPid: json['mPid'],
      planName: json['planName'],
      price: (json['price'] as num?)?.toDouble(),
      durationDays: json['durationDays'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mPid': mPid,
      'planName': planName,
      'price': price,
      'durationDays': durationDays,
    };
  }
}