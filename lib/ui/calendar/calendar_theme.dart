import 'package:flutter/material.dart';

class CalendarTheme {
  static const Color primaryColor = Color(0xFF9B5DE5);
  static const Color secondaryColor = Color(0xFF5E81F4);
  static const Color accentColor = Color(0xFFFFC107);
  static const Color backgroundColor = Color(0xFFFFFFFF);
  static const Color textColor = Color(0xFF333333);

  static const double indicatorSize = 6.0;

  static const TextStyle titleStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textColor,
  );

  static const TextStyle subtitleStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Colors.grey,
  );
}
