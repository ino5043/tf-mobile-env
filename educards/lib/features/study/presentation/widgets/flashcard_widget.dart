import 'package:flutter/material.dart';

import 'package:educards/core/theme/app_tokens.dart';

import 'package:educards/features/deck/domain/entities/flashcard.dart';
import 'card_content_renderer.dart';

/// Animated flashcard with flip gesture.
/// Delegates content rendering to [CardContentRenderer] based on card type.
/// Respects "reduce motion" accessibility setting.
class FlashcardWidget extends StatelessWidget {
  final Flashcard card;
  final bool isFlipped;
  final VoidCallback onFlip;

  const FlashcardWidget({
    super.key,
    required this.card,
    required this.isFlipped,
    required this.onFlip,
  });

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final renderer = getRenderer(card.cardType);

    return Semantics(
      label: renderer.getAccessibilityLabel(card, isFlipped: isFlipped),
      button: !isFlipped,
      child: GestureDetector(
        onTap: isFlipped ? null : onFlip,
        child: AnimatedSwitcher(
          duration: reduceMotion
              ? Duration.zero
              : const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: Card(
            key: ValueKey(isFlipped),
            // 影ではなく枠線で境界を示す（UI/UX 標準 3-11）。角は大きく丸める
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.xl),
              side: BorderSide(color: Theme.of(context).colorScheme.outline),
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              child: Center(
                child: isFlipped
                    ? renderer.buildBack(context, card)
                    : renderer.buildFront(context, card),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
