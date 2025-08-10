import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../provider/providers.dart';

String formatCurrency(double value) {
  if (value >= 1_000_000_000) {
    double inB = value / 1_000_000_000;
    return '${inB.toStringAsFixed(inB.truncateToDouble() == inB ? 0 : 1)}B ₫';
  } else if (value >= 1_000_000) {
    double inM = value / 1_000_000;
    return '${inM.toStringAsFixed(inM.truncateToDouble() == inM ? 0 : 1)}M ₫';
  } else if (value >= 1_000) {
    double inK = value / 1_000;
    return '${inK.toStringAsFixed(inK.truncateToDouble() == inK ? 0 : 1)}K ₫';
  } else {
    return '${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')} ₫';
  }
}

class Header extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const Header({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      backgroundColor: const Color(
        0xFF9B5DE5,
      ), // Using CalendarTheme.primaryColor value
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

Widget buildHeader({
  required Color color,
  String title = "Hi",
  required String subtitle,
  Widget? content,
}) {
  final now = DateTime.now();
  final dayOfWeek = DateFormat('EEEE').format(now);
  final formattedDate = formatWithOrdinal(now);

  return Consumer(
    builder: (context, ref, child) {
      final userAsync = ref.watch(userNotifierProvider);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              userAsync.when(
                data: (user) => Expanded(
                  child: Text(
                    '$title, ${user?.fullName ?? 'User'}',
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
                  loading: () => Text(
                  '$title, Loading...',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                error: (_, _) => Text(
                  '$title, User',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
              ?content,
            ],
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 21,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 2),
          Text(
            '$dayOfWeek, $formattedDate',
            style: TextStyle(fontSize: 14, color: color.withValues(alpha: 0.5)),
          ),
        ],
      );
    },
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
