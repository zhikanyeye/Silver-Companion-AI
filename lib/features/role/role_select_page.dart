import 'package:flutter/material.dart';

import 'package:yinling_zhiban_demo/features/role/widgets/role_option_card.dart';
import 'package:yinling_zhiban_demo/routes.dart';
import 'package:yinling_zhiban_demo/theme/app_theme.dart';

class RoleSelectPage extends StatefulWidget {
  const RoleSelectPage({super.key});

  @override
  State<RoleSelectPage> createState() => _RoleSelectPageState();
}

class _RoleSelectPageState extends State<RoleSelectPage> {
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
      body: Stack(
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppTheme.backgroundTop, Colors.white],
              ),
            ),
          ),
          Positioned(
            left: -30,
            top: 72,
            child: IgnorePointer(
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primary.withValues(alpha: 0.08),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                key: const Key('roleBrandShell'),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 620),
                  child: AnimatedSlide(
                    duration: _motionDuration,
                    curve: Curves.easeOutCubic,
                    offset: _isVisible ? Offset.zero : const Offset(0, 0.08),
                    child: AnimatedOpacity(
                      duration: _motionDuration,
                      curve: Curves.easeOut,
                      opacity: _isVisible ? 1 : 0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF3E7),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: const Color(0xFFF1D3BE)),
                            ),
                            child: Text(
                              '身份确认',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: AppTheme.accent,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '请选择您的身份',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '我们会带您进入对应的专属入口。',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 24),
                          RoleOptionCard(
                            title: '我是老人',
                            subtitle: '进入长辈使用入口，查看陪伴、提醒与常用功能。',
                            icon: Icons.elderly_rounded,
                            onPressed: () =>
                                Navigator.of(context).pushNamed(elderlyRoute),
                          ),
                          const SizedBox(height: 16),
                          RoleOptionCard(
                            title: '我是子女',
                            subtitle: '进入家人关怀入口，查看联动信息与陪伴功能。',
                            icon: Icons.family_restroom_rounded,
                            onPressed: () => Navigator.of(context).pushNamed(childRoute),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
