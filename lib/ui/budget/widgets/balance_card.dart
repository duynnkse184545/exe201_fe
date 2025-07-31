import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../model/models.dart';
import '../../../provider/providers.dart';
import '../../extra/custom_dialog.dart';
import '../../extra/custom_field.dart';


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
    final balanceAsync = ref.watch(balanceNotifierProvider(widget.userId));

    return balanceAsync.when(
      loading: () => _buildLoadingCard(),
      error: (error, stack) => _buildErrorCard(error.toString()),
      data: (balance) {
        // Use accounts from balance provider (cached data)
        final accounts = balance.accounts;
        return _buildBalanceCard(balance, accounts);
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

  Widget _buildBalanceCard(Balance balance, List<FinancialAccount> accounts) {
    // Get the actual account balance from provider data
    final currentAccount = accounts.isNotEmpty ? accounts.first : null;
    final actualBalance = currentAccount?.balance ?? balance.availableBalance;
    // Update animation targets when data changes
    if (_targetBalance != actualBalance) {
      _displayedBalance = _targetBalance;
      _targetBalance = actualBalance;
    }

    final List<Map<String, dynamic>> balanceItems = [
      {
        "title": "Available balance",
        "amount": _formatCurrency(actualBalance),
        "action": () => _showBalanceDialog(context),
        "isAnimated": true, // Mark this for animation
      },
      {
        "title": "Income",
        "amount": _formatCurrency(balance.monthlyIncome),
        "action": () async => debugPrint("Tapped: income"),
        "isAnimated": false,
      },
      {
        "title": "Expenses",
        "amount": _formatCurrency(balance.monthlyExpenses),
        "action": () async => debugPrint("Tapped: expenses"),
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
                                  _formatCurrency(value),
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

  String _formatCurrency(double value) {
    return '${value
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (match) => '${match[1]}.')} ₫';
  }

  Future<Map<String, dynamic>?> _showBalanceDialog(BuildContext context) async {
    final amountController = TextEditingController();
    final accountNameController = TextEditingController();

    final result = await showCustomBottomSheet<Map<String, dynamic>>(
      context: context,
      title: 'Financial Account',
      actionText: 'SAVE',
      actionColor: const Color(0xff7583ca),
      content: Consumer(
        builder: (context, ref, child) {
          // Use balance provider data instead of separate accounts provider
          final balanceAsync = ref.watch(balanceNotifierProvider(widget.userId));

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
                  // Show current account info if updating
                  if (hasAccount && existingAccount != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.blue),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Current: ${existingAccount.accountName} - ${existingAccount.balance.toStringAsFixed(0)} ${existingAccount.currencyCode}',
                              style: const TextStyle(color: Colors.blue),
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (hasAccount) const SizedBox(height: 16),

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
          final balanceAsync = ref.read(balanceNotifierProvider(widget.userId));
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
          await ref.read(balanceNotifierProvider(widget.userId).notifier).refresh();
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
}