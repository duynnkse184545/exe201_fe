import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'balance_card_test.dart';
import 'budget_categories_test.dart';
import '../budget/widgets/month_slider.dart';
import 'recent_transactions_test.dart';
import '../../service/storage/token_storage.dart';

class BudgetTabTest extends ConsumerWidget {
  const BudgetTabTest({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  BalanceCardTest(userId: userId),
                  CategoriesSectionTest(userId: userId),
                  RecentTransactionsSectionTest(userId: userId),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}