import 'package:exe201/budget/widgets/balance_card.dart';
import 'package:exe201/budget/widgets/budget_categories.dart';
import 'package:exe201/budget/widgets/month_slider.dart';
import 'package:exe201/budget/widgets/recent_transaction.dart';
import 'package:flutter/material.dart';


class BudgetTab extends StatelessWidget {
  const BudgetTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF3F4F6),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MonthSlider(),
              BalanceCard(),
              CategoriesSection(),
              RecentTransactionsSection()
            ],
          ),
        ),
      ),
    );
  }

}
