import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:educards/features/progress/domain/entities/deck_progress.dart';

class MasteryPieChart extends StatelessWidget {
  final List<DeckProgress> deckProgressList;

  const MasteryPieChart({super.key, required this.deckProgressList});

  @override
  Widget build(BuildContext context) {
    int mastered = 0, review = 0, learning = 0, newCount = 0;
    for (final dp in deckProgressList) {
      mastered += dp.masteredCount;
      review += dp.reviewCount;
      learning += dp.learningCount;
      newCount += dp.newCount;
    }

    final total = mastered + review + learning + newCount;
    if (total == 0) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('No cards yet')),
      );
    }

    final theme = Theme.of(context);
    return SizedBox(
      height: 200,
      child: Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 30,
                sections: [
                  if (mastered > 0)
                    PieChartSectionData(
                      value: mastered.toDouble(),
                      color: Colors.green,
                      title: '$mastered',
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      radius: 50,
                    ),
                  if (review > 0)
                    PieChartSectionData(
                      value: review.toDouble(),
                      color: Colors.blue,
                      title: '$review',
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      radius: 50,
                    ),
                  if (learning > 0)
                    PieChartSectionData(
                      value: learning.toDouble(),
                      color: Colors.orange,
                      title: '$learning',
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      radius: 50,
                    ),
                  if (newCount > 0)
                    PieChartSectionData(
                      value: newCount.toDouble(),
                      color: theme.colorScheme.outline,
                      title: '$newCount',
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      radius: 50,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Legend(color: Colors.green, label: 'Mastered'),
              const SizedBox(height: 4),
              const _Legend(color: Colors.blue, label: 'Review'),
              const SizedBox(height: 4),
              const _Legend(color: Colors.orange, label: 'Learning'),
              const SizedBox(height: 4),
              _Legend(color: theme.colorScheme.outline, label: 'New'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;

  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
