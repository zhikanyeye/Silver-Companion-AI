import 'package:flutter/material.dart';

import 'package:yinling/features/auth/auth_page.dart';
import 'package:yinling/routes.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeIn = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _animCtrl.forward();
      }
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF0F9FF), Color(0xFFFFF4EA), Colors.white],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final isCompact = width < 640;
              final horizontalPadding = isCompact ? 20.0 : 32.0;

              return FadeTransition(
                opacity: _fadeIn,
                child: SlideTransition(
                  position: _slideUp,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: 20,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 960),
                        child: Column(
                          children: [
                            _TopBar(isCompact: isCompact),
                            SizedBox(height: isCompact ? 32 : 48),
                            _HeroSection(isCompact: isCompact),
                            const SizedBox(height: 40),
                            _FeatureCards(isCompact: isCompact),
                            const SizedBox(height: 40),
                            const _SocialProofSection(),
                            const SizedBox(height: 40),
                            _CTASection(isCompact: isCompact),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
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

class _TopBar extends StatelessWidget {
  const _TopBar({required this.isCompact});

  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'web/assets/branding/yinling-website-logo.png',
              width: 40,
              height: 40,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '银聆',
            style: TextStyle(
              fontSize: isCompact ? 18 : 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0C4A6E),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.isCompact});

  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF0369A1).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: const Color(0xFF0369A1).withValues(alpha: 0.15),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.verified_rounded, size: 18, color: Color(0xFF0369A1)),
              SizedBox(width: 6),
              Text(
                '家庭照护与生活服务平台',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0369A1),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          '银聆——“AI+社区”养老双引擎实践者',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isCompact ? 28 : 40,
            fontWeight: FontWeight.w800,
            height: 1.2,
            color: const Color(0xFF0C4A6E),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Text(
            '以 AI 陪伴回应日常需求，以社区服务承接线下照护，让长辈、家人和服务人员在同一入口协同。',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isCompact ? 16 : 18,
              height: 1.6,
              color: const Color(0xFF64748B),
            ),
          ),
        ),
        const SizedBox(height: 32),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: [
            ElevatedButton.icon(
              onPressed: () => Navigator.of(
                context,
              ).pushNamed(authRoute, arguments: AuthTabSelection.register),
              icon: const Icon(Icons.arrow_forward_rounded, size: 20),
              label: const Text(
                '立即开始',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0369A1),
                foregroundColor: Colors.white,
                minimumSize: const Size(200, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(
                context,
              ).pushNamed(authRoute, arguments: AuthTabSelection.login),
              icon: const Icon(Icons.play_circle_outline_rounded, size: 20),
              label: const Text(
                '登录使用',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF0369A1),
                minimumSize: const Size(180, 56),
                side: const BorderSide(color: Color(0xFF0369A1), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Wrap(
          alignment: WrapAlignment.center,
          spacing: 24,
          runSpacing: 8,
          children: [
            _QuickStat(icon: Icons.people_rounded, text: '长辈和家人共同使用'),
            _QuickStat(icon: Icons.schedule_rounded, text: '全天候陪伴与提醒'),
            _QuickStat(icon: Icons.security_rounded, text: '重要信息及时同步'),
          ],
        ),
      ],
    );
  }
}

class _QuickStat extends StatelessWidget {
  const _QuickStat({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF22C55E)),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _FeatureCards extends StatelessWidget {
  const _FeatureCards({required this.isCompact});

  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final cards = [
      const _FeatureCardData(
        icon: Icons.smart_toy_rounded,
        iconBg: Color(0xFFEFF6FF),
        iconColor: Color(0xFF2563EB),
        title: 'AI 日常陪伴',
        description: '语音聊天、用药提醒和情绪记录，帮助长辈把需求说出来。',
      ),
      const _FeatureCardData(
        icon: Icons.monitor_heart_rounded,
        iconBg: Color(0xFFF0FDF4),
        iconColor: Color(0xFF16A34A),
        title: '家庭远程关怀',
        description: '日常提醒、状态记录和趋势汇总，子女远程了解更安心。',
      ),
      const _FeatureCardData(
        icon: Icons.groups_rounded,
        iconBg: Color(0xFFFEF3C7),
        iconColor: Color(0xFFD97706),
        title: '社区互助网络',
        description: '连接邻里互助、社区活动和便民服务，让线下支持更容易找到。',
      ),
    ];

    if (isCompact) {
      return Column(
        children: cards
            .map(
              (card) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _FeatureCard(data: card),
              ),
            )
            .toList(),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: cards
          .map(
            (card) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 7),
                child: _FeatureCard(data: card),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _FeatureCardData {
  const _FeatureCardData({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String description;
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.data});

  final _FeatureCardData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: data.iconBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(data.icon, color: data.iconColor, size: 28),
          ),
          const SizedBox(height: 16),
          Text(
            data.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0C4A6E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            data.description,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialProofSection extends StatelessWidget {
  const _SocialProofSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          '常用场景',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0C4A6E),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          '围绕长辈每天真正会遇到的事',
          style: TextStyle(fontSize: 16, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 14,
          runSpacing: 14,
          alignment: WrapAlignment.center,
          children: const [
            _TestimonialCard(
              quote: '长辈想找人说话、记录心情或设置提醒时，可以先从 AI 陪伴入口开始。',
              name: '陪伴',
              role: '聊天 · 提醒 · 记录',
              avatarColor: Color(0xFF2563EB),
            ),
            _TestimonialCard(
              quote: '家人需要了解近况时，可以查看提醒、互动和服务记录，减少反复追问。',
              name: '关怀',
              role: '状态 · 记录 · 同步',
              avatarColor: Color(0xFF16A34A),
            ),
            _TestimonialCard(
              quote: '遇到助餐、陪诊、活动和邻里互助需求时，可以从社区入口找到可对接资源。',
              name: '社区',
              role: '互助 · 活动 · 服务',
              avatarColor: Color(0xFFD97706),
            ),
          ],
        ),
      ],
    );
  }
}

class _TestimonialCard extends StatelessWidget {
  const _TestimonialCard({
    required this.quote,
    required this.name,
    required this.role,
    required this.avatarColor,
  });

  final String quote;
  final String name;
  final String role;
  final Color avatarColor;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 300),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x06000000),
              blurRadius: 20,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.format_quote_rounded,
              color: Color(0xFFCBD5E1),
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              quote,
              style: const TextStyle(
                fontSize: 15,
                height: 1.6,
                color: Color(0xFF475569),
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: avatarColor,
                  child: Text(
                    name.substring(0, 1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Color(0xFF0C4A6E),
                      ),
                    ),
                    Text(
                      role,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CTASection extends StatelessWidget {
  const _CTASection({required this.isCompact});

  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isCompact ? 28 : 40),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0369A1), Color(0xFF0284C7)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x300369A1),
            blurRadius: 32,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '从一次陪伴开始',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isCompact ? 24 : 30,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '进入银聆，连接 AI 陪伴、家庭关怀和社区服务。',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(
              context,
            ).pushNamed(authRoute, arguments: AuthTabSelection.register),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF0369A1),
              minimumSize: const Size(220, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: const Text('创建账号'),
          ),
        ],
      ),
    );
  }
}
