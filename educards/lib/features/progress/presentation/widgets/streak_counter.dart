import 'package:flutter/material.dart';

import 'package:educards/features/progress/domain/entities/streak_info.dart';

class StreakCounter extends StatelessWidget {
  final StreakInfo streak;

  const StreakCounter({super.key, required this.streak});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Semantics(
      label: '${streak.currentStreak} day streak. '
          'Longest streak: ${streak.longestStreak} days.',
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
                    ? Colors.orange
                    : colorScheme.outline,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${streak.currentStreak} Day Streak',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Best: ${streak.longestStreak} days',
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
                  semanticLabel: 'Studied today',
                ),
            ],
          ),
        ),
      ),
    );
  }
}
