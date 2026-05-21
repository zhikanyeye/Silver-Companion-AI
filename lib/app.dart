import 'package:flutter/material.dart';

import 'dart:math' as math;

import 'package:yinling/routes.dart';
import 'package:yinling/services/accessibility_speech_controller.dart';
import 'package:yinling/theme/app_theme.dart';

class App extends StatelessWidget {
  const App({
    super.key,
    this.initialRoute = landingRoute,
    AccessibilitySpeechController? accessibilitySpeechController,
  }) : _accessibilitySpeechController = accessibilitySpeechController;

  final String initialRoute;
  final AccessibilitySpeechController? _accessibilitySpeechController;

  static final ValueNotifier<bool> isCareMode = ValueNotifier(true);
  static final AccessibilitySpeechController _defaultSpeechController =
      AccessibilitySpeechController();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isCareMode,
      builder: (context, careMode, child) {
        final accessibilitySpeechController =
            _accessibilitySpeechController ?? _defaultSpeechController;
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
            return MediaQuery(
              data: scaled,
              child: _AccessibilitySpeechLayer(
                controller: accessibilitySpeechController,
                child: materialChild ?? const SizedBox(),
              ),
            );
          },
          routes: appRoutes,
          initialRoute: initialRoute,
        );
      },
    );
  }
}

class _AccessibilitySpeechLayer extends StatelessWidget {
  const _AccessibilitySpeechLayer({
    required this.controller,
    required this.child,
  });

  final AccessibilitySpeechController controller;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Stack(
          children: [
            Listener(
              behavior: HitTestBehavior.translucent,
              onPointerUp: (event) {
                if (!controller.enabled) {
                  return;
                }
                final element = _findElementAt(context, event.position);
                if (element != null) {
                  controller.speakFromElement(element);
                }
              },
              child: child,
            ),
            Positioned(
              left: 16,
              bottom: 24,
              child: SafeArea(
                child: FloatingActionButton.small(
                  key: const Key('accessibilitySpeechToggle'),
                  heroTag: 'accessibilitySpeechToggle',
                  onPressed: controller.toggle,
                  tooltip: controller.enabled ? '关闭点击播报' : '开启点击播报',
                  backgroundColor: controller.enabled
                      ? AppTheme.serviceBluePrimary
                      : AppTheme.surface,
                  foregroundColor: controller.enabled
                      ? Colors.white
                      : AppTheme.serviceBluePrimary,
                  child: Icon(
                    controller.enabled
                        ? Icons.record_voice_over_rounded
                        : Icons.volume_up_outlined,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Element? _findElementAt(BuildContext context, Offset globalPosition) {
    Element? result;

    void visitor(Element element) {
      final renderObject = element.renderObject;
      if (renderObject is! RenderBox) {
        element.visitChildElements(visitor);
        return;
      }

      if (!renderObject.hasSize) {
        return;
      }

      final local = renderObject.globalToLocal(globalPosition);
      if (!renderObject.size.contains(local)) {
        return;
      }

      result = element;
      element.visitChildElements(visitor);
    }

    context.visitChildElements(visitor);
    return result;
  }
}
