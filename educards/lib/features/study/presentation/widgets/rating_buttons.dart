import 'package:flutter/material.dart';

import 'package:educards/features/study/domain/entities/review_rating.dart';
import 'package:educards/l10n/app_localizations.dart';

/// Rating buttons for SM-2 difficulty feedback.
/// Touch targets are 48x48dp minimum (Material Design 3 / WCAG).
class RatingButtons extends StatelessWidget {
  final void Function(ReviewRating rating) onRate;

  const RatingButtons({super.key, required this.onRate});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _RatingButton(
          label: l10n.ratingAgain,
          color: colorScheme.error,
          icon: Icons.close,
          onPressed: () => onRate(ReviewRating.again),
        ),
        _RatingButton(
          label: l10n.ratingHard,
          color: colorScheme.tertiary,
          icon: Icons.sentiment_dissatisfied,
          onPressed: () => onRate(ReviewRating.hard),
        ),
        _RatingButton(
          label: l10n.ratingGood,
          color: colorScheme.primary,
          icon: Icons.sentiment_satisfied,
          onPressed: () => onRate(ReviewRating.good),
        ),
        _RatingButton(
          label: l10n.ratingEasy,
          color: colorScheme.secondary,
          icon: Icons.sentiment_very_satisfied,
          onPressed: () => onRate(ReviewRating.easy),
        ),
      ],
    );
  }
}

class _RatingButton extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onPressed;

  const _RatingButton({
    required this.label,
    required this.color,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Semantics(
      label: l10n.ratingSemantics(label),
      button: true,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: const BoxConstraints(
            minWidth: 48,
            minHeight: 48,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: color,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
