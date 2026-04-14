import 'package:flutter/material.dart';

import 'dart:math' as math;

import 'package:yinling_zhiban_demo/routes.dart';
import 'package:yinling_zhiban_demo/theme/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key, this.initialRoute = landingRoute});

  final String initialRoute;

  static final ValueNotifier<bool> isCareMode = ValueNotifier(true);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isCareMode,
      builder: (context, careMode, child) {
        return MaterialApp(
          title: '银聆',
          theme: careMode ? AppTheme.highContrast() : AppTheme.standard(),
          builder: (context, materialChild) {
            final baseScaler = MediaQuery.textScalerOf(context);
            final baseScale = baseScaler.scale(1.0);
            final minScale = careMode ? AppTheme.textScale : 1.0;
            final scaled = MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(math.max(baseScale, minScale)),
            );
            return MediaQuery(data: scaled, child: materialChild ?? const SizedBox());
          },
          routes: appRoutes,
          initialRoute: initialRoute,
        );
      },
    );
  }
}

