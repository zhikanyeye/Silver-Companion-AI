import 'package:flutter/material.dart';

import 'package:yinling_zhiban_demo/features/auth/auth_page.dart';
import 'package:yinling_zhiban_demo/routes.dart';
import 'package:yinling_zhiban_demo/theme/app_theme.dart';
import 'package:yinling_zhiban_demo/widgets/brand_hero.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  static const _motionDuration = Duration(milliseconds: 220);

  var _isVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _isVisible = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.backgroundTop, Color(0xFFFFE7D3), Colors.white],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final isCompact = width < 640;
              final isTablet = width >= 640 && width < 1100;
              final horizontalPadding = isCompact ? 16.0 : (isTablet ? 24.0 : 32.0);
              final topPadding = isCompact ? 12.0 : (isTablet ? 20.0 : 24.0);
              final heroMaxWidth = isCompact ? 720.0 : (isTablet ? 840.0 : 960.0);

              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  topPadding,
                  horizontalPadding,
                  28,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - (topPadding + 28),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedSlide(
                        duration: _motionDuration,
                        curve: Curves.easeOutCubic,
                        offset: _isVisible ? Offset.zero : const Offset(0, -0.08),
                        child: AnimatedOpacity(
                          duration: _motionDuration,
                          curve: Curves.easeOut,
                          opacity: _isVisible ? 1 : 0,
                          child: SizedBox(
                            width: double.infinity,
                            child: _LandingActions(isCompact: isCompact),
                          ),
                        ),
                      ),
                      SizedBox(height: isCompact ? 18 : 24),
                      Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: heroMaxWidth),
                          child: AnimatedSlide(
                            duration: _motionDuration,
                            curve: Curves.easeOutCubic,
                            offset: _isVisible
                                ? Offset.zero
                                : Offset(isCompact ? 0 : 0.04, isCompact ? 0.06 : 0),
                            child: AnimatedOpacity(
                              duration: _motionDuration,
                              curve: Curves.easeOut,
                              opacity: _isVisible ? 1 : 0,
                              child: const BrandHero(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _LandingActions extends StatelessWidget {
  const _LandingActions({required this.isCompact});

  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final registerStyle = ElevatedButton.styleFrom(
      backgroundColor: AppTheme.surface,
      foregroundColor: AppTheme.accent,
    );

    Widget loginButton = ElevatedButton(
      onPressed: () => Navigator.of(
        context,
      ).pushNamed(authRoute, arguments: AuthTabSelection.login),
      child: const Text('登录'),
    );

    Widget registerButton = ElevatedButton(
      onPressed: () => Navigator.of(
        context,
      ).pushNamed(authRoute, arguments: AuthTabSelection.register),
      style: registerStyle,
      child: const Text('注册'),
    );

    if (isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          loginButton,
          const SizedBox(height: 10),
          registerButton,
        ],
      );
    }

    return Align(
      alignment: Alignment.topRight,
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [loginButton, registerButton],
      ),
    );
  }
}
