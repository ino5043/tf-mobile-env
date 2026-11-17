import 'package:flutter/material.dart';

import 'package:educards/features/deck/domain/entities/flashcard.dart';
import 'package:educards/l10n/app_localizations.dart';
import 'card_content_renderer.dart';
import 'card_side_label.dart';

/// Renders standard question/answer cards.
class BasicCardRenderer implements CardContentRenderer {
  const BasicCardRenderer();

  @override
  Widget buildFront(BuildContext context, Flashcard card) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CardSideLabel(l10n.cardRendererQuestion),
        const SizedBox(height: 16),
        // 覚える対象を大きく、キーの色で目立たせる（孤立効果）
        Text(
          card.front,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.primary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Text(
          l10n.cardRendererTapToReveal,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  @override
  Widget buildBack(BuildContext context, Flashcard card) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CardSideLabel(l10n.cardRendererAnswer),
        const SizedBox(height: 16),
        Text(
          card.back,
          style: theme.textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  @override
  String getTextForTts(Flashcard card, {required bool isFlipped}) {
    return isFlipped ? card.back : card.front;
  }

  @override
  String getAccessibilityLabel(Flashcard card, {required bool isFlipped}) {
    return isFlipped
        ? 'Answer: ${card.back}'
        : 'Question: ${card.front}. Tap to reveal answer.';
  }
}
