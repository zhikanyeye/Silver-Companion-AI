import 'package:flutter/material.dart';

import 'package:yinling_zhiban_demo/features/community/mock_posts.dart';
import 'package:yinling_zhiban_demo/theme/app_theme.dart';

class CommunityFeedPage extends StatefulWidget {
  const CommunityFeedPage({super.key, this.posts = mockPosts});

  final List<CommunityPost> posts;

  @override
  State<CommunityFeedPage> createState() => _CommunityFeedPageState();
}

class _CommunityFeedPageState extends State<CommunityFeedPage> {
  CommunityFeedBucket _selectedBucket = CommunityFeedBucket.recommended;

  List<CommunityPost> get _visiblePosts => widget.posts
      .where((post) => post.bucket == _selectedBucket)
      .toList(growable: false);

  @override
  Widget build(BuildContext context) {
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
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            children: [
              const _CommunityHeroCard(),
              const SizedBox(height: 16),
              const _PinnedNoticeSection(),
              const SizedBox(height: 16),
              _FeedSwitcher(
                selectedBucket: _selectedBucket,
                onChanged: (bucket) {
                  setState(() {
                    _selectedBucket = bucket;
                  });
                },
              ),
              const SizedBox(height: 16),
              ..._buildPostCards(context),
            ],
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

  List<Widget> _buildPostCards(BuildContext context) {
    if (_visiblePosts.isEmpty) {
      return const [
        _EmptyFeedCard(
          title: '暂时还没有新的社区动态',
          subtitle: '可以切换到其他分栏，或先发布一条互助信息。',
        ),
      ];
    }

    return List<Widget>.generate(_visiblePosts.length, (index) {
      final post = _visiblePosts[index];
      return Padding(
        padding: EdgeInsets.only(bottom: index == _visiblePosts.length - 1 ? 0 : 12),
        child: _CommunityPostCard(
          key: Key('communityPostCard_$index'),
          post: post,
        ),
      );
    });
  }
}

class _CommunityHeroCard extends StatelessWidget {
  const _CommunityHeroCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: const Color(0xFFFFFCF8),
      child: Padding(
        padding: const EdgeInsets.all(20),
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
              child: const Icon(
                Icons.groups_rounded,
                color: AppTheme.primary,
                size: 30,
              ),
            ),
            const SizedBox(height: 14),
            Text('邻里互助广场', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              '看看邻里间正在发生的帮助与回应',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            const Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _HeroBadge(
                  icon: Icons.notifications_active_outlined,
                  title: '重要提醒',
                  subtitle: '社区公告与防诈提示',
                ),
                _HeroBadge(
                  icon: Icons.volunteer_activism_outlined,
                  title: '邻里响应',
                  subtitle: '看见帮助，也更容易参与',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroBadge extends StatelessWidget {
  const _HeroBadge({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF2E5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppTheme.primary),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: theme.textTheme.labelLarge?.copyWith(color: AppTheme.textStrong)),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PinnedNoticeSection extends StatelessWidget {
  const _PinnedNoticeSection();

  static const _items = [
    _NoticeItem(
      title: '社区公告',
      description: '本周五下午有健康义诊，请提前到服务站登记。',
      icon: Icons.campaign_outlined,
      color: Color(0xFFFFEBD9),
    ),
    _NoticeItem(
      title: '防诈提醒',
      description: '遇到陌生来电索要验证码或转账，请先联系家人确认。',
      icon: Icons.shield_outlined,
      color: Color(0xFFFFF3E8),
    ),
    _NoticeItem(
      title: '本周活动',
      description: '周六上午社区合唱活动开放报名，欢迎邻里结伴参加。',
      icon: Icons.event_available_outlined,
      color: Color(0xFFFFF7F0),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: const Color(0xFFFFFBF8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('重要提醒', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            for (final item in _items) ...[
              _PinnedNoticeTile(item: item),
              if (item != _items.last) const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}

class _NoticeItem {
  const _NoticeItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color color;
}

class _PinnedNoticeTile extends StatelessWidget {
  const _PinnedNoticeTile({required this.item});

  final _NoticeItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${item.title}（演示）')),
        );
      },
      child: Ink(
        decoration: BoxDecoration(
          color: item.color,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.88),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(item.icon, color: AppTheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title, style: theme.textTheme.titleSmall?.copyWith(color: AppTheme.textStrong)),
                    const SizedBox(height: 4),
                    Text(item.description, style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeedSwitcher extends StatelessWidget {
  const _FeedSwitcher({
    required this.selectedBucket,
    required this.onChanged,
  });

  final CommunityFeedBucket selectedBucket;
  final ValueChanged<CommunityFeedBucket> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFFFFCF8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: _FeedSwitchButton(
                label: '推荐',
                selected: selectedBucket == CommunityFeedBucket.recommended,
                onTap: () => onChanged(CommunityFeedBucket.recommended),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _FeedSwitchButton(
                label: '最新',
                selected: selectedBucket == CommunityFeedBucket.latest,
                onTap: () => onChanged(CommunityFeedBucket.latest),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedSwitchButton extends StatelessWidget {
  const _FeedSwitchButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFE5D1) : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Center(
          child: Text(
            label,
            style: theme.textTheme.titleMedium?.copyWith(
              color: selected ? AppTheme.accent : AppTheme.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}

class _CommunityPostCard extends StatelessWidget {
  const _CommunityPostCard({super.key, required this.post});

  final CommunityPost post;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: const Color(0xFFFFFCF8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 50,
                  height: 50,
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
                      Text(post.identity, style: theme.textTheme.bodySmall),
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
            const SizedBox(height: 14),
            Text(post.title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(post.summary, style: theme.textTheme.bodyLarge?.copyWith(color: AppTheme.textStrong)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _MetaChip(icon: Icons.place_outlined, label: post.location),
                _MetaChip(icon: Icons.schedule_outlined, label: post.time),
                _MetaChip(icon: Icons.volunteer_activism_outlined, label: post.responseStatus),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('查看详情（演示）')),
                    );
                  },
                  child: const Text('查看详情'),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('我来帮忙（演示）')),
                      );
                    },
                    child: const Text('我来帮忙'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyFeedCard extends StatelessWidget {
  const _EmptyFeedCard({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: const Color(0xFFFFFCF8),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(subtitle, style: theme.textTheme.bodyMedium),
          ],
        ),
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
