import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:educards/l10n/app_localizations.dart';
import 'package:educards/core/theme/app_tokens.dart';
import 'package:educards/features/study/domain/entities/spaced_repetition_data.dart';
import 'package:educards/features/study/presentation/widgets/mastery_colors.dart';
import '../bloc/deck_detail_bloc.dart';
import '../bloc/deck_detail_event.dart';
import '../bloc/deck_detail_state.dart';
import '../../domain/entities/deck.dart';
import '../../domain/entities/flashcard.dart';

class DeckDetailPage extends StatelessWidget {
  const DeckDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocConsumer<DeckDetailBloc, DeckDetailState>(
      listener: (context, state) {
        if (state is DeckDetailLoaded && state.exportedJson != null) {
          _showExportDialog(context, state.exportedJson!);
        }
      },
      builder: (context, state) => switch (state) {
        DeckDetailLoading() => Scaffold(
            appBar: AppBar(title: Text(l10n.deckDetailTitle)),
            body: const Center(child: CircularProgressIndicator()),
          ),
        DeckDetailError(:final message) => Scaffold(
            appBar: AppBar(title: Text(l10n.deckDetailTitle)),
            body: Center(child: Text(message)),
          ),
        DeckDetailLoaded(:final deck) => _buildContent(context, deck),
      },
    );
  }

  Widget _buildContent(BuildContext context, Deck deck) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(deck.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: l10n.deckDetailEdit,
            onPressed: () async {
              await context.push('/decks/${deck.id}/edit');
              if (context.mounted) {
                context.read<DeckDetailBloc>().add(LoadDeckDetail(deck.id));
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            tooltip: l10n.deckDetailExport,
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
                  label: l10n.deckDetailTotal,
                  value: '${deck.totalCards}',
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 12),
                _StatCard(
                  icon: Icons.schedule,
                  label: l10n.deckDetailDue,
                  value: '${deck.dueCards}',
                  // 期限のカードはエラーではないので、赤ではなく強調の色にする（4-4）
                  color: deck.dueCards > 0
                      ? AppColors.of(context).highlight
                      : colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                _StatCard(
                  icon: Icons.trending_up,
                  label: l10n.deckDetailMastery,
                  value: '${(deck.masteryPercentage * 100).round()}%',
                  color: AppColors.of(context).masteryMastered,
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
                      ? l10n.deckDetailStudyNow(deck.dueCards)
                      : l10n.deckDetailNoCardsDue,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Listen mode button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: deck.totalCards > 0
                    ? () => context.push('/listen/${deck.id}')
                    : null,
                icon: const Icon(Icons.headphones),
                label: Text(
                  deck.totalCards > 0
                      ? l10n.deckDetailListenMode(deck.totalCards)
                      : l10n.deckDetailNoCardsToListen,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Cards list
            Text(
              l10n.deckDetailCardsCount(deck.totalCards),
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
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deckDetailExportTitle),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: SingleChildScrollView(
            child: SelectableText(
              json,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: json));
              Navigator.of(dialogContext).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.deckDetailCopied)),
              );
            },
            child: Text(l10n.deckDetailCopyButton),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.deckDetailClose),
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
    final masteryColor =
        AppColors.of(context).forMastery(card.srData.mastery);
    final masteryLabel = _masteryLabel(context, card.srData.mastery);

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
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }


  String _masteryLabel(BuildContext context, MasteryLevel level) {
    final l10n = AppLocalizations.of(context);
    return switch (level) {
      MasteryLevel.newCard => l10n.deckDetailStatusNew,
      MasteryLevel.learning => l10n.deckDetailStatusLearning,
      MasteryLevel.review => l10n.deckDetailStatusReview,
      MasteryLevel.mastered => l10n.deckDetailStatusMastered,
    };
  }
}
