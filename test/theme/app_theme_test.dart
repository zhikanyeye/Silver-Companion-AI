import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:yinling/theme/app_theme.dart';

void main() {
  test('app theme exposes unified warm and service design tokens', () {
    expect(AppTheme.brandWarmPrimary, const Color(0xFFC96A43));
    expect(AppTheme.serviceBluePrimary, const Color(0xFF2B67C7));
    expect(AppTheme.borderSoft, const Color(0xFFD9E6F7));
    expect(AppTheme.surfaceAlt, const Color(0xFFF7FAFD));
    expect(AppTheme.warningSoft, const Color(0xFFFFF4E8));
    expect(AppTheme.successSoft, const Color(0xFFEAF7EA));
  });

  test('high contrast theme uses unified card and button styling baselines', () {
    final theme = AppTheme.highContrast();

    expect(theme.cardTheme.shape, isA<RoundedRectangleBorder>());
    expect(theme.cardTheme.color, AppTheme.surface);
    expect(theme.colorScheme.primary, AppTheme.brandWarmPrimary);
    expect(theme.textButtonTheme.style?.foregroundColor?.resolve({}), AppTheme.accent);
  });
}
