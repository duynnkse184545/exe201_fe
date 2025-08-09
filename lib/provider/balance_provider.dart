import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../model/balance/balance.dart';
import 'service_providers.dart';

part 'balance_provider.g.dart';

// Main balance data provider - now uses backend logic only
@riverpod
class BalanceNotifier extends _$BalanceNotifier {
  @override
  Future<Balance> build() async {
    // Fetch from backend API (single call with pre-computed data)
    final service = ref.watch(balanceServiceProvider);
    final data = await service.getCompleteBalanceData();
    
    // Cache the data for offline access
    final storage = ref.watch(balanceStorageProvider);
    await storage.saveBalanceData(data);
    
    return data;
  }

  // Toggle budget lock for next month
  Future<void> toggleBudgetLock(String budgetId, bool isLocked) async {
    final currentData = state.value;
    if (currentData == null) return;

    try {
      final service = ref.read(balanceServiceProvider);
      await service.toggleBudgetLock(budgetId, isLocked);
      
      // Refresh data to reflect changes
      await refresh();
    } catch (e) {
      state = AsyncData(currentData.copyWith(
        error: 'Failed to toggle budget lock: $e',
      ));
    }
  }

  // Refresh data manually
  Future<void> refresh() async {
    final currentData = state.value;
    if (currentData == null) return;
    
    state = const AsyncLoading();
    try {
      final service = ref.read(balanceServiceProvider);
      final freshData = await service.getCompleteBalanceData();
      
      // Cache the fresh data
      final storage = ref.read(balanceStorageProvider);
      await storage.saveBalanceData(freshData);
      
      state = AsyncData(freshData);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}