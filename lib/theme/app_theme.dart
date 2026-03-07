import 'package:flutter/material.dart';

class AppTheme {
  static const double textScale = 1.2;

  static ThemeData highContrast() {
    final base = ThemeData.from(
      colorScheme: const ColorScheme.highContrastLight(),
    );

    return base.copyWith(
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
