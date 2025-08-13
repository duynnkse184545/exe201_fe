import 'package:exe201/model/invoice.dart';

import '../api/base/generic_handler.dart';
import '../api/base/id_generator.dart';
import '../../model/expense_category/expense_category.dart';

class InvoiceService extends ApiService<Invoice, String> {
  InvoiceService() : super(endpoint: '/api/Invoice');

  @override
  Invoice fromJson(Map<String, dynamic> json) => Invoice.fromJson(json);

  @override
  Map<String, dynamic> toJson(dynamic data) {
    if (data is ExpenseCategory) return data.toJson();
    if (data is Map<String, dynamic>) return data;
    throw ArgumentError('Unsupported data type for toJson: ${data.runtimeType}');
  }

  Future<Invoice> getUserInvoice() async {
    try {
      final response = await dio.get('$endpoint/current-user');
      final responseData = response.data['data'] as Map<String, dynamic>;
      return fromJson(responseData);
    } catch (e, stackTrace) {
      print('ERROR: Failed in getInvoice: $e');
      print('ERROR: Stack trace: $stackTrace');
      throw Exception('Failed to get complete balance data: $e');
    }
  }

}