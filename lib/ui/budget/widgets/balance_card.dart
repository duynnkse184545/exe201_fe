import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../model/balance/balance.dart';
import '../../../model/expense/expense.dart';
import '../../../model/expense_category/expense_category.dart';
import '../../../model/financial_account/financial_account.dart';
import '../../../model/selected_month_data/selected_month_data.dart';
import '../../../provider/providers.dart';
import '../../extra/custom_dialog.dart';
import '../../extra/custom_field.dart';
import '../../extra/header.dart';


extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

class BalanceCard extends ConsumerStatefulWidget {
  final String userId;

  const BalanceCard({super.key, required this.userId});

  @override
  ConsumerState<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends ConsumerState<BalanceCard> with PressedStateMixin {
  final PageController _controller = PageController();
  int _currentPage = 0;
  double _displayedBalance = 0;
  double _targetBalance = 0;

  @override
  void initState() {
    super.initState();
    // Animation state will be updated from provider data
  }

  @override
  Widget build(BuildContext context) {
    final selectedDataAsync = ref.watch(selectedMonthDataProvider);

    return selectedDataAsync.when(
      loading: () => _buildLoadingCard(),
      error: (error, stack) => _buildErrorCard(error.toString()),
      data: (data) {
        if (data == null) {
          return _buildErrorCard('No data available for selected month');
        }
        return _buildBalanceCard(data);
      },
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      width: double.maxFinite,
      margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(16),
        child: const SizedBox(
          width: double.infinity,
          height: 120,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Container(
      width: double.maxFinite,
      margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.red[300],
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: double.infinity,
          height: 120,
          child: Center(
            child: Text(
              'Error: $error',
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard(SelectedMonthData data) {
    // Get the actual account balance from provider data
    final actualBalance = data.availableBalance;
    // Update animation targets when data changes
    if (_targetBalance != actualBalance) {
      _displayedBalance = _targetBalance;
      _targetBalance = actualBalance;
    }

    final balanceData = ref.read(balanceNotifierProvider).value;
    final fixedIncomeAmount = _getIncomeAmount(balanceData, "Salary");
    final externalIncomeAmount = _getIncomeAmount(balanceData, "Other Source");

    final List<Map<String, dynamic>> balanceItems = [
      {
        "title": data.isCurrentMonth ? "Available balance" : "Balance (${data.isPastMonth ? 'Transferred' : 'Not Available'})",
        "amount": formatCurrency(actualBalance),
        "action": data.isCurrentMonth ? () => _showBalanceDialog(context) : null,
        "isAnimated": data.isCurrentMonth, // Only animate current month
      },
      {
        "title": "Fixed Income",
        "amount": formatCurrency(fixedIncomeAmount),
        "action": data.isCurrentMonth ? () => _showIncomeDialog(context, "Salary", true) : null,
        "isAnimated": false,
      },
      {
        "title": "External Income",
        "amount": formatCurrency(externalIncomeAmount),
        "action": data.isCurrentMonth ? () => _showIncomeDialog(context, "External Income", false) : null,
        "isAnimated": false,
      },
      {
        "title": "Expenses",
        "amount": formatCurrency(data.totalExpenses),
        "action": () async => debugPrint("Tapped: expenses"),
        "isAnimated": false,
      },
      {
        "title": data.isPastMonth ? "Net Amount (Final)" : "Net Amount",
        "amount": formatCurrency(data.netAmount),
        "action": () async => debugPrint("Tapped: net amount"),
        "isAnimated": false,
      },
    ];

    return Container(
      width: double.maxFinite,
      margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: getPressedStateColor(null, isPressed),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          splashColor: Colors.black.withValues(alpha: 0.5),
          onTap: () => executeWithPressedState(balanceItems[_currentPage]['action']),
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 70,
                    child: PageView.builder(
                      controller: _controller,
                      itemCount: balanceItems.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        final item = balanceItems[index];
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item['title']!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            item['isAnimated'] == true
                                ? TweenAnimationBuilder<double>(
                              duration: const Duration(milliseconds: 800),
                              tween: Tween<double>(
                                begin: _displayedBalance,
                                end: actualBalance,
                              ),
                              onEnd: () {
                                _displayedBalance = actualBalance;
                              },
                              builder: (context, value, child) {
                                return Text(
                                  formatCurrency(value),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 30,
                                    fontWeight: FontWeight.w900,
                                  ),
                                );
                              },
                            )
                                : Text(
                              item['amount'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  SmoothPageIndicator(
                    controller: _controller,
                    count: balanceItems.length,
                    effect: WormEffect(
                      activeDotColor: Colors.white,
                      dotColor: Colors.white.withValues(alpha: 0.5),
                      dotHeight: 5,
                      dotWidth: 5,
                      spacing: 5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  

  Future<Map<String, dynamic>?> _showBalanceDialog(BuildContext context) async {
    final amountController = TextEditingController();
    final accountNameController = TextEditingController();

    final result = await showCustomBottomSheet<Map<String, dynamic>>(
      context: context,
      title: 'Financial Account',
      actionText: 'SAVE',
      actionColor: Theme.of(context).primaryColor,
      content: Consumer(
        builder: (context, ref, child) {
          // Use balance provider data instead of separate accounts provider
          final balanceAsync = ref.watch(balanceNotifierProvider);

          return balanceAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) {
              debugPrint('ERROR: Balance provider failed: $error');
              return Column(
                children: [
                  const Icon(Icons.error, color: Colors.red),
                  Text('Error: $error'),
                  const SizedBox(height: 16),
                  _buildCreateAccountForm(amountController, accountNameController),
                ],
              );
            },
            data: (balance) {
              final accounts = balance.accounts;
              final hasAccount = accounts.isNotEmpty;
              final existingAccount = hasAccount ? accounts.first : null;

              // Pre-fill data when account exists and controllers are empty
              if (hasAccount && existingAccount != null) {
                if (accountNameController.text.isEmpty) {
                  accountNameController.text = existingAccount.accountName;
                }
                if (amountController.text.isEmpty) {
                  amountController.text = existingAccount.balance.toString();
                }
              }

              return Column(
                children: [
                  // Account Name Input
                  buildFormField(
                    label: 'Account Name',
                    controller: accountNameController,
                    keyboardType: TextInputType.text,
                  ),

                  const SizedBox(height: 16),

                  // Amount Input
                  buildFormField(
                    label: hasAccount ? 'New Balance Amount' : 'Initial Balance',
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ],
              );
            },
          );
        },
      ),
      onActionPressed: () async {
        final amountText = amountController.text.trim();
        final accountName = accountNameController.text.trim();

        if (amountText.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter an amount')),
          );
          return;
        }

        if (accountName.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter an account name')),
          );
          return;
        }

        final amount = double.tryParse(amountText);
        if (amount == null || amount < 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter a valid amount')),
          );
          return;
        }

        try {
          // Show loading
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Processing...')),
          );

          // Use balance provider data instead of accounts provider
          final balanceAsync = ref.read(balanceNotifierProvider);
          final accounts = balanceAsync.when(
            data: (balance) {
              debugPrint('SUCCESS: Got ${balance.accounts.length} accounts from balance');
              return balance.accounts;
            },
            loading: () {
              debugPrint('LOADING: Balance provider loading...');
              return <FinancialAccount>[];
            },
            error: (error, stack) {
              debugPrint('ERROR: Balance provider failed: $error');
              return <FinancialAccount>[];
            },
          );
          final hasAccount = accounts.isNotEmpty;
          final existingAccount = hasAccount ? accounts.first : null;

          if (hasAccount && existingAccount != null) {
            // Update existing account using service directly
            debugPrint('UPDATE: Updating account ${existingAccount.accountId} with balance: $amount');
            final updateRequest = FinancialAccountRequest(
              accountId: existingAccount.accountId,
              accountName: accountName,
              balance: amount,
              currencyCode: existingAccount.currencyCode,
              isDefault: existingAccount.isDefault,
            );
            await ref.read(financialAccountServiceProvider).updateAccount(updateRequest);

            debugPrint('SUCCESS: Account updated successfully');
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Account updated successfully!')),
            );

          } else {
            // Create new account using service directly
            debugPrint('CREATE: Creating new account $accountName with balance: $amount');
            final request = FinancialAccountRequest(
              accountName: accountName,
              balance: amount,
              currencyCode: 'VND',
              isDefault: true,
            );
            await ref.read(financialAccountServiceProvider).createAccount(request);

            debugPrint('SUCCESS: Account created successfully');
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Account created successfully!')),
            );
          }

          // Refresh balance provider to get updated data
          await ref.read(balanceNotifierProvider.notifier).refresh();
          if (!context.mounted) return;
          Navigator.of(context).pop({
            'operation': hasAccount ? 'update' : 'create',
            'amount': amount,
            'accountName': accountName,
          });

        } catch (e, stackTrace) {
          debugPrint('ERROR: Dialog action failed: $e');
          debugPrint('STACK: $stackTrace');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      },
    );
    return result;
  }

  // Helper method for create account form
  Widget _buildCreateAccountForm(TextEditingController amountController, TextEditingController accountNameController) {
    return Column(
      children: [
        buildFormField(
          label: 'Account Name',
          controller: accountNameController,
          keyboardType: TextInputType.text,
        ),
        const SizedBox(height: 16),
        buildFormField(
          label: 'Initial Balance',
          controller: amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
      ],
    );
  }

  // Helper method to get income amount for specific category
  double _getIncomeAmount(Balance? balance, String categoryName) {
    if (balance == null) return 0.0;
    
    final incomeExpenses = balance.expenses.where((expense) =>
      expense.categoryName == categoryName
    );
    
    return incomeExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  Future<void> _showIncomeDialog(BuildContext context, String categoryName, bool isPersistent) async {
    final amountController = TextEditingController();

    // Get existing income amount for this category
    final balanceData = ref.read(balanceNotifierProvider).value;
    final existingAmount = _getIncomeAmount(balanceData, categoryName);
    if (existingAmount > 0) {
      amountController.text = existingAmount.toString();
    }

    await showCustomBottomSheet<void>(
      context: context,
      title: categoryName,
      actionText: 'SAVE',
      actionColor: Colors.green,
      content: Column(
        children: [
          if (isPersistent)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Fixed income persists across months',
                      style: TextStyle(color: Colors.green[700]),
                    ),
                  ),
                ],
              ),
            ),
          
          if (!isPersistent)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_outlined, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'External income resets each month',
                      style: TextStyle(color: Colors.orange[700]),
                    ),
                  ),
                ],
              ),
            ),

          buildFormField(
            label: '$categoryName Amount',
            controller: amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ],
      ),
      onActionPressed: () async {
        final amountText = amountController.text.trim();

        if (amountText.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter an amount')),
          );
          return;
        }

        final amount = double.tryParse(amountText);
        if (amount == null || amount < 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter a valid amount')),
          );
          return;
        }

        try {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Processing...')),
          );

          await _createOrUpdateIncomeExpense(categoryName, amount);

          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$categoryName updated successfully!')),
          );
          Navigator.of(context).pop();

        } catch (e) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      },
    );
  }

  Future<void> _createOrUpdateIncomeExpense(String categoryName, double amount) async {
    final balanceData = ref.read(balanceNotifierProvider).value;
    if (balanceData == null || balanceData.accounts.isEmpty) {
      throw Exception('No account found. Please create an account first.');
    }

    final defaultAccount = balanceData.accounts.first;
    
    // Check if income category exists, if not create it
    final categoriesData = ref.read(expenseCategoriesNotifierProvider).value;
    ExpenseCategory? incomeCategory = categoriesData?.firstWhere(
      (cat) => cat.categoryName == categoryName && cat.type == CategoryType.income,
      orElse: () => throw StateError('Category not found'),
    );


    // Check if expense already exists for this category
    final existingExpense = balanceData.expenses.where((expense) => 
      expense.categoryName == categoryName
    ).firstOrNull;

    if (existingExpense != null) {
      // Update existing expense
      final updateRequest = ExpenseRequest(
        expensesId: existingExpense.expensesId,
        amount: amount,
        description: categoryName,
        exCid: incomeCategory!.exCid,
        accountId: defaultAccount.accountId,
      );
      await ref.read(expenseServiceProvider).updateExpense(updateRequest);
    } else {
      // Create new expense
      final expenseRequest = ExpenseRequest(
        amount: amount,
        description: categoryName,
        exCid: incomeCategory!.exCid,
        accountId: defaultAccount.accountId,
      );
      await ref.read(expenseServiceProvider).createExpense(expenseRequest);
    }

    // Refresh balance to show updated data
    await ref.read(balanceNotifierProvider.notifier).refresh();
  }

}