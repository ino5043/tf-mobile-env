import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:educards/core/theme/app_tokens.dart';
import 'package:educards/features/progress/domain/entities/deck_progress.dart';
import 'package:educards/features/study/domain/entities/spaced_repetition_data.dart';
import 'package:educards/features/study/presentation/widgets/mastery_colors.dart';
import 'package:educards/l10n/app_localizations.dart';

/// 習熟度の内訳の円グラフ。
///
/// 値は円の上に白い文字で載せず、凡例の文字で示す（UI/UX 標準 4-14、4-1）。
/// 凡例はそのまま読み上げの要約にもなる（34-46）。
class MasteryPieChart extends StatelessWidget {
  final List<DeckProgress> deckProgressList;

  const MasteryPieChart({super.key, required this.deckProgressList});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = AppColors.of(context);

    final counts = <MasteryLevel, int>{
      MasteryLevel.mastered: 0,
      MasteryLevel.review: 0,
      MasteryLevel.learning: 0,
      MasteryLevel.newCard: 0,
    };
    for (final dp in deckProgressList) {
      counts[MasteryLevel.mastered] = counts[MasteryLevel.mastered]! + dp.masteredCount;
      counts[MasteryLevel.review] = counts[MasteryLevel.review]! + dp.reviewCount;
      counts[MasteryLevel.learning] = counts[MasteryLevel.learning]! + dp.learningCount;
      counts[MasteryLevel.newCard] = counts[MasteryLevel.newCard]! + dp.newCount;
    }

    final total = counts.values.fold<int>(0, (a, b) => a + b);
    if (total == 0) {
      return SizedBox(
        height: 200,
        child: Center(child: Text(l10n.progressMasteryEmpty)),
      );
    }

    String labelOf(MasteryLevel level) => switch (level) {
          MasteryLevel.mastered => l10n.deckDetailStatusMastered,
          MasteryLevel.review => l10n.deckDetailStatusReview,
          MasteryLevel.learning => l10n.deckDetailStatusLearning,
          MasteryLevel.newCard => l10n.deckDetailStatusNew,
        };

    final entries = counts.entries.toList();
    final summary = entries
        .map((e) => l10n.progressMasteryLegendItem(labelOf(e.key), e.value))
        .join('、');

    return Semantics(
      label: summary,
      excludeSemantics: true,
      child: SizedBox(
        height: 200,
        child: Row(
          children: [
            Expanded(
              child: PieChart(
                PieChartData(
                  sectionsSpace: 3,
                  centerSpaceRadius: 32,
                  sections: [
                    for (final e in entries)
                      if (e.value > 0)
                        PieChartSectionData(
                          value: e.value.toDouble(),
                          color: colors.forMastery(e.key),
                          showTitle: false,
                          radius: 48,
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
                for (final (i, e) in entries.indexed) ...[
                  if (i > 0) const SizedBox(height: 8),
                  _Legend(
                    color: colors.forMastery(e.key),
                    label: l10n.progressMasteryLegendItem(labelOf(e.key), e.value),
                  ),
                ],
              ],
            ),
          ],
        ),
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
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
