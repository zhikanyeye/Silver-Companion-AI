import 'package:flutter/material.dart';

import 'dart:math' as math;

import 'package:yinling_zhiban_demo/routes.dart';
import 'package:yinling_zhiban_demo/theme/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key, this.initialRoute = landingRoute});

  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.highContrast(),
      builder: (context, child) {
        final baseScaler = MediaQuery.textScalerOf(context);
        final baseScale = baseScaler.scale(1.0);
        final minScale = AppTheme.textScale;
        final scaled = MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(math.max(baseScale, minScale)),
        );
        return MediaQuery(data: scaled, child: child ?? const SizedBox());
      },
      routes: appRoutes,
      initialRoute: initialRoute,
    );
  }
}

