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
bool hasUserInvoice(HasUserInvoiceRef ref) {
  final invoiceAsync = ref.watch(userInvoiceNotifierProvider);
  return invoiceAsync.when(
    data: (invoice) => invoice != null,
    loading: () => false,
    error: (_, __) => false,
  );
}