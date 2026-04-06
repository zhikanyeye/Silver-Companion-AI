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
            '每周趋势',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 8),
          Text('近 7 天活动与情绪的简要趋势。'),
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
            '健康指标',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 8),
          Text('关键健康数据一目了然。'),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: Text('血压')),
              Expanded(child: Text('128/82')),
              Expanded(child: Text('正常')),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: Text('心率')),
              Expanded(child: Text('72 次/分')),
              Expanded(child: Text('正常')),
            ],
          ),
        ],
      ),
    );
  }
}
