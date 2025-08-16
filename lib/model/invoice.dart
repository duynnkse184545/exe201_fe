import 'package:intl/intl.dart';

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

  // Helper methods for better data handling

  /// Gets the effective amount - prioritizes totalAmount, falls back to amount
  double get effectiveAmount => totalAmount ?? amount ?? 0.0;

  /// Gets a display-friendly description based on available data
  String get displayDescription {
    if (membershipPlanId != null) {
      return 'Membership Plan $membershipPlanId';
    } else if (invoiceStatus != null && invoiceStatus!.isNotEmpty) {
      return '${invoiceStatus!.toTitleCase()} Services';
    } else {
      return 'General Services';
    }
  }

  /// Gets payment method display name
  String get displayPaymentMethod {
    if (paymentMethodId == null || paymentMethodId!.isEmpty) {
      return 'Unknown Payment Method';
    }

    // Map common payment method IDs to display names
    switch (paymentMethodId!.toLowerCase()) {
      case 'credit_card':
      case 'creditcard':
      case 'card':
        return 'Credit Card';
      case 'paypal':
        return 'PayPal';
      case 'bank_transfer':
      case 'banktransfer':
        return 'Bank Transfer';
      case 'momo':
        return 'MoMo';
      case 'zalopay':
        return 'ZaloPay';
      case 'vnpay':
        return 'VNPay';
      default:
        return paymentMethodId!.toTitleCase();
    }
  }

  /// Formats the effective amount in VND currency
  String get formattedAmountVND {
    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    );
    return formatter.format(effectiveAmount);
  }

  /// Formats the effective amount in short VND format (e.g., 1.2M₫)
  String get formattedAmountVNDShort {
    final amount = effectiveAmount;
    if (amount >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(1)}B₫';
    } else if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M₫';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K₫';
    } else {
      final formatter = NumberFormat.currency(
        locale: 'vi_VN',
        symbol: '₫',
        decimalDigits: 0,
      );
      return formatter.format(amount);
    }
  }

  /// Gets the status with better formatting
  String get displayStatus {
    if (invoiceStatus == null || invoiceStatus!.isEmpty) {
      return 'Unknown';
    }
    return invoiceStatus!.toTitleCase();
  }

  /// Checks if the invoice is paid/completed
  bool get isPaid {
    if (invoiceStatus == null) return false;
    final status = invoiceStatus!.toLowerCase();
    return status == 'paid' || status == 'completed' || status == 'success';
  }

  /// Checks if the invoice is pending
  bool get isPending {
    if (invoiceStatus == null) return false;
    final status = invoiceStatus!.toLowerCase();
    return status == 'pending' || status == 'processing';
  }

  /// Checks if the invoice is failed/cancelled
  bool get isFailed {
    if (invoiceStatus == null) return false;
    final status = invoiceStatus!.toLowerCase();
    return status == 'failed' || status == 'cancelled' || status == 'rejected';
  }

  /// Gets formatted creation date
  String get formattedCreatedDate {
    if (createdDate == null) return 'Unknown date';
    return DateFormat('dd/MM/yyyy HH:mm').format(createdDate!);
  }

  /// Gets relative time since creation (e.g., "2 hours ago")
  String get relativeCreatedTime {
    if (createdDate == null) return 'Unknown time';

    final now = DateTime.now();
    final difference = now.difference(createdDate!);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}

// Extension for string formatting
extension StringExtension on String {
  String toTitleCase() {
    return split(' ')
        .map((word) => word.isEmpty
        ? word
        : word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }
}