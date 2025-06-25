import 'package:flutter/material.dart';

import '../../Extra/custom_dialog.dart';
import '../../extra/custom_field.dart';

class BalanceCard extends StatefulWidget {
  const BalanceCard({super.key});

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      margin: EdgeInsets.only(left: 20, right: 20, top: 20),
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
            await _showBalanceDialog(context);

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
                  Text(
                    'Available balance',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '5.000.000 ₫',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
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
              keyboardType: TextInputType.numberWithOptions(decimal: true)
          ),
        ],
      ),
      onActionPressed: () {
        final balanceText = balanceController.text.trim();
        if (balanceText.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Please fill in all fields'))
          );
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