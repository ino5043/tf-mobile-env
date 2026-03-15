import 'package:flutter/material.dart';

import 'package:educards/features/deck/domain/entities/card_type.dart';
import 'package:educards/features/deck/domain/entities/flashcard.dart';
import 'basic_card_renderer.dart';

/// Strategy interface for rendering card content by type.
///
/// Each [CardType] has a corresponding renderer that determines
/// how front/back content is displayed and what text is used for TTS.
abstract class CardContentRenderer {
  Widget buildFront(BuildContext context, Flashcard card);
  Widget buildBack(BuildContext context, Flashcard card);

  /// Text to speak via TTS for the currently visible side.
  String getTextForTts(Flashcard card, {required bool isFlipped});

  /// Accessibility label for the currently visible side.
  String getAccessibilityLabel(Flashcard card, {required bool isFlipped});
}

/// Returns the appropriate renderer for the given [CardType].
CardContentRenderer getRenderer(CardType type) {
  return switch (type) {
    CardType.basic => const BasicCardRenderer(),
    // Phase 2 will add:
    // CardType.cloze => const ClozeCardRenderer(),
    // CardType.multiChoice => const MultiChoiceCardRenderer(),
    // CardType.stepByStep => const StepByStepCardRenderer(),
    _ => const BasicCardRenderer(),
  };
}
