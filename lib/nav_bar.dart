import 'package:exe201/ui/budget/budget.dart';
import 'package:exe201/ui/calendar/calendar.dart';
import 'package:exe201/ui/community/community.dart';
import 'package:exe201/ui/home/widgets/calendarSummary.dart';
import 'package:exe201/ui/user/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'provider/providers.dart';
import 'ui/home/home.dart';

class BottomTab extends ConsumerStatefulWidget {
  const BottomTab({super.key});

  @override
  ConsumerState<BottomTab> createState() => _BottomTabState();
}

class _BottomTabState extends ConsumerState<BottomTab> {
  int _currentIndex = 0;
  late final PageController _pageController;

  final List<Widget> _tabs = [
    const HomeTab(),
    const BudgetTab(),
    const CalendarTab(),
    const UserTab(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF3F4F6),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
        },
        children: _tabs,
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildBottomNavigation() {
    final icons = [
      Icons.home,
      Icons.credit_card_outlined,
      Icons.calendar_month_outlined,
      Icons.person_2_rounded,
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(icons.length, (index) {
              return _buildNavItem(icons[index], index);
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => _goToPage(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        padding: isSelected
            ? const EdgeInsets.symmetric(horizontal: 20, vertical: 12)
            : const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6366F1) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: const Color(0xFF6366F1).withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
              spreadRadius: 1,
            ),
          ]
              : [],
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, animation) {
            return ScaleTransition(scale: animation, child: child);
          },
          child: Icon(
            icon,
            key: ValueKey<bool>(isSelected),
            color: isSelected ? Colors.white : Colors.grey[400],
            size: 24,
          ),
        ),
      ),
    );
  }

  void _goToPage(int targetIndex) {
    if (targetIndex == _currentIndex) return;

    // Add haptic feedback for better UX
    HapticFeedback.lightImpact();

    final distance = (targetIndex - _currentIndex).abs();

    if (distance > 1) {
      _pageController.jumpToPage(targetIndex);
    } else {
      _pageController.animateToPage(
        targetIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }

    setState(() => _currentIndex = targetIndex);
  }
}
