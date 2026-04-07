import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:yinling_zhiban_demo/theme/app_theme.dart';

class WeeklyTrendData {
  const WeeklyTrendData({
    required this.dayLabel,
    required this.activityScore,
    required this.moodScore,
    required this.sleepHours,
  });

  final String dayLabel;
  final double activityScore;
  final double moodScore;
  final double sleepHours;
}

const List<WeeklyTrendData> mockWeeklyTrend = [
  WeeklyTrendData(
    dayLabel: '周一',
    activityScore: 72,
    moodScore: 65,
    sleepHours: 6.5,
  ),
  WeeklyTrendData(
    dayLabel: '周二',
    activityScore: 68,
    moodScore: 70,
    sleepHours: 7.0,
  ),
  WeeklyTrendData(
    dayLabel: '周三',
    activityScore: 75,
    moodScore: 72,
    sleepHours: 6.0,
  ),
  WeeklyTrendData(
    dayLabel: '周四',
    activityScore: 80,
    moodScore: 78,
    sleepHours: 7.5,
  ),
  WeeklyTrendData(
    dayLabel: '周五',
    activityScore: 85,
    moodScore: 82,
    sleepHours: 7.0,
  ),
  WeeklyTrendData(
    dayLabel: '周六',
    activityScore: 78,
    moodScore: 80,
    sleepHours: 8.0,
  ),
  WeeklyTrendData(
    dayLabel: '今天',
    activityScore: 82,
    moodScore: 85,
    sleepHours: 7.5,
  ),
];

class HealthMetricRow {
  const HealthMetricRow({
    required this.metric,
    required this.value,
    required this.status,
    required this.trend,
  });

  final String metric;
  final String value;
  final String status;
  final String trend;
}

const List<HealthMetricRow> mockHealthMetrics = [
  HealthMetricRow(metric: '血压', value: '128/82', status: '正常', trend: '→'),
  HealthMetricRow(metric: '心率', value: '72 次/分', status: '正常', trend: '↓'),
  HealthMetricRow(metric: '血糖', value: '5.8 mmol/L', status: '正常', trend: '→'),
  HealthMetricRow(metric: '体重', value: '65 kg', status: '正常', trend: '↑'),
  HealthMetricRow(metric: '步数', value: '4,280 步', status: '偏低', trend: '↓'),
  HealthMetricRow(metric: '饮水量', value: '1,200 ml', status: '偏低', trend: '→'),
];

class WeeklyTrendChart extends StatelessWidget {
  const WeeklyTrendChart({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.borderSoft),
        boxShadow: const [
          BoxShadow(
            color: Color(0x082563EB),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.show_chart_rounded,
                color: AppTheme.serviceBluePrimary,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                '近 7 天趋势',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text('活跃度与情绪综合走势', style: theme.textTheme.bodyMedium),
          const SizedBox(height: 20),
          const Row(
            children: [
              _LegendDot(color: AppTheme.serviceBluePrimary, label: '活跃度'),
              SizedBox(width: 16),
              _LegendDot(color: Color(0xFF22C55E), label: '情绪指数'),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                minY: 40,
                maxY: 100,
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: 20,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) =>
                      FlLine(color: const Color(0xFFE8EEF5), strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 20,
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF999999),
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= mockWeeklyTrend.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            mockWeeklyTrend[index].dayLabel,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: index == mockWeeklyTrend.length - 1
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              color: index == mockWeeklyTrend.length - 1
                                  ? AppTheme.serviceBluePrimary
                                  : const Color(0xFF999999),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                      mockWeeklyTrend.length,
                      (i) => FlSpot(
                        i.toDouble(),
                        mockWeeklyTrend[i].activityScore,
                      ),
                    ),
                    isCurved: true,
                    curveSmoothness: 0.3,
                    color: AppTheme.serviceBluePrimary,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, bar, index) =>
                          FlDotCirclePainter(
                            radius: index == mockWeeklyTrend.length - 1 ? 5 : 3,
                            color: AppTheme.serviceBluePrimary,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.serviceBluePrimary.withValues(
                        alpha: 0.08,
                      ),
                    ),
                  ),
                  LineChartBarData(
                    spots: List.generate(
                      mockWeeklyTrend.length,
                      (i) => FlSpot(i.toDouble(), mockWeeklyTrend[i].moodScore),
                    ),
                    isCurved: true,
                    curveSmoothness: 0.3,
                    color: const Color(0xFF22C55E),
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, bar, index) =>
                          FlDotCirclePainter(
                            radius: index == mockWeeklyTrend.length - 1 ? 5 : 3,
                            color: const Color(0xFF22C55E),
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF22C55E).withValues(alpha: 0.06),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final label = spot.barIndex == 0 ? '活跃' : '情绪';
                        return LineTooltipItem(
                          '$label: ${spot.y.toInt()}',
                          TextStyle(
                            color: spot.bar.color ?? Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Color(0xFF666666)),
        ),
      ],
    );
  }
}

class HealthMetricsTable extends StatelessWidget {
  const HealthMetricsTable({super.key});

  Color _statusColor(String status) {
    switch (status) {
      case '偏高':
        return const Color(0xFFEA580C);
      case '偏低':
        return const Color(0xFFCA8A04);
      default:
        return const Color(0xFF16A34A);
    }
  }

  Color _statusBgColor(String status) {
    switch (status) {
      case '偏高':
        return const Color(0xFFFFF7ED);
      case '偏低':
        return const Color(0xFFFEFCE8);
      default:
        return const Color(0xFFF0FDF4);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.borderSoft),
        boxShadow: const [
          BoxShadow(
            color: Color(0x082563EB),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.table_chart_rounded,
                color: AppTheme.serviceBluePrimary,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                '健康指标总览',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text('今日关键健康数据一览', style: theme.textTheme.bodyMedium),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    '指标',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Color(0xFF475569),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    '数值',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Color(0xFF475569),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '状态',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Color(0xFF475569),
                    ),
                  ),
                ),
                SizedBox(
                  width: 32,
                  child: Text(
                    '趋势',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Color(0xFF475569),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          ...mockHealthMetrics.map(
            (row) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      row.metric,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      row.value,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _statusBgColor(row.status),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        row.status,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _statusColor(row.status),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 32,
                    child: Text(
                      row.trend,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: row.trend == '↑'
                            ? const Color(0xFFEA580C)
                            : row.trend == '↓'
                            ? const Color(0xFF2563EB)
                            : const Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
