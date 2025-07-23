import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../provider/providers.dart';
import '../../model/models.dart';

class TransactionItemTest extends StatelessWidget {
  final String title;
  final String subtitle;
  final String date;
  final String amount;
  final Color color;
  final IconData icon;

  const TransactionItemTest({
    super.key,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.2),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: amount.startsWith('-') ? Colors.red : Colors.green,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                date,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class RecentTransactionsSectionTest extends ConsumerWidget {
  final String userId;
  
  const RecentTransactionsSectionTest({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balanceAsync = ref.watch(balanceNotifierProvider(userId));

    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Transactions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          balanceAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Text('Error loading data: $error'),
            ),
            data: (balance) => _buildContent(balance),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(Balance balance) {
    // Calculate budget utilization
    final totalBudget = balance.budgets.fold<double>(0, (sum, budget) => sum + budget.budgetAmount);
    final totalSpent = balance.monthlyExpenses; // Using monthly expenses as total spent
    final percentUsed = totalBudget > 0 ? (totalSpent / totalBudget).clamp(0.0, 1.0) : 0.0;

    // Mock recent transactions - in real app, this would come from a provider
    final transactions = _getMockTransactions(balance);

    return Column(
      children: [
        // Circular Chart
        Center(
          child: CircularPercentIndicator(
            radius: 80.0,
            lineWidth: 14.0,
            animation: true,
            percent: percentUsed,
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${(percentUsed * 100).toStringAsFixed(1)}%",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                ),
                const SizedBox(height: 4),
                Text(
                  "${_formatShortCurrency(totalSpent)} / ${_formatShortCurrency(totalBudget)}",
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            circularStrokeCap: CircularStrokeCap.round,
            progressColor: _getProgressColor(percentUsed),
            backgroundColor: _getProgressColor(percentUsed).withValues(alpha: 0.2),
          ),
        ),
        const SizedBox(height: 24),
        // Transactions List
        if (transactions.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No Recent Transactions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your recent transactions will appear here',
                  style: TextStyle(color: Colors.grey[500]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          ...transactions.map((tx) => TransactionItemTest(
            title: tx['title'] as String,
            subtitle: tx['subtitle'] as String,
            date: tx['date'] as String,
            amount: tx['amount'] as String,
            color: tx['color'] as Color,
            icon: tx['icon'] as IconData,
          )),
      ],
    );
  }

  List<Map<String, dynamic>> _getMockTransactions(Balance balance) {
    // Mock data - in real app, this would come from recent expenses
    return [
      {
        'title': 'Netflix Subscription',
        'subtitle': 'Entertainment',
        'date': _formatDate(DateTime.now().subtract(const Duration(days: 1))),
        'amount': '-120.000₫',
        'color': Colors.red,
        'icon': Icons.movie,
      },
      {
        'title': 'Grab Ride',
        'subtitle': 'Transport',
        'date': _formatDate(DateTime.now().subtract(const Duration(days: 2))),
        'amount': '-80.000₫',
        'color': Colors.orange,
        'icon': Icons.local_taxi,
      },
      {
        'title': 'Monthly Salary',
        'subtitle': 'Income',
        'date': _formatDate(DateTime.now().subtract(const Duration(days: 5))),
        'amount': '+${_formatCurrency(balance.monthlyIncome)}',
        'color': Colors.green,
        'icon': Icons.attach_money,
      },
    ];
  }

  Color _getProgressColor(double percent) {
    if (percent < 0.5) return Colors.green;
    if (percent < 0.8) return Colors.orange;
    return Colors.red;
  }

  String _formatShortCurrency(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M₫';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}K₫';
    }
    return '${value.toStringAsFixed(0)}₫';
  }

  String _formatCurrency(double value) {
    return '${value.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    )}₫';
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}';
  }
}