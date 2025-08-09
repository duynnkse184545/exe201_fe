import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../model/balance/balance.dart';
import '../../../model/expense/expense.dart';
import '../../../provider/providers.dart';
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
            content: _buildStudyPlannerContent(),
          ),
        ),
      ],
    );
  }

  Widget _buildCard({
    required String header,
    required Color color,
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
                    shrinkWrap: true,
                    itemCount: itemList.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index){
                      final item = itemList[index];
                      return _buildCardItem(item['title'], item['content'], baseColor);
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

  Widget _buildStudyPlannerContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            _buildTimeSlot('9am - 10am'),
            const SizedBox(height: 8),
            _buildTimeSlot('8pm - 10pm'),
          ],
        ),
      ],
    );
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
        bool reversed = false,
      }) {
    final titleWidget = Text(
      title,
      style: TextStyle(color: Colors.white70, fontSize: 12),
    );

    final contentWidget = Text(
      content,
      maxLines: 1,
      style: TextStyle(
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