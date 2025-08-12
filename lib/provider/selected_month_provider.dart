import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../model/models.dart';
import '../ui/budget/widgets/month_slider.dart';
import 'providers.dart';

part 'selected_month_provider.g.dart';

// Provider that returns data based on selected month
@riverpod
Future<SelectedMonthData?> selectedMonthData(Ref ref) async {
  final selectedDate = ref.watch(selectedMonthProvider);
  final now = DateTime.now();
  
  final isCurrentMonth = selectedDate.year == now.year && selectedDate.month == now.month;
  
  if (isCurrentMonth) {
    // Current month: Use balance provider for real-time data
    try {
      final balance = await ref.watch(balanceNotifierProvider.future);
      return balance != null 
          ? SelectedMonthData.fromBalance(balance, isCurrentMonth: true)
          : null;
    } catch (error) {
      print('Error loading current month balance: $error');
      return null;
    }
  } else {
    // Past/Future months: Use monthly summary with 0 balance
    try {
      final summary = await ref.watch(monthlySummaryNotifierProvider(selectedDate.year, selectedDate.month).future);
      return summary != null 
          ? SelectedMonthData.fromSummary(summary, isCurrentMonth: false)
          : SelectedMonthData.empty(selectedDate.year, selectedDate.month);
    } catch (error) {
      print('Error loading monthly summary for ${selectedDate.year}/${selectedDate.month}: $error');
      return SelectedMonthData.empty(selectedDate.year, selectedDate.month);
    }
  }
}

