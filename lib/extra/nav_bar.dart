import 'package:exe201/budget/budget.dart';
import 'package:exe201/calendar/calendar.dart';
import 'package:exe201/community/community.dart';
import 'package:exe201/user/user.dart';
import 'package:flutter/material.dart';
import '../home/home.dart';

class BottomTab extends StatefulWidget {
  const BottomTab({super.key});

  @override
  State<BottomTab> createState() => _BottomTabState();
}

class _BottomTabState extends State<BottomTab> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const HomeTab(),
    const BudgetTab(),
    const CommunityTab(),
    const CalendarTab(),
    const UserTab()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF3F4F6),
      body: _tabs[_currentIndex], // Use the selected tab as the body
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }
  Widget _buildBottomNavigation() {
    final icons = [
      Icons.home,
      Icons.credit_card_outlined,
      Icons.people_sharp,
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
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
            colors: [
              Color(0xFF6366F1).withValues(alpha: 0.8),
              Color(0xFF8B5CF6).withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : null,
          borderRadius: BorderRadius.circular(30),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: Color(0xFF6366F1).withValues(alpha: 0.4),
              blurRadius: 12,
              offset: Offset(0, 4),
              spreadRadius: 2,
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.8),
              blurRadius: 8,
              offset: Offset(-2, -2),
              spreadRadius: 1,
            ),
          ]
              : null,
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.grey[400],
          size: 24,
        ),
      ),
    );
  }

}