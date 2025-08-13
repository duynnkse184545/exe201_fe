import 'package:flutter/material.dart';

class CalendarTheme {
  static const Color primaryColor = Color(0xFF9B5DE5);
  static const Color secondaryColor = Color(0xFFCBD6F2);
  static const Color event = Color(0xff6CB28E);
  static const Color deadline = Color(0xFFFF7043);
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
