import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';


class TransactionItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String date;
  final String amount;
  final Color color;
  final IconData icon;

  const TransactionItem({
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
            offset: Offset(0, 3),
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


class RecentTransactionsSection extends StatelessWidget {
  const RecentTransactionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final totalSpent = 4870000;
    final totalBudget = 10000000;
    final percentUsed = totalSpent / totalBudget;

    final transactions = [
      {
        'title': 'Netflix',
        'subtitle': 'Entertainment',
        'date': 'Jun 10',
        'amount': '-120.000₫',
        'color': Colors.red,
        'icon': Icons.movie,
      },
      {
        'title': 'Grab',
        'subtitle': 'Transport',
        'date': 'Jun 9',
        'amount': '-80.000₫',
        'color': Colors.orange,
        'icon': Icons.local_taxi,
      },
      {
        'title': 'Salary',
        'subtitle': 'Income',
        'date': 'Jun 5',
        'amount': '+10.000.000₫',
        'color': Colors.green,
        'icon': Icons.attach_money,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Text(
          'Recent Transactions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // ⭕ Circular Chart
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
                  "${totalSpent ~/ 1000}.000₫ / ${totalBudget ~/ 1000}.000₫",
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            circularStrokeCap: CircularStrokeCap.round,
            progressColor: Colors.deepPurple,
            backgroundColor: Colors.deepPurple.shade100,
          ),
        ),

        const SizedBox(height: 24),

        // 🧾 Transactions
        ...transactions.map((tx) => TransactionItem(
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
}
