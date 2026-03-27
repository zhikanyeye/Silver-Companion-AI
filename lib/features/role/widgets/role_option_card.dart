import 'package:flutter/material.dart';

class RoleOptionCard extends StatefulWidget {
  const RoleOptionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onPressed,
    this.iconColor = const Color(0xFF0369A1),
    this.iconBg = const Color(0xFFEFF6FF),
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onPressed;
  final Color iconColor;
  final Color iconBg;

  @override
  State<RoleOptionCard> createState() => _RoleOptionCardState();
}

class _RoleOptionCardState extends State<RoleOptionCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Semantics(
          label: '${widget.title}，${widget.subtitle}',
          button: true,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _isHovered
                    ? const Color(0xFF0369A1).withOpacity(0.3)
                    : const Color(0xFFE2E8F0),
                width: _isHovered ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: _isHovered
                      ? const Color(0x140369A1)
                      : const Color(0x06000000),
                  blurRadius: _isHovered ? 24 : 16,
                  offset: Offset(0, _isHovered ? 8 : 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: widget.iconBg,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(widget.icon, color: widget.iconColor, size: 28),
                ),
                const SizedBox(width: 18),
                // Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0C4A6E),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.subtitle,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                // Arrow
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _isHovered
                        ? const Color(0xFF0369A1).withOpacity(0.08)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    size: 20,
                    color: _isHovered
                        ? const Color(0xFF0369A1)
                        : const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
