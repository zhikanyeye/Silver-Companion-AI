import 'package:flutter/material.dart';

import 'package:yinling_zhiban_demo/features/auth/auth_page.dart';

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
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
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
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextButton(
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}
