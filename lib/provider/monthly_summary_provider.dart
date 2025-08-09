import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../model/models.dart';
import 'service_providers.dart';

part 'monthly_summary_provider.g.dart';

@riverpod
class MonthlySummaryNotifier extends _$MonthlySummaryNotifier {
  late int _year;
  late int _month;

  @override
  Future<MonthlySummary?> build(int year, int month) async {
    _year = year;
    _month = month;
    
    try {
      final service = ref.read(monthlySummaryServiceProvider);
      return await service.getMonthlySummary(year, month);
    } catch (e) {
      // Return null on error, UI can handle gracefully
      return null;
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(monthlySummaryServiceProvider);
      return await service.getMonthlySummary(_year, _month);
    });
  }

  // Helper getters for the current state
  @override
  int get year => _year;

  @override
  int get month => _month;
}