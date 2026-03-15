import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:educards/core/widgets/empty_state.dart';
import 'package:educards/core/widgets/error_display.dart';
import 'package:educards/core/widgets/loading_indicator.dart';
import 'package:educards/features/study/domain/entities/study_queue.dart';
import '../bloc/study_plan_bloc.dart';
import '../bloc/study_plan_event.dart';
import '../bloc/study_plan_state.dart';

class StudyPlanPage extends StatelessWidget {
  const StudyPlanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Today's Study"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: BlocBuilder<StudyPlanBloc, StudyPlanState>(
        builder: (context, state) => switch (state) {
          StudyPlanInitial() || StudyPlanLoading() => const LoadingIndicator(
              message: 'Loading study plan...',
            ),
          StudyPlanError(:final message) => ErrorDisplay(
              message: message,
              onRetry: () =>
                  context.read<StudyPlanBloc>().add(const LoadStudyPlan()),
            ),
          StudyPlanLoaded(:final queue) =>
            queue.isEmpty
                ? const EmptyState(
                    icon: Icons.check_circle_outline,
                    title: 'All done!',
                    subtitle:
                        'No cards to study today. Come back tomorrow or add new decks.',
                  )
                : _StudyPlanContent(queue: queue),
        },
      ),
    );
  }
}

class _StudyPlanContent extends StatelessWidget {
  final StudyQueue queue;

  const _StudyPlanContent({required this.queue});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary cards
            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    icon: Icons.fiber_new,
                    label: 'New',
                    count: queue.newCards.length,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    icon: Icons.refresh,
                    label: 'Review',
                    count: queue.reviewCards.length,
                    color: theme.colorScheme.secondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    icon: Icons.style,
                    label: 'Total',
                    count: queue.totalCards,
                    color: theme.colorScheme.tertiary,
                  ),
                ),
              ],
            ),
            if (queue.hasOverflow) ...[
              const SizedBox(height: 12),
              Card(
                color: theme.colorScheme.surfaceContainerHighest,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${queue.remainingNew + queue.remainingReview} cards deferred to next session',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            // New cards section
            if (queue.newCards.isNotEmpty) ...[
              Text('New Cards', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              ...queue.newCards.map((card) => _CardTile(
                    front: card.front,
                    deckId: card.deckId,
                    isNew: true,
                    onTap: () => context.push('/study/${card.deckId}'),
                  )),
            ],
            if (queue.reviewCards.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('Review Cards', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              ...queue.reviewCards.map((card) => _CardTile(
                    front: card.front,
                    deckId: card.deckId,
                    isNew: false,
                    onTap: () => context.push('/study/${card.deckId}'),
                  )),
            ],
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color color;

  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              '$count',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _CardTile extends StatelessWidget {
  final String front;
  final String deckId;
  final bool isNew;
  final VoidCallback onTap;

  const _CardTile({
    required this.front,
    required this.deckId,
    required this.isNew,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          isNew ? Icons.fiber_new : Icons.refresh,
          color: isNew
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.secondary,
        ),
        title: Text(
          front,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
