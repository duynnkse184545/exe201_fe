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
            data: (balance) => _buildContent(balance, ref),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(Balance balance, WidgetRef ref) {
    // Calculate budget utilization
    final totalBudget = balance.budgets.fold<double>(0, (sum, budget) => sum + budget.budgetAmount);
    final totalSpent = balance.monthlyExpenses; // Using monthly expenses as total spent
    final percentUsed = totalBudget > 0 ? (totalSpent / totalBudget).clamp(0.0, 1.0) : 0.0;

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
        // Transactions List - Use FutureBuilder to get data from ExpenseService
        FutureBuilder<List<Expense>>(
          future: ref.read(expenseServiceProvider).getRecentTransactions(userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (snapshot.hasError) {
              return Center(
                child: Text('Error loading transactions: ${snapshot.error}'),
              );
            }
            
            final expenses = snapshot.data ?? [];
            final transactions = _convertExpensesToTransactions(expenses, ref);
            
            if (transactions.isEmpty) {
              return Container(
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
              );
            }
            
            return Column(
              children: transactions.map((tx) => TransactionItemTest(
                title: tx['title'] as String,
                subtitle: tx['subtitle'] as String,
                date: tx['date'] as String,
                amount: tx['amount'] as String,
                color: tx['color'] as Color,
                icon: tx['icon'] as IconData,
              )).toList(),
            );
          },
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _convertExpensesToTransactions(List<Expense> expenses, WidgetRef ref) {
    final List<Map<String, dynamic>> transactions = [];
    final categoriesAsync = ref.read(expenseCategoriesNotifierProvider);
    
    // Get categories if available
    final categories = categoriesAsync.hasValue ? categoriesAsync.value! : <ExpenseCategory>[];
    
    // Convert expenses to transaction format
    for (final expense in expenses) {
      // Find the category for this expense
      final category = categories
          .where((cat) => cat.exCid == expense.categoryId)
          .firstOrNull;
      
      final categoryName = category?.categoryName ?? 'Unknown Category';
      final isIncome = category?.type == CategoryType.income;
      
      transactions.add({
        'title': expense.description ?? categoryName,
        'subtitle': categoryName,
        'date': _formatDate(expense.createdDate),
        'amount': '${isIncome ? '+' : '-'}${_formatCurrency(expense.amount)}',
        'color': _getCategoryColor(category, isIncome),
        'icon': _getCategoryIcon(category, isIncome),
      });
    }
    
    return transactions;
  }
  
  Color _getCategoryColor(ExpenseCategory? category, bool isIncome) {
    if (isIncome) return Colors.green;
    
    // Return different colors based on category or use a default
    if (category == null) return Colors.grey;
    
    // You can customize colors based on category names
    final categoryName = category.categoryName.toLowerCase();
    if (categoryName.contains('food') || categoryName.contains('restaurant')) {
      return Colors.orange;
    } else if (categoryName.contains('transport') || categoryName.contains('taxi')) {
      return Colors.blue;
    } else if (categoryName.contains('entertainment') || categoryName.contains('movie')) {
      return Colors.purple;
    } else if (categoryName.contains('shopping') || categoryName.contains('clothes')) {
      return Colors.pink;
    } else if (categoryName.contains('health') || categoryName.contains('medical')) {
      return Colors.red;
    }
    
    return Colors.indigo; // Default color for other categories
  }
  
  IconData _getCategoryIcon(ExpenseCategory? category, bool isIncome) {
    if (isIncome) return Icons.attach_money;
    
    if (category == null) return Icons.receipt;
    
    // Return different icons based on category names
    final categoryName = category.categoryName.toLowerCase();
    if (categoryName.contains('food') || categoryName.contains('restaurant')) {
      return Icons.restaurant;
    } else if (categoryName.contains('transport') || categoryName.contains('taxi')) {
      return Icons.local_taxi;
    } else if (categoryName.contains('entertainment') || categoryName.contains('movie')) {
      return Icons.movie;
    } else if (categoryName.contains('shopping') || categoryName.contains('clothes')) {
      return Icons.shopping_bag;
    } else if (categoryName.contains('health') || categoryName.contains('medical')) {
      return Icons.local_hospital;
    } else if (categoryName.contains('education') || categoryName.contains('school')) {
      return Icons.school;
    } else if (categoryName.contains('utility') || categoryName.contains('bill')) {
      return Icons.receipt_long;
    }
    
    return Icons.payment; // Default icon for other categories
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