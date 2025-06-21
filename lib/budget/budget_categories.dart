import 'package:flutter/material.dart';

class CategoryItem extends StatelessWidget {
  final int index;
  final String label;
  final String amount;
  final Color color;
  final bool isExpanded;
  final VoidCallback onTap;

  const CategoryItem({
    super.key,
    required this.index,
    required this.label,
    required this.amount,
    required this.color,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
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
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                Text(
                  amount,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Expanded content
        if (isExpanded)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ElevatedButton(
              onPressed: () {
                // Your action
              },
              child: const Text("Do Something"),
            ),
          ),
      ],
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

  final categories = [
    {'label': 'Fixed Expenses', 'amount': '2.000.000₫', 'color': Colors.blue},
    {'label': 'Living Expenses', 'amount': '1.500.000₫', 'color': Colors.green},
    {'label': 'Entertainment & Personal Spending', 'amount': '600.000₫', 'color': Colors.orange},
    {'label': 'Education & Self-improvement', 'amount': '400.000₫', 'color': Colors.purple},
    {'label': 'Other Expenses', 'amount': '200.000₫', 'color': Colors.red},
    {'label': 'Saving', 'amount': '500.000₫', 'color': Colors.grey},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Text(
          'Categories',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(categories.length, (i) {
          final cat = categories[i];
          return CategoryItem(
            index: i + 1,
            label: cat['label'] as String,
            amount: cat['amount'] as String,
            color: cat['color'] as Color,
            isExpanded: expandedIndex == i,
            onTap: () {
              setState(() {
                expandedIndex = expandedIndex == i ? null : i;
              });
            },
          );
        }),
      ],
    );
  }
}

