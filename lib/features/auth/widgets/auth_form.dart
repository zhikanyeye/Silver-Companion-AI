import 'package:flutter/material.dart';

import 'package:yinling/features/auth/auth_page.dart';
import 'package:yinling/theme/app_theme.dart';

class AuthForm extends StatefulWidget {
  const AuthForm({super.key, required this.tab, required this.onSuccess});

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
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(prefixIcon, color: const Color(0xFF94A3B8), size: 20),
      suffixIcon: suffixIcon,
      labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 15),
      hintStyle: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 15),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF0369A1), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFEF4444)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
      ),
    );
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
              decoration: _inputDecoration(
                label: '姓名',
                hint: '请输入您的姓名',
                prefixIcon: Icons.person_rounded,
              ),
              style: const TextStyle(fontSize: 16),
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
            decoration: _inputDecoration(
              label: '手机号',
              hint: '请输入手机号码',
              prefixIcon: Icons.phone_rounded,
            ),
            keyboardType: TextInputType.phone,
            style: const TextStyle(fontSize: 16),
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
            decoration: _inputDecoration(
              label: '密码',
              hint: '请输入密码',
              prefixIcon: Icons.lock_rounded,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  color: const Color(0xFF94A3B8),
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            obscureText: _obscurePassword,
            style: const TextStyle(fontSize: 16),
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
              backgroundColor: const Color(0xFF0369A1),
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(AppTheme.minButtonHeight),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: Text(isRegister ? '创建账号' : '登录'),
          ),
          if (!isRegister) ...[
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF0369A1),
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                child: const Text('忘记密码？'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
