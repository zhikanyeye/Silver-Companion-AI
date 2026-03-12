import 'package:flutter/material.dart';

import 'package:yinling_zhiban_demo/features/community/mock_posts.dart';
import 'package:yinling_zhiban_demo/theme/app_theme.dart';

class CommunityFeedPage extends StatelessWidget {
  const CommunityFeedPage({super.key, this.posts = mockPosts});

  final List<CommunityPost> posts;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('社区互助')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.backgroundTop, Color(0xFFFFE9DA)],
          ),
        ),
        child: SafeArea(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: posts.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _CommunityHeroCard(
                    title: '邻里互助，温暖就在身边',
                    subtitle: '看看附近正在发生的求助与回应，熟悉的社区联系保持不变。',
                  ),
                );
              }

              final post = posts[index - 1];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  key: Key('communityPostCard_${index - 1}'),
                  color: const Color(0xFFFFFCF8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF1E6),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                post.username.substring(0, 1),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(post.username, style: theme.textTheme.titleMedium),
                                  const SizedBox(height: 4),
                                  Text('社区正在接力回应这条信息', style: theme.textTheme.bodySmall),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFE8D5),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                post.tag,
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: AppTheme.accent,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(post.content, style: theme.textTheme.bodyLarge?.copyWith(color: AppTheme.textStrong)),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _MetaChip(icon: Icons.place_outlined, label: post.location),
                            _MetaChip(icon: Icons.schedule_outlined, label: post.time),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('发布互助（演示）')),
          );
        },
        icon: const Icon(Icons.edit_outlined),
        label: const Text('发布互助'),
      ),
    );
  }
}

class _CommunityHeroCard extends StatelessWidget {
  const _CommunityHeroCard({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFCF8), Color(0xFFFFE7D3)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14C96A43),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.groups_rounded, color: AppTheme.primary, size: 30),
          ),
          const SizedBox(height: 14),
          Text(title, style: theme.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(subtitle, style: theme.textTheme.bodyLarge),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E8),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppTheme.primary),
          const SizedBox(width: 6),
          Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.textStrong)),
        ],
      ),
    );
  }
}
