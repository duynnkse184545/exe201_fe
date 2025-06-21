import 'package:exe201/budget/budget_categories.dart';
import 'package:exe201/budget/recent_transaction.dart';
import 'package:exe201/extra/header.dart';
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
              Container(
                margin: EdgeInsets.zero,
                decoration: BoxDecoration(
                  color: Color(0xff7583ca),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildHeader(Colors.white),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: ['January', 'February', 'March'].map((month) {
                          bool isSelected = month == 'February'; // You can pass in the selected month as a variable
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isSelected ? Colors.white : Color(0xff7583ca),
                                  foregroundColor: isSelected ? Color(0xff7583ca) : Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () {},
                                child: Text(month),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              Container(
                width: double.maxFinite,
                margin: EdgeInsets.only(left: 20, right: 20, top: 20),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Available balance',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '5.000.000 ₫',
                      style: TextStyle(
                        color: Colors.deepPurple,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              CategoriesSection(),
              RecentTransactionsSection()
            ],
          ),
        ),
      ),
    );
  }

}
