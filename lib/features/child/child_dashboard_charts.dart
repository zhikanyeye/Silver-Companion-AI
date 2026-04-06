import 'package:flutter/material.dart';
import 'package:yinling_zhiban_demo/theme/app_theme.dart';

class WeeklyTrendChart extends StatelessWidget {
  const WeeklyTrendChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.borderSoft),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly trend',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 8),
          Text('A simple summary of activity and mood over the last 7 days.'),
          SizedBox(height: 16),
          LinearProgressIndicator(value: 0.82),
          SizedBox(height: 8),
          LinearProgressIndicator(value: 0.76),
        ],
      ),
    );
  }
}

class HealthMetricsTable extends StatelessWidget {
  const HealthMetricsTable({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.borderSoft),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Health metrics',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 8),
          Text('Key health data at a glance.'),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: Text('Blood pressure')),
              Expanded(child: Text('128/82')),
              Expanded(child: Text('Normal')),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: Text('Heart rate')),
              Expanded(child: Text('72 bpm')),
              Expanded(child: Text('Normal')),
            ],
          ),
        ],
      ),
    );
  }
}
