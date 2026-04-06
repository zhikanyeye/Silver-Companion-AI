import 'package:flutter/material.dart';

import 'package:yinling_zhiban_demo/features/auth/widgets/auth_form.dart';
import 'package:yinling_zhiban_demo/features/auth/widgets/auth_tabs.dart';
import 'package:yinling_zhiban_demo/routes.dart';

enum AuthTabSelection { login, register }

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  static AuthTabSelection tabFromRouteArguments(Object? arguments) {
    if (arguments == AuthTabSelection.register) {
      return AuthTabSelection.register;
    }
    return AuthTabSelection.login;
  }

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  AuthTabSelection? _selectedTab;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _selectedTab ??= AuthPage.tabFromRouteArguments(
      ModalRoute.of(context)?.settings.arguments,
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedTab = _selectedTab ?? AuthTabSelection.login;
    final isRegister = selectedTab == AuthTabSelection.register;

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
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          isRegister ? '创建账号' : '欢迎回来',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '欢迎使用银龄智伴',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isRegister ? '填写基础信息即可开始使用。' : '使用手机号和密码继续。',
                        ),
                        const SizedBox(height: 24),
                        AuthTabs(
                          selectedTab: selectedTab,
                          onChanged: (tab) {
                            setState(() {
                              _selectedTab = tab;
                            });
                          },
                        ),
                        const SizedBox(height: 24),
                        AuthForm(
                          tab: selectedTab,
                          onSuccess: () {
                            Navigator.of(context).pushNamed(roleSelectRoute);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
