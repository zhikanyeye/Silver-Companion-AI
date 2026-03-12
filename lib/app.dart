import 'package:flutter/material.dart';

import 'dart:math' as math;

import 'package:yinling_zhiban_demo/routes.dart';
import 'package:yinling_zhiban_demo/theme/app_theme.dart';
import 'package:yinling_zhiban_demo/widgets/brand_hero.dart';
import 'package:yinling_zhiban_demo/widgets/role_entry_card.dart';

class App extends StatelessWidget {
  const App({super.key});

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
      initialRoute: homeRoute,
    );
  }
}

class HomeSelectorScreen extends StatelessWidget {
  const HomeSelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.backgroundTop, AppTheme.backgroundBottom],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Semantics(
                  label: '打开设置',
                  button: true,
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushNamed(settingsRoute);
                    },
                    icon: const Icon(Icons.tune),
                    label: const Text('设置'),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const BrandHero(),
              const SizedBox(height: 20),
              RoleEntryCard(
                semanticsLabel: '进入老人端',
                title: '老人端',
                subtitle: '大字清晰入口，AI陪伴与社区互助一步直达',
                icon: Icons.wb_sunny_outlined,
                backgroundColor: const Color(0xFFFFF0E2),
                iconColor: const Color(0xFFD46A4C),
                onTap: () {
                  Navigator.of(context).pushNamed(elderlyRoute);
                },
              ),
              const SizedBox(height: 14),
              RoleEntryCard(
                semanticsLabel: '进入子女端',
                title: '子女端',
                subtitle: '远程了解长者动态，及时响应陪伴与提醒',
                icon: Icons.favorite_border_rounded,
                backgroundColor: const Color(0xFFFFF7F1),
                iconColor: const Color(0xFFC85C3D),
                onTap: () {
                  Navigator.of(context).pushNamed(childRoute);
                },
              ),
              const SizedBox(height: 14),
              RoleEntryCard(
                semanticsLabel: '进入平台端',
                title: '平台端',
                subtitle: '预留给社区协同与平台运营的演示入口',
                icon: Icons.apartment_rounded,
                backgroundColor: const Color(0xFFFFFBF7),
                iconColor: const Color(0xFFB85B42),
                onTap: () {
                  Navigator.of(context).pushNamed(platformRoute);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
