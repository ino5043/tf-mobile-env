import 'package:flutter/material.dart';

import 'package:educards/core/theme/app_tokens.dart';

import 'package:educards/features/progress/domain/entities/deck_progress.dart';
import 'package:educards/l10n/app_localizations.dart';

class DeckProgressList extends StatelessWidget {
  final List<DeckProgress> deckProgressList;

  const DeckProgressList({super.key, required this.deckProgressList});

  @override
  Widget build(BuildContext context) {
    if (deckProgressList.isEmpty) {
      return Center(child: Text(AppLocalizations.of(context).progressDeckListEmpty));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: deckProgressList.length,
      itemBuilder: (context, index) {
        final dp = deckProgressList[index];
        return _DeckProgressCard(progress: dp);
      },
    );
  }
}

class _DeckProgressCard extends StatelessWidget {
  final DeckProgress progress;

  const _DeckProgressCard({required this.progress});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final masteryPct = (progress.masteryPercentage * 100).round();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    progress.deckTitle,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                Text(
                  '$masteryPct%',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.masteryPercentage,
                minHeight: 8,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatChip(
                  label: l10n.progressDeckListTotal,
                  value: '${progress.totalCards}',
                  color: theme.colorScheme.onSurface,
                ),
                _StatChip(
                  label: l10n.progressDeckListMastered,
                  value: '${progress.masteredCount}',
                  color: AppColors.of(context).masteryMastered,
                ),
                _StatChip(
                  label: l10n.progressDeckListLearning,
                  value: '${progress.learningCount}',
                  color: AppColors.of(context).masteryLearning,
                ),
                _StatChip(
                  label: l10n.progressDeckListDue,
                  value: '${progress.dueCount}',
                  color: AppColors.of(context).highlight,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
