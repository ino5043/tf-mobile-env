import 'package:flutter/material.dart';

import 'package:educards/features/progress/domain/entities/deck_progress.dart';

class DeckProgressList extends StatelessWidget {
  final List<DeckProgress> deckProgressList;

  const DeckProgressList({super.key, required this.deckProgressList});

  @override
  Widget build(BuildContext context) {
    if (deckProgressList.isEmpty) {
      return const Center(child: Text('No decks yet'));
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
                  label: 'Total',
                  value: '${progress.totalCards}',
                  color: theme.colorScheme.onSurface,
                ),
                _StatChip(
                  label: 'Mastered',
                  value: '${progress.masteredCount}',
                  color: Colors.green,
                ),
                _StatChip(
                  label: 'Learning',
                  value: '${progress.learningCount}',
                  color: Colors.orange,
                ),
                _StatChip(
                  label: 'Due',
                  value: '${progress.dueCount}',
                  color: theme.colorScheme.error,
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
