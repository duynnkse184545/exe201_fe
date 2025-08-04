import 'package:flutter/material.dart';

class CategoryStyle {
  final Color color;
  final String icon;
  
  const CategoryStyle({required this.color, required this.icon});
}

class CategoryColors {
  static const List<String> customOrder = [
    "Fixed Expenses",
    "Living Expenses", 
    "Entertainment & Personal",
    "Education & Self-improvement",
    "Other Expenses",
    "Saving"
  ];

  /// The merged palette with both colors and icons (mapped to custom order)
  static const List<CategoryStyle> palette = [
    CategoryStyle(color: Color(0xff7583ca), icon: '🏠'),     // Fixed Expenses
    CategoryStyle(color: Color(0xff6CB28E), icon: '🍔'),    // Living Expenses
    CategoryStyle(color: Color(0xffFFBF00), icon: '🎉'),   // Entertainment & Personal
    CategoryStyle(color: Color(0xff76798F), icon: '🎓'),   // Education & Self-improvement
    CategoryStyle(color: Color(0xffEA580C), icon: '🎁'),      // Other Expenses
    CategoryStyle(color: Color(0xffA3AEE7), icon: '💡'),     // Saving
    CategoryStyle(color: Colors.indigo, icon: '🚗'),   // Fallback 1
    CategoryStyle(color: Colors.pink, icon: '💊'),     // Fallback 2
  ];

  /// Get category style by category name (uses custom order)
  static CategoryStyle getStyleByCategoryName(String categoryName) {
    final index = customOrder.indexOf(categoryName);
    if (index >= 0 && index < palette.length) {
      return palette[index];
    }
    // Fallback to hash-based index for unknown categories
    final fallbackIndex = categoryName.hashCode.abs() % palette.length;
    return palette[fallbackIndex];
  }

  /// Get category style by index (cycles through palette)
  static CategoryStyle getStyleByIndex(int index) {
    return palette[index % palette.length];
  }

  /// Get color by category name (uses custom order)
  static Color getColorByCategoryName(String categoryName) {
    return getStyleByCategoryName(categoryName).color;
  }

  /// Get icon by category name (uses custom order)
  static String getIconByCategoryName(String categoryName) {
    return getStyleByCategoryName(categoryName).icon;
  }

  /// Get color by index (cycles through palette)
  static Color getColorByIndex(int index) {
    return palette[index % palette.length].color;
  }

  /// Get icon by index (cycles through palette)
  static String getIconByIndex(int index) {
    return palette[index % palette.length].icon;
  }
}