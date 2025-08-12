import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../provider/providers.dart';
import '../../model/balance/balance.dart';
import '../../model/budget/budget.dart';
import '../../model/expense/expense.dart';
import '../../model/expense_category/expense_category.dart';
import 'custom_dialog.dart';
import 'custom_field.dart';

class UnifiedBudgetExpenseDialog extends ConsumerStatefulWidget {
  final String categoryId;
  final String categoryName;
  final Color categoryColor;
  final String userId;
  final Balance? balance;
  final int initialTab; // 0 for budget, 1 for expense
  final VoidCallback? onActionComplete; // Callback to close the dialog

  const UnifiedBudgetExpenseDialog({
    super.key,
    required this.categoryId,
    required this.categoryName,
    required this.categoryColor,
    required this.userId,
    this.balance,
    this.initialTab = 0,
    this.onActionComplete,
  });

  @override
  ConsumerState<UnifiedBudgetExpenseDialog> createState() =>
      _UnifiedBudgetExpenseDialogState();
}

class _UnifiedBudgetExpenseDialogState
    extends ConsumerState<UnifiedBudgetExpenseDialog>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // Budget controllers
  final _budgetAmountController = TextEditingController();

  // Expense controllers
  final _expenseAmountController = TextEditingController();
  final _expenseDescriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab,
    );

    // Add listener to update UI when tab changes
    _tabController.addListener(() {
      setState(() {});
    });

    // Pre-fill budget amount if exists
    _initializeBudgetAmount();
  }

  void _initializeBudgetAmount() {
    if (widget.balance != null) {
      final existingBudget = widget.balance!.budgets
          .where((b) => b.categoryId == widget.categoryId)
          .firstOrNull;

      if (existingBudget != null) {
        _budgetAmountController.text = existingBudget.budgetAmount.toString();
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _budgetAmountController.dispose();
    _expenseAmountController.dispose();
    _expenseDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab bar
        _buildTabBar(),

        // Tab content
        SizedBox(
          height: 300, // Fixed height for the tab content
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildBudgetTab(),
              _buildExpenseTab(),
            ],
          ),
        ),
      ],
    );
  }


  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabWidth = (constraints.maxWidth - 8) / 2; // Account for padding
          return Stack(
            children: [
              // Animated sliding background
              AnimatedPositioned(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOutCubic,
                left: _tabController.index == 0 ? 0 : tabWidth,
                top: 0,
                bottom: 0,
                child: Container(
                  width: tabWidth,
                  decoration: BoxDecoration(
                    color: widget.categoryColor,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: widget.categoryColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
              // Tab content
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _tabController.animateTo(0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: Icon(
                                Icons.account_balance_wallet,
                                key: ValueKey('budget_${_tabController.index == 0}'),
                                size: 18,
                                color: _tabController.index == 0 
                                    ? Colors.white 
                                    : Colors.grey[600],
                              ),
                            ),
                            const SizedBox(width: 8),
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 200),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _tabController.index == 0 
                                    ? Colors.white 
                                    : Colors.grey[600],
                              ),
                              child: const Text('Budget'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _tabController.animateTo(1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: Icon(
                                Icons.add_shopping_cart,
                                key: ValueKey('expense_${_tabController.index == 1}'),
                                size: 18,
                                color: _tabController.index == 1 
                                    ? Colors.white 
                                    : Colors.grey[600],
                              ),
                            ),
                            const SizedBox(width: 8),
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 200),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _tabController.index == 1 
                                    ? Colors.white 
                                    : Colors.grey[600],
                              ),
                              child: const Text('Expense'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBudgetTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current budget info

          const SizedBox(height: 16),

          buildFormField(
            label: 'Budget Amount',
            controller: _budgetAmountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),

          const SizedBox(height: 12),

          Text(
            'Set the spending limit for this category this month',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          // Budget tips
          _buildBudgetTips(),
        ],
      ),
    );
  }

  Widget _buildExpenseTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildFormField(
            label: 'Amount',
            controller: _expenseAmountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),

          const SizedBox(height: 16),

          buildFormField(
            label: 'Description (Optional)',
            controller: _expenseDescriptionController,
          ),

          const SizedBox(height: 24),

          // Quick amount buttons
          _buildQuickAmountButtons(),
        ],
      ),
    );
  }


  Widget _buildBudgetTips() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.blue[600]),
              const SizedBox(width: 8),
              Text(
                'Budget Tips',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '• Start with realistic amounts\n'
                '• Review and adjust monthly\n'
                '• Leave some buffer for unexpected expenses',
            style: TextStyle(color: Colors.blue[700], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAmountButtons() {
    final quickAmounts = [10000, 50000, 100000, 200000];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick amounts:',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: quickAmounts.map((amount) {
            return ActionChip(
              label: Text(_formatCurrency(amount.toDouble())),
              onPressed: () {
                _expenseAmountController.text = amount.toString();
              },
              backgroundColor: widget.categoryColor.withOpacity(0.1),
              side: BorderSide(color: widget.categoryColor.withOpacity(0.3)),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Public method to handle action from external button
  Future<void> handleAction() async {
    if (_tabController.index == 0) {
      await _handleBudgetAction();
    } else {
      await _handleExpenseAction();
    }
  }

  Future<void> _handleBudgetAction() async {
    final amountText = _budgetAmountController.text.trim();

    if (amountText.isEmpty) {
      _showSnackBar('Please enter a budget amount');
      return;
    }

    final budgetAmount = double.tryParse(amountText);
    if (budgetAmount == null || budgetAmount <= 0) {
      _showSnackBar('Please enter a valid budget amount');
      return;
    }

    try {
      _showSnackBar('Setting budget...');

      final balanceData = ref.read(balanceNotifierProvider).value;
      if (balanceData == null || balanceData.accounts.isEmpty) {
        _showSnackBar('No account found. Please create an account first.');
        return;
      }

      final defaultAccount = balanceData.accounts.first;
      final existingBudget = balanceData.budgets
          .where((b) => b.categoryId == widget.categoryId)
          .firstOrNull;

      if (existingBudget != null) {
        final updateRequest = BudgetRequest(
          budgetId: existingBudget.budgetId,
          categoryId: null,
          accountId: null,
          budgetAmount: budgetAmount,
        );
        await ref.read(budgetServiceProvider).updateBudget(updateRequest);
      } else {
        final request = BudgetRequest(
          categoryId: widget.categoryId,
          accountId: defaultAccount.accountId,
          budgetAmount: budgetAmount,
          isLocked: false,
        );
        await ref.read(budgetServiceProvider).createBudget(request);
      }

      await ref.read(balanceNotifierProvider.notifier).refresh();
      widget.onActionComplete?.call();
      _showSnackBar('Budget set successfully!');
    } catch (e) {
      _showSnackBar('Error setting budget: ${e.toString()}');
    }
  }

  Future<void> _handleExpenseAction() async {
    final amount = double.tryParse(_expenseAmountController.text.trim());

    if (amount == null || amount <= 0) {
      _showSnackBar('Please enter a valid amount');
      return;
    }

    try {
      final balanceData = ref.read(balanceNotifierProvider).value;

      if (balanceData == null || balanceData.accounts.isEmpty) {
        _showSnackBar('No account found. Please create an account first.');
        return;
      }

      final defaultAccount = balanceData.accounts.first;
      final expenseRequest = ExpenseRequest(
        amount: amount,
        description: _expenseDescriptionController.text.trim().isEmpty
            ? null
            : _expenseDescriptionController.text.trim(),
        exCid: widget.categoryId,
        accountId: defaultAccount.accountId,
      );

      await ref.read(expenseServiceProvider).createExpense(expenseRequest);
      await ref.read(balanceNotifierProvider.notifier).refresh();

      widget.onActionComplete?.call();
      _showSnackBar('Expense added successfully!');
    } catch (e) {
      _showSnackBar('Error adding expense: ${e.toString()}');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _formatCurrency(double value) {
    return '${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')} ₫';
  }
}

// Helper function to show the unified dialog
void showUnifiedBudgetExpenseDialog({
  required BuildContext context,
  required String categoryId,
  required String categoryName,
  required Color categoryColor,
  required String userId,
  Balance? balance,
  int initialTab = 0, // 0 for budget, 1 for expense
}) {
  final GlobalKey<_UnifiedBudgetExpenseDialogState> dialogKey = GlobalKey();
  
  showCustomBottomSheet(
    context: context,
    title: "Spending for $categoryName",
    actionText: "Confirm",
    actionColor: categoryColor,
    content: UnifiedBudgetExpenseDialog(
      key: dialogKey,
      categoryId: categoryId,
      categoryName: categoryName,
      categoryColor: categoryColor,
      userId: userId,
      balance: balance,
      initialTab: initialTab,
      onActionComplete: () => Navigator.of(context).pop(),
    ),
    onActionPressed: () async {
      // Trigger the action through the dialog's state
      await dialogKey.currentState?.handleAction();
    },
  );
}