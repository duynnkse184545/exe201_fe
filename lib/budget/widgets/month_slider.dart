import 'package:flutter/material.dart';

import '../../extra/header.dart';

class MonthSlider extends StatefulWidget {
  const MonthSlider({super.key});

  @override
  State<MonthSlider> createState() => _MonthSliderState();
}

class _MonthSliderState extends State<MonthSlider> {
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
  late String selectedMonth;

  @override
  void initState() {
    super.initState();

    final currentMonthIndex = DateTime.now().month - 1;
    selectedMonth = months[currentMonthIndex];

    _scrollController = ScrollController();

    // Auto-scroll after layout builds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedMonth(currentMonthIndex);
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
    return Container(
      margin: EdgeInsets.zero,
      decoration: const BoxDecoration(color: Color(0xff7583ca)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildHeader(Colors.white, true),

            const SizedBox(height: 10,),

            SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              child: Row(
                children: months.asMap().entries.map((entry) {
                  final i = entry.key;
                  final month = entry.value;
                  final isSelected = month == selectedMonth;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedMonth = month;
                        });
                        _scrollToSelectedMonth(i);
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(105, 40),
                        backgroundColor: isSelected
                            ? Colors.white
                            : const Color(0xff7583ca).withValues(alpha: 1.2),
                        foregroundColor: isSelected
                            ? const Color(0xff7583ca)
                            : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        month,
                        style: TextStyle(
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
