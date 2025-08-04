import 'package:exe201/ui/extra/custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../provider/providers.dart';
import '../../../model/models.dart';
import '../../extra/custom_field.dart';
import '../../extra/category_colors.dart';
import '../../extra/expenseBudgetDialog.dart';
import '../../extra/header.dart';

class CategoryItem extends StatelessWidget {
  final int index;
  final String label;
  final double amount;
  final double spentAmount;
  final Color color;
  final bool isExpanded;
  final VoidCallback onTap;
  final bool isPressed;
  final VoidCallback onActionPressed;
  final String categoryId;
  final String userId;

  const CategoryItem({
    super.key,
    required this.index,
    required this.label,
    required this.amount,
    required this.spentAmount,
    required this.color,
    required this.isExpanded,
    required this.onTap,
    required this.isPressed,
    required this.onActionPressed,
    required this.categoryId,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      height: isExpanded ? 170 : 55,
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
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Initial value:'),
                            Text(
                              formatCurrency(amount),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Spent:'),
                            Text(
                              formatCurrency(spentAmount),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: spentAmount > amount
                                    ? Colors.red
                                    : Colors.green,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          child: ElevatedButton(
                            onPressed: () => onActionPressed(),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 80,
                              ),
                              backgroundColor: getPressedStateColor(
                                color,
                                isPressed,
                              ),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text("Set spending limit"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Main container (always on top)
          Positioned(
            child: Container(
              height: 50,
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
                onHorizontalDragEnd: (details) {
                  // Swipe right to add expense
                  if (details.primaryVelocity! > 0) {
                    showUnifiedBudgetExpenseDialog(
                      context: context,
                      categoryId: categoryId,
                      categoryName: label,
                      categoryColor: color,
                      userId: userId,
                      initialTab: 1, // Start with expense tab
                    );
                  }
                },
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
                          CategoryColors.getIconByIndex(index),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // Animated amount display
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 800),
                        tween: Tween<double>(
                          begin: 0,
                          end: amount - spentAmount,
                        ),
                        builder: (context, value, child) {
                          return Text(
                            formatCurrency(value),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                      Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CategoriesSection extends ConsumerStatefulWidget {
  final String userId;

  const CategoriesSection({super.key, required this.userId});

  @override
  ConsumerState<CategoriesSection> createState() => _CategoriesSectionState();
}

class _CategoriesSectionState extends ConsumerState<CategoriesSection> {
  int? expandedIndex;
  int? pressedIndex;

  // Updated to use Map<String, dynamic> with double amounts
  // Using shared color palette from CategoryColors

  @override
  Widget build(BuildContext context) {
    const List<String> customOrder = [
      "Fixed Expenses",
      "Living Expenses",
      "Entertainment & Personal",
      "Education & Self-improvement",
      "Other Expenses",
      "Saving",
    ];
    final categoriesAsync = ref.watch(expenseCategoriesNotifierProvider);
    final balanceAsync = ref.watch(balanceNotifierProvider(widget.userId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Categories',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              FloatingActionButton.small(
                onPressed: () {},
                backgroundColor: Theme.of(context).primaryColor,
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ],
          ),
        ),
        const SizedBox(height: 5),
        Builder(
          builder: (context) {
            if (categoriesAsync.hasError) {
              debugPrint('ERROR: Categories error: ${categoriesAsync.error}');
              return Center(
                child: Column(
                  children: [
                    Text('Error loading categories: ${categoriesAsync.error}'),
                    ElevatedButton(
                      onPressed: () =>
                          ref.refresh(expenseCategoriesNotifierProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            // Check balance
            if (balanceAsync.hasError) {
              debugPrint('ERROR: Balance error: ${balanceAsync.error}');
              debugPrint(
                'ERROR: Balance stackTrace: ${balanceAsync.stackTrace}',
              );
              return Center(
                child: Text('Error loading balance: ${balanceAsync.error}'),
              );
            }

            // Check if both are loaded
            if (categoriesAsync.hasValue && balanceAsync.hasValue) {
              debugPrint(
                'SUCCESS: Both categories and balance loaded successfully',
              );
              final categories = categoriesAsync.value!;
              final balance = balanceAsync.value!;
              debugPrint(
                'DEBUG: Categories count: ${categories.length}, Balance userId: ${balance.userId}',
              );

              // Filter to only show expense categories
              final expenseCategories =
                  categories
                      .where(
                        (category) => category.type == CategoryType.expense,
                      )
                      .toList()
                    ..sort(
                      (a, b) => customOrder
                          .indexOf(a.categoryName)
                          .compareTo(customOrder.indexOf(b.categoryName)),
                    );
              debugPrint(
                'DEBUG: Expense categories count: ${expenseCategories.length}',
              );

              if (expenseCategories.isEmpty) {
                debugPrint('DEBUG: No expense categories, showing empty state');
                return _buildEmptyState();
              }

              debugPrint(
                'DEBUG: Building categories list with ${expenseCategories.length} categories',
              );
              return _buildCategoriesList(expenseCategories, balance);
            }

            // Show loading if either is still loading
            debugPrint(
              'DEBUG: Still loading - categories.isLoading: ${categoriesAsync.isLoading}, balance.isLoading: ${balanceAsync.isLoading}',
            );
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.category_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No Categories Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first expense category to start budgeting',
            style: TextStyle(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _showSpendingLimitDialog(null, null),
            icon: const Icon(Icons.add),
            label: const Text('Add Category'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesList(
    List<ExpenseCategory> categories,
    Balance balance,
  ) {
    return Column(
      children: [
        ...categories.asMap().entries.map((entry) {
          final index = entry.key;
          final category = entry.value;
          final color = CategoryColors.getColorByIndex(index);

          // Find budget for this category
          final budget =
              balance.budgets
                  .where((b) => b.categoryId == category.exCid)
                  .isNotEmpty
              ? balance.budgets.firstWhere(
                  (b) => b.categoryId == category.exCid,
                )
              : Budget(
                  budgetId: '',
                  userId: widget.userId,
                  categoryId: category.exCid,
                  accountId: '',
                  budgetAmount: 0,
                  startDate: DateTime.now(),
                  endDate: DateTime.now(),
                );

          // Calculate spent amount for this category (mock data for now)
          final spentAmount = budget.spentAmount; // Mock: 60% spent

          return CategoryItem(
            index: index,
            label: category.categoryName,
            amount: budget.budgetAmount,
            spentAmount: spentAmount,
            color: color,
            isExpanded: expandedIndex == index,
            onTap: () {
              setState(() {
                expandedIndex = expandedIndex == index ? null : index;
              });
            },
            isPressed: false,
            onActionPressed: () {
              debugPrint(
                'DEBUG: Set budget button pressed for category: ${category.exCid}',
              );
              _showSpendingLimitDialog(category.exCid, balance);
            },
            categoryId: category.exCid,
            userId: widget.userId,
          );
        }),
      ],
    );
  }

  void _showAddCategoryDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    showCustomBottomSheet(
      context: context,
      title: 'Add New Category',
      actionText: 'CREATE',
      actionColor: Colors.blue,
      content: Column(
        children: [
          buildFormField(label: 'Category Name', controller: nameController),
          const SizedBox(height: 16),
          buildFormField(
            label: 'Description (Optional)',
            controller: descriptionController,
          ),
        ],
      ),
      onActionPressed: () async {
        final name = nameController.text.trim();
        if (name.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter a category name')),
          );
          return;
        }

        try {
          await ref
              .read(expenseCategoriesNotifierProvider.notifier)
              .createCategory(
                categoryName: name,
                description: descriptionController.text.trim().isEmpty
                    ? null
                    : descriptionController.text.trim(),
              );
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Category created successfully')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error creating category: $e')),
          );
        }
      },
    );
  }

  void _showSpendingLimitDialog([String? categoryId, Balance? balance]) {
    debugPrint(
      'DEBUG: _showAddExpenseDialog called with categoryId: $categoryId',
    );

    if (categoryId != null) {
      // Find the category name and color
      final categoriesAsync = ref.read(expenseCategoriesNotifierProvider);
      if (categoriesAsync.hasValue) {
        final category = categoriesAsync.value!
            .where((c) => c.exCid == categoryId)
            .firstOrNull;

        if (category != null) {
          final categoryIndex = categoriesAsync.value!
              .where((c) => c.type == CategoryType.expense)
              .toList()
              .indexWhere((c) => c.exCid == categoryId);
          final color = CategoryColors.getColorByIndex(categoryIndex);

          showUnifiedBudgetExpenseDialog(
            context: context,
            categoryId: categoryId,
            categoryName: category.categoryName,
            categoryColor: color,
            userId: widget.userId,
            balance: balance,
            initialTab: 0, // Start with budget tab
          );
        }
      }
    }
  }
}
