import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:educards/features/study/domain/entities/spaced_repetition_data.dart';
import '../bloc/deck_detail_bloc.dart';
import '../bloc/deck_detail_event.dart';
import '../bloc/deck_detail_state.dart';
import '../../domain/entities/deck.dart';
import '../../domain/entities/flashcard.dart';

class DeckDetailPage extends StatelessWidget {
  const DeckDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DeckDetailBloc, DeckDetailState>(
      listener: (context, state) {
        if (state is DeckDetailLoaded && state.exportedJson != null) {
          _showExportDialog(context, state.exportedJson!);
        }
      },
      builder: (context, state) => switch (state) {
        DeckDetailLoading() => Scaffold(
            appBar: AppBar(title: const Text('Deck')),
            body: const Center(child: CircularProgressIndicator()),
          ),
        DeckDetailError(:final message) => Scaffold(
            appBar: AppBar(title: const Text('Deck')),
            body: Center(child: Text(message)),
          ),
        DeckDetailLoaded(:final deck) => _buildContent(context, deck),
      },
    );
  }

  Widget _buildContent(BuildContext context, Deck deck) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(deck.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit deck',
            onPressed: () async {
              await context.push('/decks/${deck.id}/edit');
              if (context.mounted) {
                context.read<DeckDetailBloc>().add(LoadDeckDetail(deck.id));
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            tooltip: 'Export deck',
            onPressed: () {
              context.read<DeckDetailBloc>().add(const ExportDeck());
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (deck.description.isNotEmpty) ...[
              Text(deck.description, style: theme.textTheme.bodyLarge),
              const SizedBox(height: 16),
            ],
            // Stats row
            Row(
              children: [
                _StatCard(
                  icon: Icons.style,
                  label: 'Total',
                  value: '${deck.totalCards}',
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 12),
                _StatCard(
                  icon: Icons.schedule,
                  label: 'Due',
                  value: '${deck.dueCards}',
                  color: deck.dueCards > 0
                      ? colorScheme.error
                      : colorScheme.outline,
                ),
                const SizedBox(width: 12),
                _StatCard(
                  icon: Icons.trending_up,
                  label: 'Mastery',
                  value: '${(deck.masteryPercentage * 100).round()}%',
                  color: Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Study button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: deck.dueCards > 0
                    ? () => context.push('/study/${deck.id}')
                    : null,
                icon: const Icon(Icons.play_arrow),
                label: Text(
                  deck.dueCards > 0
                      ? 'Study Now (${deck.dueCards} due)'
                      : 'No cards due',
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Cards list
            Text(
              'Cards (${deck.totalCards})',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...deck.cards.asMap().entries.map((entry) {
              final card = entry.value;
              return _FlashcardTile(card: card);
            }),
          ],
        ),
      ),
    );
  }

  void _showExportDialog(BuildContext context, String json) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Export Deck'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: SingleChildScrollView(
            child: SelectableText(
              json,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: json));
              Navigator.of(dialogContext).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Copied to clipboard')),
              );
            },
            child: const Text('Copy to Clipboard'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(label, style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _FlashcardTile extends StatelessWidget {
  final Flashcard card;

  const _FlashcardTile({required this.card});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final masteryColor = _masteryColor(card.srData.mastery);
    final masteryLabel = _masteryLabel(card.srData.mastery);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    card.front,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: masteryColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    masteryLabel,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: masteryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              card.back,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _masteryColor(MasteryLevel level) {
    return switch (level) {
      MasteryLevel.newCard => Colors.grey,
      MasteryLevel.learning => Colors.orange,
      MasteryLevel.review => Colors.blue,
      MasteryLevel.mastered => Colors.green,
    };
  }

  String _masteryLabel(MasteryLevel level) {
    return switch (level) {
      MasteryLevel.newCard => 'New',
      MasteryLevel.learning => 'Learning',
      MasteryLevel.review => 'Review',
      MasteryLevel.mastered => 'Mastered',
    };
  }
}
