import 'package:exe201/ui/extra/custom_dialog.dart';
import 'package:flutter/material.dart';
import '../../extra/custom_field.dart';

class CategoryItem extends StatelessWidget {
  final int index;
  final String label;
  final double amount;
  final double displayedAmount;
  final Color color;
  final bool isExpanded;
  final VoidCallback onTap;
  final bool isPressed;
  final VoidCallback onActionPressed;

  const CategoryItem({
    super.key,
    required this.index,
    required this.label,
    required this.amount,
    required this.displayedAmount,
    required this.color,
    required this.isExpanded,
    required this.onTap,
    required this.isPressed,
    required this.onActionPressed
  });

  String _formatCurrency(double value) {
    return '${value
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (match) => '${match[1]}.')}₫';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      height: isExpanded ? 110 : 45,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Expanded container behind the main one
          Positioned(
            top: 30,
            left: 0,
            right: 0,
            child: AnimatedSize(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              child: ConstrainedBox(
                constraints: isExpanded
                    ? const BoxConstraints()
                    : const BoxConstraints(maxHeight: 0),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isExpanded ? 1 : 0,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 10),
                    decoration: BoxDecoration(
                      color: Colors.grey.withAlpha(30),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    child: Center(
                      child: ElevatedButton(
                        onPressed: () => onActionPressed(),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 80),
                          backgroundColor: getPressedStateColor(isPressed),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text("Set spending limit"),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Main container (always on top)
          Positioned(
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
                boxShadow: isExpanded
                    ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 7),
                  ),
                ]
                    : null,
              ),
              child: GestureDetector(
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 7,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '$index',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // Animated amount display
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 800),
                        tween: Tween<double>(
                          begin: displayedAmount,
                          end: amount,
                        ),
                        builder: (context, value, child) {
                          return Text(
                            _formatCurrency(value),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class CategoriesSection extends StatefulWidget {
  const CategoriesSection({super.key});

  @override
  State<CategoriesSection> createState() => _CategoriesSectionState();
}

class _CategoriesSectionState extends State<CategoriesSection> {
  int? expandedIndex;
  int? pressedIndex;

  // Updated to use Map<String, dynamic> with double amounts
  final List<Map<String, dynamic>> categories = [
    {'label': 'Fixed Expenses', 'amount': 2000000.0, 'displayedAmount': 2000000.0, 'color': Colors.blue},
    {'label': 'Living Expenses', 'amount': 1500000.0, 'displayedAmount': 1500000.0, 'color': Colors.green},
    {'label': 'Entertainment & Personal', 'amount': 600000.0, 'displayedAmount': 600000.0, 'color': Colors.orange},
    {'label': 'Education & Self-improvement', 'amount': 400000.0, 'displayedAmount': 400000.0, 'color': Colors.purple},
    {'label': 'Other Expenses', 'amount': 200000.0, 'displayedAmount': 200000.0, 'color': Colors.red},
    {'label': 'Saving', 'amount': 500000.0, 'displayedAmount': 500000.0, 'color': Colors.grey},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 15),
        Row(
          children: [
            SizedBox(width: 20),
            const Text(
              'Categories',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 210),
            FloatingActionButton.small(
              onPressed: () {},
              backgroundColor: const Color(0xff7583ca),
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 2),
        ...List.generate(categories.length, (i) {
          final cat = categories[i];
          return CategoryItem(
            index: i + 1,
            label: cat['label'] as String,
            amount: cat['amount'] as double,
            displayedAmount: cat['displayedAmount'] as double,
            color: cat['color'] as Color,
            isExpanded: expandedIndex == i,
            isPressed: pressedIndex == i,
            onTap: () {
              setState(() {
                expandedIndex = expandedIndex == i ? null : i;
              });
            },
            onActionPressed: () async {
              setState(() => pressedIndex = i);
              final result = await _showBalanceDialog(context);
              if (mounted) {
                setState(() => pressedIndex = null);
                if (result != null && result['amount'] != null) {
                  // Update the category amount and trigger animation
                  setState(() {
                    categories[i]['displayedAmount'] = categories[i]['amount'];
                    categories[i]['amount'] = result['amount'] as double;
                  });
                }
              }
            },
          );
        }),
      ],
    );
  }

  Future<Map<String, dynamic>?> _showBalanceDialog(BuildContext context) async {
    final balanceController = TextEditingController();

    final result = await showCustomBottomSheet<Map<String, dynamic>>(
      context: context,
      title: 'Set Spending Limit',
      actionText: 'DONE',
      actionColor: Color(0xff7583ca),
      content: Column(
        children: [
          buildFormField(
            label: 'Amount',
            controller: balanceController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
          ),
        ],
      ),
      onActionPressed: () async {
        final balanceText = balanceController.text.trim();
        if (balanceText.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Please fill in all fields'))
          );
          return;
        }
        final amount = double.tryParse(balanceText);
        if (amount == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please enter a valid amount')),
          );
          return;
        }
        Navigator.of(context).pop({'amount': amount});
      },
    );
    return result;
  }
}