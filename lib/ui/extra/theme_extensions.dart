import 'package:flutter/material.dart';

/// Extension to provide easy access to the app's primary theme color
extension AppTheme on BuildContext {
  /// Get the primary color from theme
  Color get primaryColor => Theme.of(this).primaryColor;
  
  /// Get the primary color scheme
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  
  /// Get a lighter version of the primary color
  Color get primaryColorLight => Theme.of(this).primaryColor.withValues(alpha: 0.8);
  
  /// Get a darker version of the primary color
  Color get primaryColorDark {
    final hsl = HSLColor.fromColor(Theme.of(this).primaryColor);
    return hsl.withLightness((hsl.lightness - 0.2).clamp(0.0, 1.0)).toColor();
  }
}