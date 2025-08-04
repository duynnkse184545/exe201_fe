import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Header extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  
  const Header({Key? key, required this.title}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      backgroundColor: const Color(0xFF9B5DE5), // Using CalendarTheme.primaryColor value
    );
  }
  
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

Widget buildHeader(Color color, bool greeting) {
  final now = DateTime.now();
  final dayOfWeek = DateFormat('EEEE').format(now);
  final formattedDate = formatWithOrdinal(now);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if(greeting)
      Text(
        'Hi, Afsar',
        style: TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      )
      else SizedBox(height: 10),
      Text(
        'Here is today\'s overview',
        style: TextStyle(
            fontSize: 21,
            color: color,
          fontWeight: FontWeight.bold
        ),
      ),
      SizedBox(height: 2),
      Text(
        '$dayOfWeek, $formattedDate',
        style: TextStyle(fontSize: 14, color: color.withValues(alpha: 0.5)),
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
