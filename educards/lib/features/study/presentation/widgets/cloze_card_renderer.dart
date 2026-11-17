import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:educards/features/deck/domain/entities/flashcard.dart';
import 'package:educards/l10n/app_localizations.dart';
import 'card_content_renderer.dart';
import 'card_side_label.dart';

/// Renders cloze (fill-in-the-blank) cards.
///
/// Front text uses `{{word}}` markers. Metadata JSON: `{"blanks":["word"]}`.
/// Front display replaces `{{word}}` with underscored blanks.
/// Back display shows the full sentence with blanks highlighted.
class ClozeCardRenderer implements CardContentRenderer {
  const ClozeCardRenderer();

  static final _blankPattern = RegExp(r'\{\{(.+?)\}\}');

  @override
  Widget buildFront(BuildContext context, Flashcard card) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    // 空欄を薄いミントの面で目立たせる（覚える対象の場所を一目で分かるように）
    final blankStyle = TextStyle(
      color: theme.colorScheme.onPrimaryContainer,
      backgroundColor: theme.colorScheme.primaryContainer,
      fontWeight: FontWeight.w700,
    );
    final frontSpans = <InlineSpan>[];
    final frontParts = card.front.split(_blankPattern);
    final frontMatches = _blankPattern.allMatches(card.front).toList();
    for (var i = 0; i < frontParts.length; i++) {
      if (frontParts[i].isNotEmpty) {
        frontSpans.add(TextSpan(text: frontParts[i]));
      }
      if (i < frontMatches.length) {
        final length = frontMatches[i].group(1)!.length.clamp(3, 10);
        frontSpans.add(TextSpan(text: ' ${'＿' * length} ', style: blankStyle));
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CardSideLabel(l10n.cardRendererFillInTheBlank),
        const SizedBox(height: 16),
        Text.rich(
          TextSpan(children: frontSpans),
          style: theme.textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Text(
          l10n.cardRendererTapToRevealAnswer,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  @override
  Widget buildBack(BuildContext context, Flashcard card) {
    final theme = Theme.of(context);
    final blanks = _parseBlanks(card.metadata);

    // Build rich text with blanks highlighted
    final spans = <InlineSpan>[];
    final parts = card.front.split(_blankPattern);
    final matches = _blankPattern.allMatches(card.front).toList();

    for (var i = 0; i < parts.length; i++) {
      if (parts[i].isNotEmpty) {
        spans.add(TextSpan(text: parts[i]));
      }
      if (i < matches.length) {
        final blankWord = matches[i].group(1)!;
        spans.add(TextSpan(
          text: blankWord,
          style: TextStyle(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.underline,
          ),
        ));
      }
    }

    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CardSideLabel(l10n.cardRendererAnswer),
        const SizedBox(height: 16),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: theme.textTheme.headlineSmall,
            children: spans,
          ),
        ),
        if (blanks.isNotEmpty) ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: blanks
                .map((b) => Chip(
                      label: Text(b),
                      backgroundColor:
                          theme.colorScheme.primaryContainer,
                    ))
                .toList(),
          ),
        ],
      ],
    );
  }

  @override
  String getTextForTts(Flashcard card, {required bool isFlipped}) {
    if (isFlipped) {
      // Read the full sentence with blanks filled
      return card.front.replaceAllMapped(
        _blankPattern,
        (m) => m.group(1)!,
      );
    }
    // Read with "blank" replacing the hidden words
    return card.front.replaceAllMapped(
      _blankPattern,
      (_) => 'blank',
    );
  }

  @override
  String getAccessibilityLabel(Flashcard card, {required bool isFlipped}) {
    if (isFlipped) {
      final filled = card.front.replaceAllMapped(
        _blankPattern,
        (m) => m.group(1)!,
      );
      return 'Answer: $filled';
    }
    final blanked = card.front.replaceAllMapped(
      _blankPattern,
      (_) => 'blank',
    );
    return 'Fill in the blank: $blanked. Tap to reveal answer.';
  }

  List<String> _parseBlanks(String metadata) {
    if (metadata.isEmpty) return [];
    try {
      final map = jsonDecode(metadata) as Map<String, dynamic>;
      final blanks = map['blanks'];
      if (blanks is List) {
        return blanks.cast<String>();
      }
    } catch (_) {}
    return [];
  }
}
