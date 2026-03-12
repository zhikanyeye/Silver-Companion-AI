import 'package:flutter/material.dart';

class AppTheme {
  static const double textScale = 1.2;
  static const Color backgroundTop = Color(0xFFFFF4EA);
  static const Color backgroundBottom = Color(0xFFF9DCC8);
  static const Color surface = Color(0xFFFFFCF8);
  static const Color surfaceTint = Color(0xFFF4C7A1);
  static const Color primary = Color(0xFFC96A43);
  static const Color secondary = Color(0xFFE7A15B);
  static const Color accent = Color(0xFF8E4A31);
  static const Color textStrong = Color(0xFF5F2F21);
  static const Color textMuted = Color(0xFF7D5A4C);

  static ThemeData highContrast() {
    const colorScheme = ColorScheme.light(
      primary: primary,
      onPrimary: Colors.white,
      secondary: secondary,
      onSecondary: Color(0xFF4A281C),
      surface: surface,
      onSurface: textStrong,
      error: Color(0xFFB3261E),
      onError: Colors.white,
    );
    final base = ThemeData.from(colorScheme: colorScheme, useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: backgroundTop,
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
      textTheme: base.textTheme.copyWith(
        headlineMedium: base.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w800,
          color: textStrong,
        ),
        titleLarge: base.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          color: textStrong,
        ),
        titleMedium: base.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: textStrong,
        ),
        bodyLarge: base.textTheme.bodyLarge?.copyWith(
          height: 1.5,
          color: textMuted,
        ),
        bodyMedium: base.textTheme.bodyMedium?.copyWith(
          height: 1.45,
          color: textMuted,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accent,
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
