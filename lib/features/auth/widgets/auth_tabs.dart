import 'package:flutter/material.dart';

import 'package:yinling_zhiban_demo/features/auth/auth_page.dart';
import 'package:yinling_zhiban_demo/theme/app_theme.dart';

class AuthTabs extends StatelessWidget {
  const AuthTabs({
    super.key,
    required this.selectedTab,
    required this.onChanged,
  });

  final AuthTabSelection selectedTab;
  final ValueChanged<AuthTabSelection> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF2E6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: _AuthTabButton(
              label: '登录',
              isSelected: selectedTab == AuthTabSelection.login,
              onPressed: () => onChanged(AuthTabSelection.login),
            ),
          ),
          Expanded(
            child: _AuthTabButton(
              label: '注册',
              isSelected: selectedTab == AuthTabSelection.register,
              onPressed: () => onChanged(AuthTabSelection.register),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthTabButton extends StatelessWidget {
  const _AuthTabButton({
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isSelected
            ? const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 16,
                  offset: Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: isSelected ? AppTheme.accent : AppTheme.textMuted,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(label),
      ),
    );
  }
}
