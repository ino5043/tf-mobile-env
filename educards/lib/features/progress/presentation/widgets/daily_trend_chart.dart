import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:educards/features/progress/domain/entities/progress_trend.dart';

class DailyTrendChart extends StatelessWidget {
  final ProgressTrend trend;

  const DailyTrendChart({super.key, required this.trend});

  @override
  Widget build(BuildContext context) {
    if (trend.dailyStats.isEmpty) {
      return const SizedBox(
        height: 250,
        child: Center(child: Text('No study data yet')),
      );
    }

    final theme = Theme.of(context);
    final dateFormat = DateFormat('M/d');

    double maxY = 5;
    for (final stat in trend.dailyStats) {
      if (stat.cardsReviewed > maxY) maxY = stat.cardsReviewed.toDouble();
    }

    // Round up maxY to next 5
    maxY = ((maxY / 5).ceil() * 5).toDouble();
    if (maxY < 5) maxY = 5;

    final barGroups = <BarChartGroupData>[];
    for (int i = 0; i < trend.dailyStats.length; i++) {
      final stat = trend.dailyStats[i];
      final incorrect = stat.incorrectCount.toDouble();
      final correct = stat.correctCount.toDouble();

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: stat.cardsReviewed.toDouble(),
              width: 24,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(4),
              ),
              rodStackItems: [
                BarChartRodStackItem(0, correct, Colors.green),
                BarChartRodStackItem(
                  correct,
                  correct + incorrect,
                  Colors.orange.shade300,
                ),
              ],
              color: Colors.transparent,
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 250,
      child: Padding(
        padding: const EdgeInsets.only(right: 16, top: 16),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: maxY / 5,
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 32,
                  getTitlesWidget: (value, meta) {
                    if (value == meta.max) return const SizedBox.shrink();
                    return Text(
                      value.toInt().toString(),
                      style: theme.textTheme.bodySmall,
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final idx = value.toInt();
                    if (idx < 0 || idx >= trend.dailyStats.length) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        dateFormat.format(trend.dailyStats[idx].date),
                        style: theme.textTheme.bodySmall,
                      ),
                    );
                  },
                ),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            borderData: FlBorderData(show: false),
            maxY: maxY,
            barGroups: barGroups,
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final stat = trend.dailyStats[group.x];
                  return BarTooltipItem(
                    '${dateFormat.format(stat.date)}\n'
                    'Correct: ${stat.correctCount}\n'
                    'Incorrect: ${stat.incorrectCount}',
                    theme.textTheme.bodySmall!.copyWith(
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
