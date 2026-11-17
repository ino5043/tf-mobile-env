import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:educards/features/deck/domain/entities/flashcard.dart';
import 'package:educards/l10n/app_localizations.dart';
import 'card_content_renderer.dart';
import 'card_side_label.dart';

/// Renders step-by-step solution cards (math, problem-solving).
///
/// Metadata JSON: `{"hints":["hint1"],"steps":["step1","step2"]}`.
/// Front shows the problem + hints.
/// Back shows the step-by-step solution + final answer.
class StepByStepCardRenderer implements CardContentRenderer {
  const StepByStepCardRenderer();

  @override
  Widget buildFront(BuildContext context, Flashcard card) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final meta = _parseMeta(card.metadata);
    final hints = meta?.hints ?? [];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CardSideLabel(l10n.cardRendererProblem),
        const SizedBox(height: 16),
        Text(
          card.front,
          style: theme.textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        if (hints.isNotEmpty) ...[
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: theme.colorScheme.tertiaryContainer.withAlpha(128),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb_outline,
                        size: 16, color: theme.colorScheme.tertiary),
                    const SizedBox(width: 4),
                    Text(
                      l10n.cardRendererHints,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.tertiary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...hints.map((hint) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('• ', style: theme.textTheme.bodyMedium),
                          Expanded(
                            child: Text(hint,
                                style: theme.textTheme.bodyMedium),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ],
        const SizedBox(height: 24),
        Text(
          l10n.cardRendererTapToRevealSolution,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  @override
  Widget buildBack(BuildContext context, Flashcard card) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final meta = _parseMeta(card.metadata);
    final steps = meta?.steps ?? [];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CardSideLabel(l10n.cardRendererSolution),
        if (steps.isNotEmpty) ...[
          const SizedBox(height: 16),
          ...steps.asMap().entries.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.colorScheme.primaryContainer,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${entry.key + 1}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                  ],
                ),
              )),
        ],
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle,
                color: theme.colorScheme.primary, size: 20),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                card.back,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  String getTextForTts(Flashcard card, {required bool isFlipped}) {
    if (isFlipped) {
      final meta = _parseMeta(card.metadata);
      final steps = meta?.steps ?? [];
      if (steps.isNotEmpty) {
        final stepsText = steps
            .asMap()
            .entries
            .map((e) => 'Step ${e.key + 1}: ${e.value}')
            .join('. ');
        return '$stepsText. Answer: ${card.back}';
      }
      return card.back;
    }
    return card.front;
  }

  @override
  String getAccessibilityLabel(Flashcard card, {required bool isFlipped}) {
    if (isFlipped) {
      return 'Solution: ${card.back}';
    }
    return 'Problem: ${card.front}. Tap to reveal solution.';
  }

  _StepByStepMeta? _parseMeta(String metadata) {
    if (metadata.isEmpty) return null;
    try {
      final map = jsonDecode(metadata) as Map<String, dynamic>;
      final hints = (map['hints'] as List?)?.cast<String>() ?? [];
      final steps = (map['steps'] as List?)?.cast<String>() ?? [];
      return _StepByStepMeta(hints: hints, steps: steps);
    } catch (_) {
      return null;
    }
  }
}

class _StepByStepMeta {
  final List<String> hints;
  final List<String> steps;

  const _StepByStepMeta({required this.hints, required this.steps});
}
