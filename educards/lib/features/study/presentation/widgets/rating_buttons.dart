import 'package:flutter/material.dart';

import 'package:educards/core/theme/app_tokens.dart';
import 'package:educards/features/study/domain/entities/review_rating.dart';
import 'package:educards/l10n/app_localizations.dart';

/// SM-2 の評価ボタン（もう一度・難しい・普通・簡単）。
///
/// 色はキーの色（ミント）の濃淡の 4 段で、意味の色（赤・緑）は使わない
/// （UI/UX 標準 4-4・4-15）。意味はアイコンと文字の組で伝える（4-3・7-1）。
/// 押せる大きさは 56dp 以上（6-8）。
class RatingButtons extends StatelessWidget {
  final void Function(ReviewRating rating) onRate;

  const RatingButtons({super.key, required this.onRate});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = AppColors.of(context);

    final items = [
      (
        rating: ReviewRating.again,
        label: l10n.ratingAgain,
        icon: Icons.replay_rounded,
        background: colors.ratingAgain,
        foreground: colors.onRatingLight,
      ),
      (
        rating: ReviewRating.hard,
        label: l10n.ratingHard,
        icon: Icons.sentiment_neutral_rounded,
        background: colors.ratingHard,
        foreground: colors.onRatingLight,
      ),
      (
        rating: ReviewRating.good,
        label: l10n.ratingGood,
        icon: Icons.sentiment_satisfied_rounded,
        background: colors.ratingGood,
        foreground: colors.onRatingStrong,
      ),
      (
        rating: ReviewRating.easy,
        label: l10n.ratingEasy,
        icon: Icons.star_rounded,
        background: colors.ratingEasy,
        foreground: colors.onRatingStrong,
      ),
    ];

    return Row(
      children: [
        for (final (index, item) in items.indexed) ...[
          if (index > 0) const SizedBox(width: 8),
          Expanded(
            child: _RatingButton(
              label: item.label,
              icon: item.icon,
              background: item.background,
              foreground: item.foreground,
              onPressed: () => onRate(item.rating),
            ),
          ),
        ],
      ],
    );
  }
}

class _RatingButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;
  final VoidCallback onPressed;

  const _RatingButton({
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final outline = Theme.of(context).colorScheme.outlineVariant;
    return Semantics(
      label: l10n.ratingSemantics(label),
      button: true,
      excludeSemantics: true,
      child: FilledButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(background),
          foregroundColor: WidgetStateProperty.all(foreground),
          minimumSize: WidgetStateProperty.all(const Size(56, 64)),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
          side: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.focused)) {
              return const BorderSide(color: AppPalette.focusOutline, width: 3);
            }
            return BorderSide(color: outline);
          }),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
