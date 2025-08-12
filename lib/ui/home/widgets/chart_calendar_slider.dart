import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'balance_chart.dart';
import 'calendarSummary.dart';

// Provider to track which tab is selected (0 = Balance Chart, 1 = Calendar Summary)
final chartCalendarTabProvider = StateProvider<int>((ref) => 0);

class ChartCalendarSlider extends ConsumerStatefulWidget {
  const ChartCalendarSlider({super.key});

  @override
  ConsumerState<ChartCalendarSlider> createState() => _ChartCalendarSliderState();
}

class _ChartCalendarSliderState extends ConsumerState<ChartCalendarSlider> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedTab = ref.watch(chartCalendarTabProvider);
    
    return Column(
      children: [
        // Content Area with PageView (increased width)
        SizedBox(
          height: 350, // Increased height for better content display
          width: double.infinity, // Full width
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              ref.read(chartCalendarTabProvider.notifier).state = index;
            },
            children: const [
              // Balance Chart Tab (reduced horizontal padding for more width)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: BalanceChart(),
              ),
              
              // Calendar Summary Tab (reduced horizontal padding for more width)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: CalendarSummary(),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Dot Indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildDotIndicator(0, selectedTab),
            const SizedBox(width: 12),
            _buildDotIndicator(1, selectedTab),
          ],
        ),
      ],
    );
  }

  Widget _buildDotIndicator(int index, int selectedTab) {
    final isSelected = index == selectedTab;
    return GestureDetector(
      onTap: () {
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: isSelected ? 24 : 8,
        height: 8,
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).primaryColor 
              : Colors.grey[300],
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}