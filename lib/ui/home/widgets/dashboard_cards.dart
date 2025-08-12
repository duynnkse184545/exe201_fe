import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../model/balance/balance.dart';
import '../../../model/expense/expense.dart';
import '../../../provider/providers.dart';
import '../../../provider/calendar_providers.dart';
import '../../extra/header.dart';

class DashboardCards extends ConsumerStatefulWidget {
  final String userId;
  const DashboardCards({super.key, required this.userId});

  @override
  ConsumerState<DashboardCards> createState() => _DashboardCardsState();
}

class _DashboardCardsState extends ConsumerState<DashboardCards> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Budget Tracker Card
        Expanded(
          child: _buildCard(
            header: 'Budget Tracker',
            color: Theme.of(context).primaryColor,
            items: _getBudgetTrackerItems(),
            baseColor: const Color(0xFF6366F1),
          ),
        ),
        const SizedBox(width: 16),

        // Study Planner Card
        Expanded(
          child: _buildCard(
            header: 'Study Planner',
            color: Color(0xffFA6E5A),
            isScrollable: true,
            isReversed: true,
            items: _getStudyPlannerItems(),
            baseColor: const Color(0xffFA6E5A),
          ),
        ),
      ],
    );
  }

  Widget _buildCard({
    required String header,
    required Color color,
    bool isScrollable = false,
    bool isReversed = false,
    Widget? content,
    Future<List<Map<String, dynamic>>>? items,
    Color? baseColor,
  }) {
    return Container(
      height: 200, // Fixed height for all cards
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            header,
            maxLines: 1,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          // Handle both content widget and items list
          if (content != null)
            content
          else if (items != null && baseColor != null)
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: items,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error loading data',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    );
                  }

                  final itemList = snapshot.data ?? [];
                  return ListView.separated(
                    physics: isScrollable? AlwaysScrollableScrollPhysics() : NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: itemList.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index){
                      final item = itemList[index];
                      return _buildCardItem(item['title'], item['content'], baseColor, reversed: isReversed, isCompleted: item['isCompleted'] ?? false);
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _getBudgetTrackerItems() async {
    try {
      // Get balance data using the service directly
      final balanceAsync = await ref.watch(balanceNotifierProvider.future);

      // Get recent expenses
      final expenses = balanceAsync.expenses;

      // Get the most recent expense amount
      double recentExpenseAmount = 0;
      bool hasExpenses = expenses.isNotEmpty;
      if (hasExpenses) {
        recentExpenseAmount = expenses.first.amount;
      }

      return [
        {
          'title': 'Balance',
          'content': formatCurrency(balanceAsync.availableBalance)
        },
        {
          'title': 'Recent Expense',
          'content': hasExpenses
              ? '-${formatCurrency(recentExpenseAmount)}'
              : 'No expenses'
        }
      ];
    } catch (e) {
      // Return error state items
      return [
        {'title': 'Balance', 'content': 'Error'},
        {'title': 'Recent Expense', 'content': 'Error'}
      ];
    }
  }

  Future<List<Map<String, dynamic>>> _getStudyPlannerItems() async {
    try {
      // Get all assignments without modifying providers
      final today = DateTime.now();
      final allAssignments = await ref.watch(assignmentsProvider.future);
      
      // Filter assignments for today
      final todayAssignments = allAssignments.where((assignment) => 
        assignment.dueDate.year == today.year &&
        assignment.dueDate.month == today.month &&
        assignment.dueDate.day == today.day
      ).toList();
      print(todayAssignments);
      // Get upcoming assignments (next 7 days)
      final weekFromNow = today.add(Duration(days: 7));
      final upcomingAssignments = allAssignments.where((assignment) => 
        assignment.dueDate.isAfter(today) &&
        assignment.dueDate.isBefore(weekFromNow)
      ).toList();
      
      // Get next assignment
      String nextAssignment = 'No assignments';
      if (todayAssignments.isNotEmpty) {
        // Sort today's assignments by due time
        todayAssignments.sort((a, b) => a.dueDate.compareTo(b.dueDate));
        final nextToday = todayAssignments.firstWhere(
          (assignment) => assignment.dueDate.isAfter(DateTime.now()),
          orElse: () => todayAssignments.first,
        );
        nextAssignment = nextToday.title;
      } else if (upcomingAssignments.isNotEmpty) {
        // Get next upcoming assignment
        upcomingAssignments.sort((a, b) => a.dueDate.compareTo(b.dueDate));
        nextAssignment = upcomingAssignments.first.title;
      }

      if (todayAssignments.isEmpty) {
        return [
          {'title': 'Due Today', 'content': 'No deadline'},
        ];
      }

      return todayAssignments.map((assignment) {
        return {
          'title': assignment.title,
          'content':
          '${DateFormat('HH:mm').format(assignment.dueDate)}-${DateFormat('HH:mm').format(assignment.dueDate.add(Duration(hours: assignment.estimatedTime)))}',
          'isCompleted': assignment.status == 'completed',
        };
      }).toList();

    } catch (e) {
      debugPrint(e.toString());
      return [
        {'title': 'Due Today', 'content': 'Error'},
        {'title': 'This Week', 'content': 'Error'},
        {'title': 'Next Assignment', 'content': 'Error'}
      ];
    }
  }

  Widget _buildTimeSlot(String timeRange) {
    return Row(
      children: [
        Text(
          timeRange,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        const Spacer(),
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 2),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildCardItem(
      String title,
      String content,
      Color baseColor, {
        bool? isCompleted = false,
        bool reversed = false,
      }) {
    final titleWidget = Text(
      title,
      style: TextStyle(
          decoration: !isCompleted!? null : TextDecoration.lineThrough,
          decorationColor: Colors.white70,
          color: Colors.white70,
          fontSize: 13,
        fontWeight: FontWeight.bold
      ),
    );

    final contentWidget = Text(
      content,
      maxLines: 1,
      style: TextStyle(
        decoration: isCompleted? TextDecoration.lineThrough : null,
        decorationColor: Colors.white70,
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: _getBrighterColor(baseColor),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: reversed
            ? [contentWidget, titleWidget] // reversed order
            : [titleWidget, contentWidget],
      ),
    );
  }

  /// Creates a brighter version of the input color
  Color _getBrighterColor(Color baseColor) {
    final hsl = HSLColor.fromColor(baseColor);
    final brighterHsl = hsl.withLightness((hsl.lightness + 0.15).clamp(0.0, 1.0));
    return brighterHsl.toColor();
  }
  
}