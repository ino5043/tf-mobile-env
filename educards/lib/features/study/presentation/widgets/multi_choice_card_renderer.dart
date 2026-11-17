import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:educards/features/deck/domain/entities/flashcard.dart';
import 'package:educards/l10n/app_localizations.dart';
import 'card_content_renderer.dart';

/// Renders multiple-choice cards.
///
/// Metadata JSON: `{"options":["A","B","C","D"],"correctIndex":0}`.
/// Front shows the question + options list.
/// Back highlights the correct option.
class MultiChoiceCardRenderer implements CardContentRenderer {
  const MultiChoiceCardRenderer();

  @override
  Widget buildFront(BuildContext context, Flashcard card) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final meta = _parseMeta(card.metadata);
    final options = meta?.options ?? [];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.cardRendererChooseAnswer,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.outline,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          card.front,
          style: theme.textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        ...options.asMap().entries.map((entry) {
          final label = String.fromCharCode(65 + entry.key); // A, B, C, D
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: OutlinedButton(
              onPressed: null, // Non-interactive in study mode
              style: OutlinedButton.styleFrom(
                alignment: Alignment.centerLeft,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              child: Text(
                '$label. ${entry.value}',
                style: theme.textTheme.bodyLarge,
              ),
            ),
          );
        }),
        const SizedBox(height: 12),
        Text(
          l10n.cardRendererTapToRevealAnswer,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  @override
  Widget buildBack(BuildContext context, Flashcard card) {
    final theme = Theme.of(context);
    final meta = _parseMeta(card.metadata);
    final options = meta?.options ?? [];
    final correctIndex = meta?.correctIndex ?? 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          card.front,
          style: theme.textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        ...options.asMap().entries.map((entry) {
          final label = String.fromCharCode(65 + entry.key);
          final isCorrect = entry.key == correctIndex;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isCorrect
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outlineVariant,
                  width: isCorrect ? 2 : 1,
                ),
                color: isCorrect
                    ? theme.colorScheme.primaryContainer
                    : null,
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  if (isCorrect)
                    Icon(Icons.check_circle,
                        color: theme.colorScheme.primary, size: 20)
                  else
                    Icon(Icons.circle_outlined,
                        color: theme.colorScheme.outlineVariant, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '$label. ${entry.value}',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight:
                            isCorrect ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 16),
        Text(
          card.back,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.outline,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  @override
  String getTextForTts(Flashcard card, {required bool isFlipped}) {
    final meta = _parseMeta(card.metadata);
    final options = meta?.options ?? [];

    if (isFlipped) {
      final correctIndex = meta?.correctIndex ?? 0;
      final correctAnswer = correctIndex < options.length
          ? options[correctIndex]
          : card.back;
      return 'The correct answer is: $correctAnswer. ${card.back}';
    }

    final buffer = StringBuffer(card.front);
    for (var i = 0; i < options.length; i++) {
      final label = String.fromCharCode(65 + i);
      buffer.write('. $label, ${options[i]}');
    }
    return buffer.toString();
  }

  @override
  String getAccessibilityLabel(Flashcard card, {required bool isFlipped}) {
    if (isFlipped) {
      return 'Answer: ${card.back}';
    }
    return 'Multiple choice: ${card.front}. Tap to reveal answer.';
  }

  _MultiChoiceMeta? _parseMeta(String metadata) {
    if (metadata.isEmpty) return null;
    try {
      final map = jsonDecode(metadata) as Map<String, dynamic>;
      final options = (map['options'] as List?)?.cast<String>() ?? [];
      final correctIndex = map['correctIndex'] as int? ?? 0;
      return _MultiChoiceMeta(options: options, correctIndex: correctIndex);
    } catch (_) {
      return null;
    }
  }
}

class _MultiChoiceMeta {
  final List<String> options;
  final int correctIndex;

  const _MultiChoiceMeta({required this.options, required this.correctIndex});
}
