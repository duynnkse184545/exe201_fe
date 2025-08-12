import 'dart:io';

import 'package:exe201/ui/extra/theme_extensions.dart';
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
            children: [
              Expanded(
                child: userAsync.when(
                  data: (user) => Text(
                    '$title, ${user?.fullName ?? 'User'}',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  loading: () => Text(
                    '$title, Loading...',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  error: (_, _) => Text(
                    '$title, User',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ),
              if (content != null) ...[
                content,
              ],
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

bool _isLocalFilePath(String? path) {
  if (path == null || path.isEmpty) return false;
  // Check for various local file path patterns
  return path.startsWith('file://') || 
         path.startsWith('/data/') || 
         path.startsWith('/storage/') ||
         path.startsWith('/var/') ||  // iOS paths
         path.contains('/Documents/') ||  // App documents directory
         path.contains('/Library/') ||   // iOS library directory
         (path.startsWith('/') && !path.startsWith('http'));
}

// Helper method to determine if a string is a network URL
bool _isNetworkUrl(String? url) {
  if (url == null || url.isEmpty) return false;
  return url.startsWith('http://') || url.startsWith('https://');
}

// Helper widget to display image based on its type
Widget buildImageWidget(BuildContext context, String? imagePath, {double size = 120}) {
  if (imagePath == null || imagePath.isEmpty) {
    return Icon(
      Icons.person,
      size: size * 0.5,
      color: context.primaryColor,
    );
  }

  if (_isNetworkUrl(imagePath)) {
    return ClipOval(
      child: Image.network(
        imagePath,
        fit: BoxFit.cover,
        width: size,
        height: size,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.person,
            size: size * 0.5,
            color: context.primaryColor,
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                  loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
      ),
    );
  } else if (_isLocalFilePath(imagePath)) {
    // Handle local file paths (including persistent app storage)
    final String cleanPath = imagePath.replaceFirst('file://', '');
    final file = File(cleanPath);
    
    return ClipOval(
      child: FutureBuilder<bool>(
        future: file.exists(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.primaryColor.withOpacity(0.1),
              ),
              child: Icon(
                Icons.person,
                size: size * 0.5,
                color: context.primaryColor,
              ),
            );
          }
          
          if (snapshot.data == true) {
            return Image.file(
              file,
              fit: BoxFit.cover,
              width: size,
              height: size,
              errorBuilder: (context, error, stackTrace) {
                print('Error loading image file: $error');
                return Icon(
                  Icons.person,
                  size: size * 0.5,
                  color: context.primaryColor,
                );
              },
            );
          } else {
            // File doesn't exist, show default icon
            print('Image file does not exist: $cleanPath');
            return Icon(
              Icons.person,
              size: size * 0.5,
              color: context.primaryColor,
            );
          }
        },
      ),
    );
  }

  // Fallback for any other case
  return Icon(
    Icons.person,
    size: size * 0.5,
    color: context.primaryColor,
  );
}

