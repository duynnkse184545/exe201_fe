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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      padding: EdgeInsets.only(bottom: isExpanded ? 70 : 0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Expanded container behind the main one
          if (isExpanded)
            Positioned(
              top: 40,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                decoration: BoxDecoration(
                  color: Colors.grey.withAlpha(30),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    // Your action
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff7583ca),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Do Something"),
                ),
              ),
            ),

          // Main container (always on top)
          Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
              boxShadow: isExpanded? [
                 BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 7),
                ) ,
              ] : null,
            ),
            child: GestureDetector(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      amount,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
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

  final categories = [
    {'label': 'Fixed Expenses', 'amount': '2.000.000₫', 'color': Colors.blue},
    {'label': 'Living Expenses', 'amount': '1.500.000₫', 'color': Colors.green},
    {'label': 'Entertainment & Personal ', 'amount': '600.000₫', 'color': Colors.orange},
    {'label': 'Education & Self-improvement', 'amount': '400.000₫', 'color': Colors.purple},
    {'label': 'Other Expenses', 'amount': '200.000₫', 'color': Colors.red},
    {'label': 'Saving', 'amount': '500.000₫', 'color': Colors.grey},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 15),
        Row(
        children:[
          SizedBox(width: 20),
        const Text(
          'Categories',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(width: 210,),

            FloatingActionButton.small(
            onPressed: (){},
            backgroundColor: const Color(0xff7583ca),
            child: const Icon(Icons.add, color: Colors.white),
          ),
          ]
        ),

        const SizedBox(height: 2),
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

