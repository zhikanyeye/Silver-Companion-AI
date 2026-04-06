import 'package:flutter/material.dart';

import 'package:yinling_zhiban_demo/features/auth/auth_page.dart';
import 'package:yinling_zhiban_demo/theme/app_theme.dart';

class AuthForm extends StatefulWidget {
  const AuthForm({
    super.key,
    required this.tab,
    required this.onSuccess,
  });

  final AuthTabSelection tab;
  final VoidCallback onSuccess;

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRegister = widget.tab == AuthTabSelection.register;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isRegister) ...[
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: '姓名'),
              validator: (value) {
                if (!isRegister) {
                  return null;
                }
                if (value == null || value.trim().isEmpty) {
                  return '请输入姓名';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
          ],
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(labelText: '手机号'),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '请输入手机号';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: '密码',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '请输入密码';
              }
              return null;
            },
          ),
          const SizedBox(height: 28),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                widget.onSuccess();
              }
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(AppTheme.minButtonHeight),
            ),
            child: const Text('进入角色选择'),
          ),
        ],
      ),
    );
  }
}
