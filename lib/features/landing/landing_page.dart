import 'package:flutter/material.dart';

import 'package:yinling_zhiban_demo/features/auth/auth_page.dart';
import 'package:yinling_zhiban_demo/routes.dart';

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
                'AI情感养老社区化实践',
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
          '中国首个AI情感养老社区化实践者',
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
            '听得见孤独，触得到温度。银聆把 AI 情感陪伴、健康提醒与社区互助整合到同一条简单清晰的服务路径中。',
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
                '观看演示',
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
            _QuickStat(icon: Icons.people_rounded, text: '10,000+ 用户信赖'),
            _QuickStat(icon: Icons.schedule_rounded, text: '全天候 AI 响应'),
            _QuickStat(icon: Icons.security_rounded, text: '数据安全加密'),
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
        title: 'AI 暖心陪伴',
        description: '像家人一样聊天，倾听情绪、陪伴日常，24 小时不间断。',
      ),
      const _FeatureCardData(
        icon: Icons.monitor_heart_rounded,
        iconBg: Color(0xFFF0FDF4),
        iconColor: Color(0xFF16A34A),
        title: '健康守护管家',
        description: '用药提醒、作息监测、血压/血糖趋势，子女远程实时了解。',
      ),
      const _FeatureCardData(
        icon: Icons.groups_rounded,
        iconBg: Color(0xFFFEF3C7),
        iconColor: Color(0xFFD97706),
        title: '社区互助网络',
        description: '邻里互帮，紧急代购、陪诊就医、情感支持，一键发起。',
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
          '用户心声',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0C4A6E),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          '来自真实家庭的温暖反馈',
          style: TextStyle(fontSize: 16, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 14,
          runSpacing: 14,
          alignment: WrapAlignment.center,
          children: const [
            _TestimonialCard(
              quote: '妈妈现在每天都会跟 AI 聊天，说比打电话还方便。我们做子女的也能随时看到她的状态，放心多了。',
              name: '张女士',
              role: '北京 · 女儿',
              avatarColor: Color(0xFF2563EB),
            ),
            _TestimonialCard(
              quote: '老伴走后最怕孤单，现在有了银聆，每天都有人陪我说说话，感觉日子也没那么难了。',
              name: '李大爷',
              role: '上海 · 78 岁用户',
              avatarColor: Color(0xFF16A34A),
            ),
            _TestimonialCard(
              quote: '社区互助功能太好了！上次感冒，邻居帮我代购了药，不到一小时就送到了。',
              name: '王阿姨',
              role: '广州 · 72 岁用户',
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
            '让关爱，跨越距离',
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
            '无论您身在何方，银聆帮您守护长辈的每一天。',
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
            child: const Text('免费注册体验'),
          ),
        ],
      ),
    );
  }
}
