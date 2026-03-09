import 'package:flutter/material.dart';

import 'package:yinling_zhiban_demo/routes.dart';

class ElderlyHomePage extends StatelessWidget {
  const ElderlyHomePage({super.key});

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('功能即将开放')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('长者服务')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _ActionEntry(
              title: 'AI陪伴',
              icon: Icons.forum_outlined,
              onTap: () => _showComingSoon(context),
            ),
            const SizedBox(height: 12),
            _ActionEntry(
              title: '一键求助',
              icon: Icons.sos_outlined,
              onTap: () => _showComingSoon(context),
            ),
            const SizedBox(height: 12),
            _ActionEntry(
              title: '社区互助',
              icon: Icons.groups_outlined,
              onTap: () => Navigator.of(context).pushNamed(communityRoute),
            ),
            const SizedBox(height: 12),
            _ActionEntry(
              title: '活动',
              icon: Icons.celebration_outlined,
              onTap: () => _showComingSoon(context),
            ),
            const SizedBox(height: 16),
            Semantics(
              label: '童伴聊天入口',
              button: true,
              child: InkWell(
                key: const Key('childAvatarEntry'),
                borderRadius: BorderRadius.circular(16),
                onTap: () => Navigator.of(context).pushNamed(chatRoute),
                child: Ink(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        child: Icon(Icons.child_care_outlined),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '小灵陪你聊聊天',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionEntry extends StatelessWidget {
  const _ActionEntry({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
