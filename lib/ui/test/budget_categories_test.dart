import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../provider/providers.dart';
import '../../model/models.dart';
import '../extra/custom_dialog.dart';
import '../extra/custom_field.dart';
import '../extra/category_colors.dart';
import 'demo.dart';

class CategoryItemTest extends StatelessWidget {
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

  const CategoryItemTest({
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
      child: Material(
        color: Colors.transparent,
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
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            CategoryColors.getIconByIndex(index),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          label,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 1000),
                        tween: Tween<double>(
                          begin: 0,
                          end: amount - spentAmount,
                        ),
                        builder: (context, value, child) {
                          return Text(
                            _formatCurrency(value),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                  if (isExpanded) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Initial value:'),
                              Text(
                                _formatCurrency(amount),
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
                                _formatCurrency(spentAmount),
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
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  String _formatCurrency(double value) {
    return '${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')} ₫';
  }
}

class CategoriesSectionTest extends ConsumerStatefulWidget {
  final String userId;

  const CategoriesSectionTest({super.key, required this.userId});

  @override
  ConsumerState<CategoriesSectionTest> createState() =>
      _CategoriesSectionTestState();
}

class _CategoriesSectionTestState extends ConsumerState<CategoriesSectionTest> {
  int? expandedIndex;

  String _formatCurrency(double value) {
    return '${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')} VND';
  }

  // Using shared color palette from CategoryColors

  @override
  Widget build(BuildContext context) {
    const List<String> customOrder =
    [
      "Fixed Expenses",
    "Living Expenses",
    "Entertainment & Personal",
    "Education & Self-improvement",
    "Other Expenses",
    "Saving"
    ];
    debugPrint('DEBUG: CategoriesSectionTest build() called');
    final categoriesAsync = ref.watch(expenseCategoriesNotifierProvider);
    debugPrint('DEBUG: Categories state: ${categoriesAsync.runtimeType}');
    final balanceAsync = ref.watch(balanceNotifierProvider(widget.userId));
    debugPrint('DEBUG: Balance state: ${balanceAsync.runtimeType}');

    return Container(
      margin: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Budget Categories',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                FloatingActionButton.small(
                  onPressed: () {},
                  backgroundColor: const Color(0xff7583ca),
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Builder(
            builder: (context) {
              if (categoriesAsync.hasError) {
                debugPrint('ERROR: Categories error: ${categoriesAsync.error}');
                return Center(
                  child: Column(
                    children: [
                      Text(
                        'Error loading categories: ${categoriesAsync.error}',
                      ),
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
                final expenseCategories = categories
                    .where((category) => category.type == CategoryType.expense)
                    .toList()..sort((a, b) => customOrder.indexOf(a.categoryName).compareTo(
                    customOrder.indexOf(b.categoryName)));
                debugPrint(
                  'DEBUG: Expense categories count: ${expenseCategories.toString()}',
                );

                if (expenseCategories.isEmpty) {
                  debugPrint(
                    'DEBUG: No expense categories, showing empty state',
                  );
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
      ),
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

          return CategoryItemTest(
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
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showAddCategoryDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Add New Category'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
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
    debugPrint('DEBUG: _showAddExpenseDialog called with categoryId: $categoryId');
    
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