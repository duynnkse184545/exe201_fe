import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../provider/providers.dart';
import '../../model/models.dart';
import '../extra/custom_dialog.dart';
import '../extra/custom_field.dart';

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
              _showAddExpenseDialog(context);
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
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          label,
                          style: const TextStyle(
                            fontSize: 16,
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
                              const Text('Budget Allocated:'),
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

  void _showAddExpenseDialog(BuildContext context) {
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();

    showCustomBottomSheet(
      context: context,
      title: 'Add Expense to $label',
      actionText: 'ADD EXPENSE',
      actionColor: const Color(0xff7583ca),
      content: Column(
        children: [
          // Category info
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Row(
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
                Expanded(
                  child: Text(
                    'Category: $label',
                    style: TextStyle(color: color, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),

          buildFormField(
            label: 'Amount',
            controller: amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 16),
          buildFormField(
            label: 'Description (Optional)',
            controller: descriptionController,
          ),
        ],
      ),
      onActionPressed: () async {
        await _handleAddExpense(
          context,
          amountController,
          descriptionController,
        );
      },
    );
  }

  Future<void> _handleAddExpense(
    BuildContext context,
    TextEditingController amountController,
    TextEditingController descriptionController,
  ) async {
    final amount = double.tryParse(amountController.text.trim());

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    try {
      // Get user's default account using Consumer/ProviderScope
      final container = ProviderScope.containerOf(context);
      final balanceData = container.read(balanceNotifierProvider(userId)).value;

      if (balanceData == null || balanceData.accounts.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No account found. Please create an account first.'),
          ),
        );
        return;
      }

      final defaultAccount = balanceData.accounts.first;

      // Create expense request
      final expenseRequest = ExpenseRequest(
        amount: amount,
        description: descriptionController.text.trim().isEmpty
            ? null
            : descriptionController.text.trim(),
        exCid: categoryId,
        accountId: defaultAccount.accountId,
        userId: userId,
      );

      // Add expense through service
      await container
          .read(expenseServiceProvider)
          .createExpense(expenseRequest);

      // Refresh balance provider to get updated data
      await container.read(balanceNotifierProvider(userId).notifier).refresh();

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense added successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding expense: ${e.toString()}')),
      );
    }
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

  final List<Color> categoryColors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.red,
    Colors.teal,
    Colors.indigo,
    Colors.pink,
  ];

  @override
  Widget build(BuildContext context) {
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
          // Handle both async values without nesting to avoid cycles
          Builder(
            builder: (context) {
              // Check categories first
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
                    .toList();
                debugPrint(
                  'DEBUG: Expense categories count: ${expenseCategories.length}',
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
            onPressed: () => _showAddExpenseDialog(null, null),
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
          final color = categoryColors[index % categoryColors.length];

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
          final spentAmount = budget.budgetAmount * 0.6; // Mock: 60% spent

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
              _showAddExpenseDialog(category.exCid, balance);
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

  void _showAddExpenseDialog([String? categoryId, Balance? balance]) {
    debugPrint(
      'DEBUG: _showAddExpenseDialog called with categoryId: $categoryId',
    );
    final budgetAmountController = TextEditingController();

    // Pre-fill existing budget amount if available
    if (categoryId != null && balance != null) {
      final existingBudget = balance.budgets
          .where((b) => b.categoryId == categoryId)
          .firstOrNull;

      if (existingBudget != null && budgetAmountController.text.isEmpty) {
        budgetAmountController.text = existingBudget.budgetAmount.toString();
      }
    }

    debugPrint('DEBUG: About to show dialog. CategoryId: $categoryId');
    showCustomBottomSheet(
      context: context,
      title: categoryId != null
          ? 'Set Budget for Category'
          : 'Add New Category',
      actionText: categoryId != null ? 'SET BUDGET' : 'CREATE CATEGORY',
      actionColor: const Color(0xff7583ca),
      content: categoryId != null
          ? _buildBudgetContent(categoryId, budgetAmountController, balance)
          : _buildCategoryContent(),
      onActionPressed: () async {
        if (categoryId != null) {
          await _handleBudgetAction(categoryId, budgetAmountController);
        } else {
          await _handleCategoryAction();
        }
      },
    );
  }

  Widget _buildBudgetContent(
    String categoryId,
    TextEditingController budgetAmountController,
    Balance? balance,
  ) {
    return Column(
      children: [
        // Show current budget info if exists
        Builder(
          builder: (context) {
            if (balance == null) return const SizedBox.shrink();

            final existingBudget = balance.budgets
                .where((b) => b.categoryId == categoryId)
                .firstOrNull;

            if (existingBudget != null) {
              return Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Current Budget: ${_formatCurrency(existingBudget.budgetAmount)}\nSpent: ${_formatCurrency(existingBudget.spentAmount)}',
                        style: const TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),

        buildFormField(
          label: 'Budget Amount',
          controller: budgetAmountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        const SizedBox(height: 8),
        Text(
          'Set the spending limit for this category this month',
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCategoryContent() {
    return Column(
      children: [
        buildFormField(
          label: 'Category Name',
          controller: TextEditingController(),
        ),
        const SizedBox(height: 16),
        buildFormField(
          label: 'Description (Optional)',
          controller: TextEditingController(),
        ),
      ],
    );
  }

  Future<void> _handleBudgetAction(
    String categoryId,
    TextEditingController budgetAmountController,
  ) async {
    final amountText = budgetAmountController.text.trim();

    if (amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a budget amount')),
      );
      return;
    }

    final budgetAmount = double.tryParse(amountText);
    if (budgetAmount == null || budgetAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid budget amount')),
      );
      return;
    }

    try {
      // Show loading
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Setting budget...')));

      // Get user's default account
      final balanceData = ref
          .read(balanceNotifierProvider(widget.userId))
          .value;
      if (balanceData == null || balanceData.accounts.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No account found. Please create an account first.'),
          ),
        );
        return;
      }

      final defaultAccount = balanceData.accounts.first;
      final now = DateTime.now();

      // Check if budget already exists
      final existingBudget = balanceData.budgets
          .where((b) => b.categoryId == categoryId)
          .firstOrNull;

      if (existingBudget != null) {
        // Update existing budget
        final updateRequest = BudgetRequest(
          budgetId: existingBudget.budgetId,
          // Required for update
          categoryId: null,
          accountId: null,
          budgetAmount: budgetAmount,
          userId: null,
        );
        await ref.read(budgetServiceProvider).updateBudget(updateRequest);
        debugPrint('SUCCESS: Budget updated for category $categoryId');
      } else {
        // Create new budget
        final request = BudgetRequest(
          categoryId: categoryId,
          accountId: defaultAccount.accountId,
          budgetAmount: budgetAmount,
          userId: widget.userId,
          isLocked: false,
        );

        await ref.read(budgetServiceProvider).createBudget(request);
        debugPrint('SUCCESS: Budget created for category $categoryId');
      }

      // Refresh balance provider to get updated data
      await ref.read(balanceNotifierProvider(widget.userId).notifier).refresh();

      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Budget set successfully!')));
    } catch (e, stackTrace) {
      debugPrint('ERROR: Failed to set budget: $e');
      debugPrint('STACK: $stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error setting budget: ${e.toString()}')),
      );
    }
  }

  Future<void> _handleCategoryAction() async {
    // Close current dialog and show the proper category creation dialog
    Navigator.of(context).pop();
    _showAddCategoryDialog();
  }
}
