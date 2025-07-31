import 'package:exe201/ui/budget/widgets/balance_card.dart';
import 'package:exe201/ui/budget/widgets/budget_categories.dart';
import 'package:exe201/ui/budget/widgets/month_slider.dart';
import 'package:exe201/ui/budget/widgets/recent_transaction.dart';
import 'package:flutter/material.dart';

import '../../service/storage/token_storage.dart';


class BudgetTab extends StatelessWidget {
  const BudgetTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: FutureBuilder<String?>(
          future: TokenStorage().getUserId(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Unable to load user data',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Please log in again',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }

            final userId = snapshot.data!;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const MonthSlider(),
                  BalanceCard(userId: userId,),
                  CategoriesSection(userId: userId,),
                  RecentTransactionsSection(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

}
