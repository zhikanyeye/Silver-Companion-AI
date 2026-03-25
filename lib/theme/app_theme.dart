import 'package:flutter/material.dart';

class AppTheme {
  static const double textScale = 1.2;
  static const Color brandWarmPrimary = Color(0xFFC96A43);
  static const Color brandWarmSecondary = Color(0xFFE7A15B);
  static const Color serviceBluePrimary = Color(0xFF2B67C7);
  static const Color serviceBlueSecondary = Color(0xFF78A9F5);
  static const Color backgroundTop = Color(0xFFFFF4EA);
  static const Color backgroundBottom = Color(0xFFF9DCC8);
  static const Color surface = Color(0xFFFFFCF8);
  static const Color surfaceAlt = Color(0xFFF7FAFD);
  static const Color surfaceTint = Color(0xFFF4C7A1);
  static const Color primary = brandWarmPrimary;
  static const Color secondary = brandWarmSecondary;
  static const Color accent = Color(0xFF8E4A31);
  static const Color textStrong = Color(0xFF5F2F21);
  static const Color textMuted = Color(0xFF7D5A4C);
  static const Color borderSoft = Color(0xFFD9E6F7);
  static const Color warningSoft = Color(0xFFFFF4E8);
  static const Color successSoft = Color(0xFFEAF7EA);
  static const Color dangerSoft = Color(0xFFFFEBEE);

  static const Gradient brandGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [backgroundTop, Color(0xFFFFE7D3), Colors.white],
  );

  static const Gradient serviceGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [surfaceAlt, backgroundTop, Colors.white],
  );

  static ThemeData highContrast() {
    const colorScheme = ColorScheme.light(
      primary: brandWarmPrimary,
      onPrimary: Colors.white,
      secondary: brandWarmSecondary,
      onSecondary: Color(0xFF4A281C),
      surface: surface,
      onSurface: textStrong,
      error: Color(0xFFB3261E),
      onError: Colors.white,
    );
    final base = ThemeData.from(colorScheme: colorScheme, useMaterial3: true);

    return base.copyWith(
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: ZoomPageTransitionsBuilder(),
          TargetPlatform.macOS: ZoomPageTransitionsBuilder(),
        },
      ),
      scaffoldBackgroundColor: backgroundTop,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: textStrong),
        titleTextStyle: base.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          color: textStrong,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: borderSoft),
        ),
      ),
      dividerColor: borderSoft,
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

  static ThemeData standard() {
    const colorScheme = ColorScheme.light(
      primary: brandWarmPrimary,
      onPrimary: Colors.white,
      secondary: brandWarmSecondary,
      onSecondary: Colors.white,
      surface: surface,
      onSurface: Color(0xFF333333),
      error: Color(0xFFB3261E),
      onError: Colors.white,
    );
    final base = ThemeData.from(colorScheme: colorScheme, useMaterial3: true);

    return base.copyWith(
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: ZoomPageTransitionsBuilder(),
          TargetPlatform.macOS: ZoomPageTransitionsBuilder(),
        },
      ),
      scaffoldBackgroundColor: surfaceAlt,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF333333)),
        titleTextStyle: base.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: const Color(0xFF333333),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderSoft),
        ),
      ),
      dividerColor: borderSoft,
    );
  }
}
