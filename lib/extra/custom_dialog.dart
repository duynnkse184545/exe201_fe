import 'package:flutter/material.dart';

Color getPressedStateColor(bool isPressed) {
  final baseColor = Color(0xff7583ca);
  if (isPressed) {
    // Use HSLColor to darken slightly
    final hsl = HSLColor.fromColor(baseColor);
    final darker = hsl.withLightness((hsl.lightness - 0.3).clamp(0.0, 1.0));
    return darker.toColor();
  }
  return baseColor;
}

mixin PressedStateMixin<T extends StatefulWidget> on State<T> {
  bool _isPressed = false;
  bool get isPressed => _isPressed;

  Future<void> executeWithPressedState(Future<void> Function() action) async {
    setState(() => _isPressed = true);
    try {
      await action();
    } finally {
      if (mounted) {
        setState(() => _isPressed = false);
      }
    }
  }
}

Future<T?> showCustomBottomSheet<T>({
  required BuildContext context,
  required String title,
  required Widget content,
  required String actionText,
  required Color actionColor,
  Future<void> Function()? onActionPressed,
  bool isDismissible = true,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: isDismissible,
    barrierLabel: title,
    barrierColor: Colors.white.withValues(alpha: 0.3),
    transitionDuration: Duration(milliseconds: 300),
    pageBuilder: (context, animation1, animation2) {
      return Container();
    },
    transitionBuilder: (context, animation1, animation2, child) {
      return SlideTransition(
        position: Tween(
          begin: Offset(0.0, 1.0),
          end: Offset(0.0, 0.0),
        ).animate(CurvedAnimation(
          parent: animation1,
          curve: Curves.easeInOut,
        )),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: SafeArea(
            bottom: false,
            child: Container(
              // Apply shadow to the outer container
              margin: EdgeInsets.zero,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(80)),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    blurRadius: 10,
                    offset: Offset(0, -5),
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent, // Make material transparent
                borderRadius: BorderRadius.vertical(top: Radius.circular(80)),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.8,
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Handle bar for visual feedback
                          Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF111827),
                            ),
                          ),
                          SizedBox(height: 24),
                          content,
                          SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: onActionPressed ?? () => Navigator.of(context).pop(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: actionColor,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(40),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                actionText,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}