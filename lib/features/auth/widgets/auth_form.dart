import 'package:flutter/material.dart';

import 'package:yinling_zhiban_demo/features/auth/auth_page.dart';

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
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

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
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isRegister ? '创建账号' : '欢迎回来',
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            isRegister ? '填写基础信息后即可开始使用。' : '使用手机号和密码继续。',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
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
            keyboardType: TextInputType.phone,
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
            decoration: const InputDecoration(labelText: '密码'),
            obscureText: true,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '请输入密码';
              }

              return null;
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  widget.onSuccess();
                }
              },
              child: const Text('进入角色选择'),
            ),
          ),
        ],
      ),
    );
  }
}
