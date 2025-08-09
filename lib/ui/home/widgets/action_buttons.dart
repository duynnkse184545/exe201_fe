import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../extra/custom_dialog.dart';
import '../../extra/custom_field.dart';
import '../../extra/category_colors.dart';
import '../../../provider/providers.dart';
import '../../../model/balance/balance.dart';
import '../../../model/expense/expense.dart';
import '../../../model/expense_category/expense_category.dart';
import '../../extra/header.dart';

class ActionButtons extends ConsumerStatefulWidget {
  final String userId;
  
  const ActionButtons({
    super.key,
    required this.userId,
  });

  @override
  ConsumerState<ActionButtons> createState() => _ActionButtonsState();
}

class _ActionButtonsState extends ConsumerState<ActionButtons> {
  String? selectedCategoryId;
  String selectedCategoryName = 'Select Category';
  String selectedCategoryIcon = '';
  Color? selectedCategoryColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildActionButton(
          onPressed: () => _showAddTransactionDialog(context),
          icon: Icons.add,
          label: 'Add Expense',
          backgroundColor: Colors.grey[600]!,
        ),
        const SizedBox(width: 16),
        _buildActionButton(
          onPressed: () => _showStartTimerDialog(context),
          icon: Icons.play_arrow,
          label: 'Start Timer',
          backgroundColor: const Color(0xFFEF4444),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color backgroundColor,
  }) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20),
            Text(
              label,
              style: const TextStyle(fontSize: 15),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // Add Transaction Dialog with Server Integration
  void _showAddTransactionDialog(BuildContext context) {
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();

    showCustomBottomSheet<void>(
      context: context,
      title: 'Add Expense',
      actionText: 'Confirm',
      actionColor: Theme.of(context).primaryColor,
      content: StatefulBuilder(
        builder: (context, setDialogState) {
          // Debug print to check state
          debugPrint('Dialog state - selectedCategoryId: $selectedCategoryId');
          
          return Column(
            children: [
              // Category Selection (moved to top)
              _buildCategorySelectorForDialog(setDialogState),
              const SizedBox(height: 16),
              
              // Budget info line
              _buildBudgetInfoLine(),
              const SizedBox(height: 16),

              buildFormField(
                label: 'Amount',
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                enabled: selectedCategoryId != null,
              ),
              const SizedBox(height: 16),

              buildFormField(
                label: 'Description',
                controller: descriptionController,
                enabled: selectedCategoryId != null,
              ),
              const SizedBox(height: 16),

              _buildQuickAmountButtons(amountController),
            ],
          );
        },
      ),
      onActionPressed: () async {
        debugPrint('Confirm button pressed - selectedCategoryId: $selectedCategoryId');
        
        if (selectedCategoryId == null) {
          _showErrorSnackBar(context, 'Please select a category first');
          return;
        }
        
        await _handleAddTransaction(
          context,
          amountController,
          descriptionController,
        );
      },
    ).then((_) {
      // Reset category selection when dialog is closed (dismissed or completed)
      setState(() {
        selectedCategoryId = null;
        selectedCategoryName = 'Select Category';
        selectedCategoryIcon = '';
        selectedCategoryColor = null;
      });
    });
  }

  Widget _buildCategorySelectorForDialog(StateSetter setDialogState) {
    return Consumer(
      builder: (context, ref, child) {
        final categoriesAsync = ref.watch(expenseCategoriesNotifierProvider);
        
        return GestureDetector(
          onTap: () => _showCategorySelectionDialog(context, categoriesAsync, setDialogState),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                // Show selected category icon or default icon
                selectedCategoryId != null 
                    ? CircleAvatar(
                        backgroundColor: selectedCategoryColor,
                        radius: 12,
                        child: Text(
                          selectedCategoryIcon,
                          style: const TextStyle(fontSize: 12),
                        ),
                      )
                    : Icon(Icons.category, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    selectedCategoryName,
                    style: TextStyle(
                      color: selectedCategoryId != null 
                          ? Colors.black87 
                          : Colors.grey[600],
                      fontWeight: selectedCategoryId != null 
                          ? FontWeight.w500 
                          : FontWeight.normal,
                    ),
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[600]),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCategorySelectionDialog(BuildContext context, AsyncValue<List<ExpenseCategory>> categoriesAsync, StateSetter? setDialogState) {
    showCustomBottomSheet<void>(
      context: context,
      title: 'Select Category',
      actionText: 'CANCEL',
      actionColor: Colors.grey,
      content: SizedBox(
        height: 300,
        child: categoriesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  'Failed to load categories',
                  style: TextStyle(color: Colors.red[600]),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => ref.refresh(expenseCategoriesNotifierProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          data: (categories) {
            // Filter and sort expense categories using the same logic as recent transactions
            final expenseCategories = categories
                .where((category) => category.type == CategoryType.expense)
                .toList()
              ..sort((a, b) => CategoryColors.customOrder.indexOf(a.categoryName).compareTo(
                  CategoryColors.customOrder.indexOf(b.categoryName)));

            if (expenseCategories.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.category_outlined, size: 48, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No expense categories available',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: expenseCategories.length,
              itemBuilder: (context, index) {
                final category = expenseCategories[index];
                final isSelected = selectedCategoryId == category.exCid;
                
                // Get category style using the same logic as recent transactions
                final style = CategoryColors.getStyleByIndex(index);
                
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: style.color,
                    child: Text(
                      style.icon,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  title: Text(
                    category.categoryName,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? style.color : null,
                    ),
                  ),
                  subtitle: category.description != null 
                      ? Text(category.description!) 
                      : null,
                  trailing: isSelected 
                      ? Icon(
                          Icons.check_circle,
                          color: style.color,
                        )
                      : null,
                  onTap: () {
                    // Get category style for icon and color
                    final style = CategoryColors.getStyleByIndex(index);
                    
                    // Update both the main widget state and dialog state if provided
                    setState(() {
                      selectedCategoryId = category.exCid;
                      selectedCategoryName = category.categoryName;
                      selectedCategoryIcon = style.icon;
                      selectedCategoryColor = style.color;
                    });
                    
                    // Update dialog state if StateSetter is provided
                    if (setDialogState != null) {
                      setDialogState(() {
                        selectedCategoryId = category.exCid;
                        selectedCategoryName = category.categoryName;
                        selectedCategoryIcon = style.icon;
                        selectedCategoryColor = style.color;
                      });
                    }
                    
                    Navigator.of(context).pop();
                    // Debug print to verify selection
                    print('Selected category: ${category.categoryName} (ID: ${category.exCid})');
                  },
                );
              },
            );
          },
        ),
      ),
      onActionPressed: () async => Navigator.of(context).pop(),
    );
  }

  Future<void> _handleAddTransaction(
    BuildContext context,
    TextEditingController amountController,
    TextEditingController descriptionController,
  ) async {
    final amountText = amountController.text.trim();
    final description = descriptionController.text.trim();

    // Validation
    if (description.isEmpty || amountText.isEmpty) {
      _showErrorSnackBar(context, 'Please fill in required fields');
      return;
    }

    if (selectedCategoryId == null) {
      _showErrorSnackBar(context, 'Please select a category');
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      _showErrorSnackBar(context, 'Please enter a valid amount');
      return;
    }

    try {
      // Get the default account from balance data
      final balanceData = ref.read(balanceNotifierProvider).value;
      if (balanceData == null || balanceData.accounts.isEmpty) {
        _showErrorSnackBar(context, 'No account found. Please create an account first.');
        return;
      }

      final defaultAccount = balanceData.accounts.first;
      
      // Create expense request
      final expenseRequest = ExpenseRequest(
        amount: amount,
        description: description,
        exCid: selectedCategoryId!,
        accountId: defaultAccount.accountId,
      );
      // Create the expense
      await ref.read(expenseServiceProvider).createExpense(expenseRequest);
      
      // Refresh balance data to reflect the new expense
      ref.invalidate(balanceNotifierProvider);

      if(!context.mounted) return;
      Navigator.of(context).pop();
      // Note: Category state will be reset by the dialog's .then() callback
      _showSuccessSnackBar(context, 'Expense added successfully!');
      
    } catch (e) {
      _showErrorSnackBar(context, 'Failed to add expense: ${e.toString()}');
    }
  }

  // Start Timer Dialog (you can expand this for task management)
  void _showStartTimerDialog(BuildContext context) {
    showCustomBottomSheet(
      context: context,
      title: 'Start Timer',
      actionText: 'START',
      actionColor: const Color(0xFFEF4444),
      content: Column(
        children: [
          const Text(
            'Task: EXE Figma',
            style: TextStyle(
              color: Color(0xFFEF4444),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '2 hours',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          // You can add timer configuration here
          _buildTimerConfiguration(),
        ],
      ),
      onActionPressed: () => _handleStartTimer(context),
    );
  }

  Widget _buildTimerConfiguration() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Focus Time'),
              Text('25 min'),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Break Time'),
              Text('5 min'),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleStartTimer(BuildContext context) async {
    try {
      // TODO: Implement timer logic
      // You could integrate with a task management system
      
      Navigator.of(context).pop();
      _showSuccessSnackBar(context, 'Timer started!');
      
    } catch (e) {
      _showErrorSnackBar(context, 'Failed to start timer: ${e.toString()}');
    }
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    debugPrint(message);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildQuickAmountButtons(TextEditingController controller) {
    final quickAmounts = [10000, 50000, 100000, 200000, 500000];

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick amounts:',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: quickAmounts.map((amount) {
            return ActionChip(
              label: Text(
                formatCurrency(amount.toDouble()),
                style: const TextStyle(fontSize: 15),
              ),
              onPressed: selectedCategoryId != null 
                  ? () => controller.text = amount.toString()
                  : null,
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              side: BorderSide(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
              ),
              labelStyle: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w500,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBudgetInfoLine() {
    if (selectedCategoryId == null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Please select a category first to continue!',
                style: TextStyle(
                  color: Colors.orange[700],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Consumer(
      builder: (context, ref, child) {
        final balanceAsync = ref.watch(balanceNotifierProvider);
        
        return balanceAsync.when(
          loading: () => Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 8),
                Text('Loading budget info...'),
              ],
            ),
          ),
          error: (error, stack) => Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red[700], size: 20),
                const SizedBox(width: 8),
                const Text('Error loading budget info'),
              ],
            ),
          ),
          data: (balance) {
            // Find budget for selected category
            final budget = balance.budgets
                .where((b) => b.categoryId == selectedCategoryId)
                .firstOrNull;
            
            if (budget == null || budget.budgetAmount <= 0) {
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_outlined, color: Colors.red[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'No budget set for this category. Please set a budget first.',
                        style: TextStyle(
                          color: Colors.red[700],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            // Show budget info
            final remainingAmount = budget.remainingAmount;
            final budgetAmount = budget.budgetAmount;
            final usedAmount = budgetAmount - remainingAmount;
            final usedPercentage = (usedAmount / budgetAmount * 100).clamp(0, 100);
            
            MaterialColor infoColor;
            IconData infoIcon;
            String statusText;
            
            if (usedPercentage >= 100) {
              infoColor = Colors.red;
              infoIcon = Icons.error_outline;
              statusText = 'Budget exceeded!';
            } else if (usedPercentage >= 80) {
              infoColor = Colors.orange;
              infoIcon = Icons.warning_outlined;
              statusText = 'Near budget limit';
            } else {
              infoColor = Colors.green;
              infoIcon = Icons.check_circle_outline;
              statusText = 'Budget healthy';
            }

            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: infoColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: infoColor.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(infoIcon, color: infoColor.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '$statusText - ${formatCurrency(remainingAmount)} remaining',
                          style: TextStyle(
                            color: infoColor.shade700,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Used: ${formatCurrency(usedAmount)}',
                        style: TextStyle(
                          color: infoColor.shade600,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        'Budget: ${formatCurrency(budgetAmount)}',
                        style: TextStyle(
                          color: infoColor.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

}