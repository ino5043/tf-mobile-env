import 'package:flutter/material.dart';

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
            elevation: 4,
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
