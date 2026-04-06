import 'package:flutter/material.dart';

import 'package:yinling_zhiban_demo/features/role/widgets/role_option_card.dart';
import 'package:yinling_zhiban_demo/routes.dart';

class RoleSelectPage extends StatelessWidget {
  const RoleSelectPage({super.key});

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
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  children: [
                    const Text(
                      'Select your role',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'We will take you to the role-specific experience.',
                    ),
                    const SizedBox(height: 24),
                    RoleOptionCard(
                      title: 'I am an elder',
                      subtitle: 'Chat, reminders, and community support',
                      icon: Icons.elderly_rounded,
                      onPressed: () => Navigator.of(context).pushNamed(elderlyRoute),
                    ),
                    const SizedBox(height: 16),
                    RoleOptionCard(
                      title: 'I am a child',
                      subtitle: 'Remote care dashboard and reminders',
                      icon: Icons.family_restroom_rounded,
                      onPressed: () => Navigator.of(context).pushNamed(childRoute),
                    ),
                    const SizedBox(height: 24),
                    TextButton(
                      onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                        landingRoute,
                        (route) => false,
                      ),
                      child: const Text('Log out'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
