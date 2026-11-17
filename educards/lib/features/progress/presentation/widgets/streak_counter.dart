import 'package:flutter/material.dart';

import 'package:educards/features/progress/domain/entities/streak_info.dart';
import 'package:educards/l10n/app_localizations.dart';

class StreakCounter extends StatelessWidget {
  final StreakInfo streak;

  const StreakCounter({super.key, required this.streak});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Semantics(
      label: l10n.streakSemantics(streak.currentStreak, streak.longestStreak),
      child: Card(
        color: colorScheme.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(
                Icons.local_fire_department,
                size: 48,
                color: streak.currentStreak > 0
                    ? colorScheme.tertiary
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.streakDays(streak.currentStreak),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.streakBest(streak.longestStreak),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onPrimaryContainer.withAlpha(179),
                      ),
                    ),
                  ],
                ),
              ),
              if (streak.isActiveToday)
                Icon(
                  Icons.check_circle,
                  color: colorScheme.primary,
                  size: 32,
                  semanticLabel: l10n.streakStudiedToday,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
