import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Widget buildHeader(Color color) {
  final now = DateTime.now();
  final dayOfWeek = DateFormat('EEEE').format(now);
  final formattedDate = formatWithOrdinal(now);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Hi, Afsar',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
      SizedBox(height: 4),
      Text(
        'Here is today\'s overview',
        style: TextStyle(fontSize: 18, color: Colors.black54),
      ),
      SizedBox(height: 2),
      Text(
        '$dayOfWeek, $formattedDate',
        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
      ),
    ],
  );
}

String formatWithOrdinal(DateTime date) {
  final day = date.day;
  final suffix = _getDaySuffix(day);
  final formatted = DateFormat('MMMM d yyyy').format(date); // e.g. June 5

  return formatted.replaceFirst('$day', '$day$suffix');
}

String _getDaySuffix(int day) {
  if (day >= 11 && day <= 13) return 'th';
  switch (day % 10) {
    case 1:
      return 'st';
    case 2:
      return 'nd';
    case 3:
      return 'rd';
    default:
      return 'th';
  }
}
