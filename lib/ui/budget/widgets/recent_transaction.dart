import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../model/balance/balance.dart';
import '../../../model/expense/expense.dart';
import '../../../model/expense_category/expense_category.dart';
import '../../../model/selected_month_data/selected_month_data.dart';
import '../../../provider/providers.dart';
import '../../extra/category_colors.dart';

class TransactionItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String date;
  final String amount;
  final Color color;
  final String icon;

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
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color,
            child: Text(icon),
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

class RecentTransactionsSection extends ConsumerWidget {
  final String userId;

  const RecentTransactionsSection({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDataAsync = ref.watch(selectedMonthDataProvider);

    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Transactions',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          selectedDataAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Text('Error loading data: $error'),
            ),
            data: (selectedData) {
              if (selectedData == null) {
                return Center(child: Text('No data available for selected month'));
              }
              return _buildContent(selectedData, ref);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContent(SelectedMonthData selectedData, WidgetRef ref) {
    final categoriesAsync = ref.watch(expenseCategoriesNotifierProvider);
    
    return categoriesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error loading categories: $error')),
      data: (categories) {
        // Use recent transactions from selected month data
        final expenses = selectedData.transactions;


        // Create a map of categoryId to ExpenseCategory for quick lookup
        final categoryMap = {for (var cat in categories) cat.exCid: cat};

        // Filter and sort expense categories using the same logic as budget categories
        final expenseCategories = categories
            .where((category) => category.type == CategoryType.expense)
            .toList()
          ..sort((a, b) => CategoryColors.customOrder.indexOf(a.categoryName).compareTo(
              CategoryColors.customOrder.indexOf(b.categoryName)));

        // Calculate expense breakdown by category
        final Map<String, double> categoryExpenses = {};
        final Map<String, Color> categoryColorMap = {};
        final Map<String, String> categoryIconMap = {};

        // Group expenses by category
        for (final expense in expenses) {
          final category = categoryMap[expense.exCid];
          if (category != null && category.type == CategoryType.expense) {
            final categoryName = category.categoryName;
            categoryExpenses[categoryName] = (categoryExpenses[categoryName] ?? 0) + expense.amount;
          }
        }

        // Assign colors and icons using the same order as budget categories
        for (int i = 0; i < expenseCategories.length; i++) {
          final category = expenseCategories[i];
          final categoryName = category.categoryName;
          final style = CategoryColors.getStyleByIndex(i);
          categoryColorMap[categoryName] = style.color;
          categoryIconMap[categoryName] = style.icon;
        }

        final totalExpenses = categoryExpenses.values.fold<double>(0, (sum, amount) => sum + amount);

        return _buildPieChart(categoryExpenses, categoryColorMap, categoryIconMap, totalExpenses, expenses, selectedData, ref, categoryMap);
      },
    );
  }

  Widget _buildPieChart(Map<String, double> categoryExpenses, Map<String, Color> categoryColorMap, Map<String, String> categoryIconMap, double totalExpenses, List<Expense> expenses, SelectedMonthData selectedData, WidgetRef ref, Map<String, ExpenseCategory> categoryMap) {

    return Column(
      children: [
        // Pie Chart
        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 160,
                height: 160,
                child: PieChart(
                  PieChartData(
                    sections: categoryExpenses.entries.map((entry) {
                      final categoryName = entry.key;
                      final amount = entry.value;
                      final percentage = totalExpenses > 0 ? (amount / totalExpenses) * 100 : 0;
                      final color = categoryColorMap[categoryName] ?? Colors.grey;

                      return PieChartSectionData(
                        color: color,
                        value: amount,
                        title: '${percentage.toStringAsFixed(1)}%',
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        radius: 50,
                      );
                    }).toList(),
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    startDegreeOffset: -90,
                  ),
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Transactions List - Use the expenses we already fetched
        Builder(
          builder: (context) {
            final transactions = _convertExpensesToTransactions(expenses, ref, categoryColorMap, categoryIconMap, categoryMap);

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

            return _buildSlidableTransactions(transactions);
          },
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _convertExpensesToTransactions(List<Expense> expenses, WidgetRef ref, Map<String, Color> categoryColorMap, Map<String, String> categoryIconMap, Map<String, ExpenseCategory> categoryMap) {
    final List<Map<String, dynamic>> transactions = [];

    // Convert expenses to transaction format (only expense transactions)
    for (final expense in expenses) {
      // Find the category for this expense
      final category = categoryMap[expense.exCid];

      // Skip if category not found or is income category
      if (category == null || category.type == CategoryType.income) continue;

      final categoryName = category.categoryName;

      transactions.add({
        'title': expense.description ?? categoryName,
        'subtitle': categoryName,
        'date': _formatDate(expense.createdDate),
        'amount': '-${_formatCurrency(expense.amount)}',
        'color': categoryColorMap[categoryName] ?? Colors.grey,
        'icon': categoryIconMap[categoryName] ?? '📊',
      });
    }

    return transactions;
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

  Widget _buildSlidableTransactions(List<Map<String, dynamic>> transactions) {
    if (transactions.isEmpty) {
      return const SizedBox.shrink();
    }

    return SlidableTransactionWidget(transactions: transactions);
  }
}

class SlidableTransactionWidget extends StatefulWidget {
  final List<Map<String, dynamic>> transactions;

  const SlidableTransactionWidget({
    super.key,
    required this.transactions,
  });

  @override
  State<SlidableTransactionWidget> createState() => _SlidableTransactionWidgetState();
}

class _SlidableTransactionWidgetState extends State<SlidableTransactionWidget> {
  late ScrollController _scrollController;
  double _scrollPosition = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    setState(() {
      _scrollPosition = _scrollController.offset;
    });
  }

  @override
  Widget build(BuildContext context) {
    const double itemHeight = 80.0;
    final double maxHeight = 300.0; // Maximum height for the container
    final double contentHeight = widget.transactions.length * itemHeight;
    final double containerHeight = contentHeight > maxHeight ? maxHeight : contentHeight;
    
    return Row(
      children: [
        // Scrollable transaction list - takes most space
        Expanded(
          child: SizedBox(
            height: containerHeight,
            child: ListView.builder(
              controller: _scrollController,
              itemCount: widget.transactions.length,
              itemBuilder: (context, index) {
                final tx = widget.transactions[index];
                return TransactionItem(
                  title: tx['title'] as String,
                  subtitle: tx['subtitle'] as String,
                  date: tx['date'] as String,
                  amount: tx['amount'] as String,
                  color: tx['color'] as Color,
                  icon: tx['icon'] as String,
                );
              },
            ),
          ),
        ),
        
        // Side indicator - vertical scrollbar style (only show if content is scrollable)
        if (contentHeight > maxHeight) ...[
          Container(
            width: 4,
            height: containerHeight,
            margin: const EdgeInsets.only(left: 8),
            child: Stack(
              children: [
                // Background track
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Active indicator
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 100),
                  top: _scrollController.hasClients 
                    ? (_scrollPosition / _scrollController.position.maxScrollExtent) * (containerHeight - 40)
                    : 0,
                  child: Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
