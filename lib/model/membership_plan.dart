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

  // Helper methods để format dữ liệu cho UI
  String get formattedPrice {
    return '${price!.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}đ';
  }

  String get durationText {
    if (durationDays! >= 365) {
      int years = (durationDays! / 365).floor();
      return '/$years năm';
    } else if (durationDays! >= 30) {
      int months = (durationDays! / 30).floor();
      return '/$months tháng';
    } else {
      return '/$durationDays ngày';
    }
  }

  // Method để lấy features dựa trên plan name (có thể customize)
  List<String> get features {
    switch (planName!.toLowerCase()) {
      case 'basic':
        return [
          'Quản lý thu chi cơ bản',
          'Tạo kế hoạch hàng tháng',
          'Thông báo nhắc nhở',
          'Báo cáo chi tiêu tổng quan',
          'Sử dụng AI quản lý',
        ];
      case 'premium':
        return [
          'Tất cả tính năng Basic',
          'Phân tích chi tiêu chi tiết',
          'Lập kế hoạch tự động',
          'Hỗ trợ ưu tiên 24/7',
          'Sử dụng chatbot quản lý',
        ];
      case 'vip':
        return [
          'Tất cả tính năng Premium',
          'Truy cập sớm nội dung mới',
          'Thiết bị không giới hạn',
          'Tùy chỉnh giao diện',
          'Phân tích chi tiết',
          'Quản lý đa tài khoản',
          'Tư vấn 1-1',
        ];
      default:
        return [
          'Các tính năng cơ bản',
          'Hỗ trợ khách hàng',
        ];
    }
  }

  // Method để lấy màu dựa trên plan name
  int get colorValue {
    switch (planName!.toLowerCase()) {
      case 'basic':
        return 0xFF4CAF50; // Green
      case 'premium':
        return 0xFF7B68EE; // Purple
      case 'vip':
        return 0xFFFF6B6B; // Red
      default:
        return 0xFF2196F3; // Blue
    }
  }

  // Method để check plan phổ biến
  bool get isPopular {
    return planName!.toLowerCase() == 'premium';
  }
}