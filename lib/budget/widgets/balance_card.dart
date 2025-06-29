import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../Extra/custom_dialog.dart';
import '../../extra/custom_field.dart';

class BalanceCard extends StatefulWidget {
  const BalanceCard({super.key});

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  bool _isPressed = false;
  final PageController _controller = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> balanceItems = [
      {
        "title": "Available balance",
        "amount": "5.000.000 ₫",
        "action": () => _showBalanceDialog(context),
      },
      {
        "title": "Income",
        "amount": "8.000.000 ₫",
        "action": () async => debugPrint("Tapped: income"),
      },
      {
        "title": "Expenses",
        "amount": "3.000.000 ₫",
        "action": () async => debugPrint("Tapped: expenses"),
      },
    ];
    return Container(
      width: double.maxFinite,
      margin: EdgeInsets.only(left: 20, right: 20, top: 20),
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
        color: _getMaterialColor(),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          splashColor: Colors.black.withValues(alpha: 0.5),
          onTap: () async {
            setState(() {
              _isPressed = true;
            });

            // Wait for the dialog to complete (when user dismisses it)
            balanceItems[_currentPage]['action']();

            // Only reset _isPressed after dialog is actually closed
            if (mounted) {
              setState(() {
                _isPressed = false;
              });
            }
          },
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
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              item['amount']!,
                              style: TextStyle(
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

  Color _getMaterialColor() {
    final baseColor = Color(0xff7583ca);
    if (_isPressed) {
      // Use HSLColor to darken slightly
      final hsl = HSLColor.fromColor(baseColor);
      final darker = hsl.withLightness((hsl.lightness - 0.3).clamp(0.0, 1.0));
      return darker.toColor();
    }
    return baseColor;
  }

  Future<Map<String, dynamic>?> _showBalanceDialog(BuildContext context) async {
    final balanceController = TextEditingController();

    // Make sure to return the result from showCustomBottomSheet
    final result = await showCustomBottomSheet<Map<String, dynamic>>(
      context: context,
      title: 'Add Transaction',
      actionText: 'DONE',
      actionColor: Color(0xff7583ca),
      content: Column(
        children: [
          buildFormField(
            label: 'Name',
            controller: balanceController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
          ),
        ],
      ),
      onActionPressed: () {
        final balanceText = balanceController.text.trim();
        if (balanceText.isEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Please fill in all fields')));
          return;
        }
        final amount = double.tryParse(balanceText);
        if (amount == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please enter a valid amount')),
          );
          return;
        }
        Navigator.of(context).pop({'amount': amount});
      },
    );
    return result;
  }
}
