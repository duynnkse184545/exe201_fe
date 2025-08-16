import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../model/invoice.dart';
import 'service_providers.dart';

part 'invoice_provider.g.dart';

@riverpod
class UserInvoiceNotifier extends _$UserInvoiceNotifier {
  @override
  Future<List<Invoice>> build() async {
    final invoiceService = ref.watch(invoiceServiceProvider);
    try {
      final invoices = await invoiceService.getUserInvoice();
      return invoices;
    } catch (e) {
      print('Failed to load user invoice: $e');
      return [];
    }
  }

}

@riverpod
@riverpod
bool hasUserInvoice(Ref ref) {
  final invoiceAsync = ref.watch(userInvoiceNotifierProvider);

  return invoiceAsync.when(
    data: (invoices) {
      if (invoices.isEmpty) return false;

      // Find the most recent createdDate
      final latestInvoice = invoices.reduce((a, b) =>
      (a.createdDate!.isAfter(b.createdDate!)) ? a : b
      );

      final now = DateTime.now();
      final difference = now.difference(latestInvoice.createdDate!).inDays;

      return difference <= 30; // true if latest invoice is within 30 days
    },
    loading: () => false,
    error: (_, __) => false,
  );
}

