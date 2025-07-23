import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'balance_card_test.dart';
import 'budget_categories_test.dart';
import '../budget/widgets/month_slider.dart';
import 'recent_transactions_test.dart';

class BudgetTabTest extends ConsumerWidget {
  final String userId;
  
  const BudgetTabTest({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const MonthSlider(),
              BalanceCardTest(userId: userId),
              CategoriesSectionTest(userId: userId),
              RecentTransactionsSectionTest(userId: userId),
            ],
          ),
        ),
      ),
    );
  }
}