import 'package:flutter/material.dart';

class BrandHero extends StatelessWidget {
  const BrandHero({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFCF8), Color(0xFFFFE7D3), Color(0xFFFFD8BC)],
        ),
        border: Border.all(color: const Color(0xFFF1D3BE)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Silver Companion',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 16),
          Text(
            'Compassionate AI support for older adults and their families.',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, height: 1.2),
          ),
          SizedBox(height: 12),
          Text(
            'Chat, reminders, family care dashboards, and community support in one clear flow.',
            style: TextStyle(fontSize: 16, height: 1.5),
          ),
        ],
      ),
    );
  }
}
