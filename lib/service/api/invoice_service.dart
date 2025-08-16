import 'package:exe201/model/invoice.dart';

import '../api/base/generic_handler.dart';


class InvoiceService extends ApiService<Invoice, String> {
  InvoiceService() : super(endpoint: '/api/Invoice');

  @override
  Invoice fromJson(Map<String, dynamic> json) => Invoice.fromJson(json);

  @override
  Map<String, dynamic> toJson(dynamic data) {
    if (data is Invoice) return data.toJson();
    if (data is Map<String, dynamic>) return data;
    throw ArgumentError('Unsupported data type for toJson: ${data.runtimeType}');
  }

  Future<List<Invoice>> getUserInvoice() async {
    try {
      final response = await dio.get('$endpoint/current-user');
      final List<dynamic> dataList = response.data['data'];
      return dataList.map((e) => fromJson(e as Map<String, dynamic>)).toList();
    } catch (e, stackTrace) {
      print('ERROR: Failed in getInvoice: $e');
      print('ERROR: Stack trace: $stackTrace');
      throw Exception('Failed to get Invoice data: $e');
    }
  }

  /// Admin method: Get all invoices (uses existing backend method)
  Future<List<Invoice>> getAllInvoices() async {
    try {
      final response = await dio.get('$endpoint');
      final List<dynamic> dataList = response.data['data'];
      return dataList.map((e) => fromJson(e as Map<String, dynamic>)).toList();
    } catch (e, stackTrace) {
      print('ERROR: Failed in getAllInvoices: $e');
      print('ERROR: Stack trace: $stackTrace');
      throw Exception('Failed to get all invoices: $e');
    }
  }

  /// Calculate revenue statistics from invoice data
  Map<String, dynamic> calculateRevenueStatistics(List<Invoice> invoices) {
    if (invoices.isEmpty) {
      return {
        'totalRevenue': 0.0,
        'monthlyRecurringRevenue': 0.0,
        'averageRevenuePerUser': 0.0,
        'revenueGrowthPercentage': 0.0,
      };
    }

    final totalRevenue = invoices.fold<double>(0, (sum, invoice) => sum + (invoice.totalAmount ?? 0));
    final currentMonth = DateTime.now().month;
    final currentYear = DateTime.now().year;
    
    final monthlyInvoices = invoices.where((invoice) => 
      invoice.createdDate?.month == currentMonth && 
      invoice.createdDate?.year == currentYear
    ).toList();
    
    final monthlyRevenue = monthlyInvoices.fold<double>(0, (sum, invoice) => sum + (invoice.totalAmount ?? 0));
    
    final uniqueUsers = invoices.map((invoice) => invoice.userId).toSet().length;
    final averageRevenuePerUser = uniqueUsers > 0 ? totalRevenue / uniqueUsers : 0.0;

    return {
      'totalRevenue': totalRevenue,
      'monthlyRecurringRevenue': monthlyRevenue,
      'averageRevenuePerUser': averageRevenuePerUser,
      'revenueGrowthPercentage': 15.0, // Mock growth percentage
    };
  }

  /// Calculate revenue growth data from invoices
  List<Map<String, dynamic>> calculateRevenueGrowthData(List<Invoice> invoices) {
    final Map<int, double> monthlyRevenue = {};
    
    for (final invoice in invoices) {
      if (invoice.createdDate != null) {
        final month = invoice.createdDate!.month;
        monthlyRevenue[month] = (monthlyRevenue[month] ?? 0) + (invoice.totalAmount ?? 0);
      }
    }

    return List.generate(12, (index) {
      final month = index + 1;
      return {
        'month': month,
        'revenue': monthlyRevenue[month] ?? 0.0,
      };
    });
  }

  /// Calculate financial metrics from invoices
  Map<String, dynamic> calculateFinancialMetrics(List<Invoice> invoices) {
    if (invoices.isEmpty) {
      return {
        'averageRevenuePerUser': 0.0,
        'customerLifetimeValue': 0.0,
        'monthlyRecurringRevenue': 0.0,
        'churnRate': 0.0,
      };
    }

    final revenueStats = calculateRevenueStatistics(invoices);
    
    return {
      'averageRevenuePerUser': revenueStats['averageRevenuePerUser'],
      'customerLifetimeValue': (revenueStats['averageRevenuePerUser'] as double) * 12, // Estimate CLV
      'monthlyRecurringRevenue': revenueStats['monthlyRecurringRevenue'],
      'churnRate': 2.5, // Mock churn rate
    };
  }

}