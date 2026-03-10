import 'package:flutter/material.dart';

import 'dart:math' as math;

import 'package:yinling_zhiban_demo/routes.dart';
import 'package:yinling_zhiban_demo/theme/app_theme.dart';

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
    const warmBackground = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFFFF5EB), Color(0xFFFFE2D2)],
    );

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: warmBackground),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
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
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: Color(0xFFFFD3B6),
                      child: Icon(Icons.favorite_rounded, color: Color(0xFFC85C3D)),
                    ),
                    SizedBox(height: 18),
                    Text(
                      '银龄智伴',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF7A2E1F),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'AI虚拟家人 + 社区互助的智慧养老平台',
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: Color(0xFF7A5A4F),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _RoleEntryCard(
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
              _RoleEntryCard(
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
              _RoleEntryCard(
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

class _RoleEntryCard extends StatelessWidget {
  const _RoleEntryCard({
    required this.semanticsLabel,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    required this.onTap,
  });

  final String semanticsLabel;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Semantics(
        label: semanticsLabel,
        button: true,
        child: Card(
          color: backgroundColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(icon, color: iconColor),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF5B2C20),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.4,
                            color: Color(0xFF7A5A4F),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.arrow_forward_rounded, color: Color(0xFFC85C3D)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
