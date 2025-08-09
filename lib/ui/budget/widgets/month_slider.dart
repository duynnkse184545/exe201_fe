import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../extra/header.dart';

// Provider to track selected month and year
final selectedMonthProvider = StateProvider<DateTime>((ref) => DateTime.now());

class MonthSlider extends ConsumerStatefulWidget {
  const MonthSlider({super.key});

  @override
  ConsumerState<MonthSlider> createState() => _MonthSliderState();
}

class _MonthSliderState extends ConsumerState<MonthSlider> {
  final List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // Auto-scroll after layout builds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final selectedDate = ref.read(selectedMonthProvider);
      _scrollToSelectedMonth(selectedDate.month - 1);
    });
  }

  void _scrollToSelectedMonth(int index) {
    final buttonWidth = 116; // Your actual button width (including margin)
    final screenWidth = MediaQuery.of(context).size.width;
    final offset = (index * buttonWidth) - (screenWidth - buttonWidth) / 2;

    _scrollController.animateTo(
      offset.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }


  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedMonthProvider);
    
    return Container(
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(color: Theme.of(context).primaryColor),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with year navigation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buildHeader(Colors.white, true),
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          final newDate = DateTime(selectedDate.year - 1, selectedDate.month);
                          ref.read(selectedMonthProvider.notifier).state = newDate;
                        },
                        icon: const Icon(Icons.chevron_left, color: Colors.white),
                        constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                        padding: EdgeInsets.all(4),
                      ),
                      Flexible(
                        child: Text(
                          selectedDate.year.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          final newDate = DateTime(selectedDate.year + 1, selectedDate.month);
                          ref.read(selectedMonthProvider.notifier).state = newDate;
                        },
                        icon: const Icon(Icons.chevron_right, color: Colors.white),
                        constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                        padding: EdgeInsets.all(4),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              child: Row(
                children: months.asMap().entries.map((entry) {
                  final i = entry.key;
                  final month = entry.value;
                  final isSelected = i == selectedDate.month - 1;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ElevatedButton(
                      onPressed: () {
                        final newDate = DateTime(selectedDate.year, i + 1);
                        ref.read(selectedMonthProvider.notifier).state = newDate;
                        _scrollToSelectedMonth(i);
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(105, 40),
                        backgroundColor: isSelected
                            ? Colors.white
                            : Theme.of(context).primaryColor.withValues(alpha: 1.2),
                        foregroundColor: isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        month,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
