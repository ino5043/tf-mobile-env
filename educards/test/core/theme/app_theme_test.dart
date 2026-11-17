import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:educards/core/theme/app_theme.dart';
import 'package:educards/core/theme/app_tokens.dart';

/// WCAG のコントラスト比（UI/UX 標準 4-1・4-2 の計算）
double contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  for (final entry in {
    'light': (AppTheme.light, AppColors.light),
    'dark': (AppTheme.dark, AppColors.dark),
  }.entries) {
    final name = entry.key;
    final theme = entry.value.$1;
    final colors = entry.value.$2;
    final s = theme.colorScheme;
    final bg = theme.scaffoldBackgroundColor;

    group('$name theme contrast', () {
      // 文字と背景は 4.5:1 以上（4-1）
      final textPairs = <String, (Color, Color)>{
        'onPrimary / primary': (s.onPrimary, s.primary),
        'primary / surface': (s.primary, s.surface),
        'primary / background': (s.primary, bg),
        'onPrimaryContainer / primaryContainer':
            (s.onPrimaryContainer, s.primaryContainer),
        'onTertiary / tertiary': (s.onTertiary, s.tertiary),
        'tertiary / surface': (s.tertiary, s.surface),
        'onTertiaryContainer / tertiaryContainer':
            (s.onTertiaryContainer, s.tertiaryContainer),
        'onSurface / surface': (s.onSurface, s.surface),
        'onSurface / background': (s.onSurface, bg),
        'onSurfaceVariant / surface': (s.onSurfaceVariant, s.surface),
        'onSurfaceVariant / background': (s.onSurfaceVariant, bg),
        'onSurfaceVariant / surfaceContainer':
            (s.onSurfaceVariant, s.surfaceContainer),
        'error / surface': (s.error, s.surface),
        'onError / error': (s.onError, s.error),
        'onInverseSurface / inverseSurface':
            (s.onInverseSurface, s.inverseSurface),
        'info / surface': (colors.info, s.surface),
        'warningText / surface': (colors.warningText, s.surface),
        'highlight / surface': (colors.highlight, s.surface),
        'onRatingLight / ratingAgain': (colors.onRatingLight, colors.ratingAgain),
        'onRatingLight / ratingHard': (colors.onRatingLight, colors.ratingHard),
        'onRatingStrong / ratingGood': (colors.onRatingStrong, colors.ratingGood),
        'onRatingStrong / ratingEasy': (colors.onRatingStrong, colors.ratingEasy),
        'masteryMastered / surface (as text)': (colors.masteryMastered, s.surface),
        'masteryLearning / surface (as text)': (colors.masteryLearning, s.surface),
      };
      for (final p in textPairs.entries) {
        test('text ${p.key} >= 4.5', () {
          expect(contrast(p.value.$1, p.value.$2), greaterThanOrEqualTo(4.5));
        });
      }

      // 文字以外（枠線・グラフの系列・アイコン）は 3:1 以上（4-2）
      final nonTextPairs = <String, (Color, Color)>{
        'outline / surface': (s.outline, s.surface),
        'outline / background': (s.outline, bg),
        'masteryNew / surface': (colors.masteryNew, s.surface),
        'masteryLearning / surface': (colors.masteryLearning, s.surface),
        'masteryReview / surface': (colors.masteryReview, s.surface),
        'masteryMastered / surface': (colors.masteryMastered, s.surface),
        'chartCorrect / surface': (colors.chartCorrect, s.surface),
        'chartIncorrect / surface': (colors.chartIncorrect, s.surface),
        'tertiary (streak icon) / primaryContainer':
            (s.tertiary, s.primaryContainer),
      };
      for (final p in nonTextPairs.entries) {
        test('non-text ${p.key} >= 3.0', () {
          expect(contrast(p.value.$1, p.value.$2), greaterThanOrEqualTo(3.0));
        });
      }
    });
  }

  test('focus ring keeps the DADS yellow and black (4-8)', () {
    expect(AppPalette.focusRing, const Color(0xFFFFD43D));
    expect(AppPalette.focusOutline, const Color(0xFF000000));
  });

  test('body and button text are at least 16, small text at least 14 (5-4, 5-5)',
      () {
    for (final theme in [AppTheme.light, AppTheme.dark]) {
      final t = theme.textTheme;
      expect(t.bodyLarge!.fontSize, greaterThanOrEqualTo(16));
      expect(t.bodyMedium!.fontSize, greaterThanOrEqualTo(16));
      expect(t.labelLarge!.fontSize, greaterThanOrEqualTo(16));
      for (final style in [t.bodySmall, t.labelMedium, t.labelSmall]) {
        expect(style!.fontSize, greaterThanOrEqualTo(14));
      }
    }
  });

  test('screens do not hard-code colors outside lib/core/theme (3-1, 3-3)', () {
    final offenders = <String>[];
    final hardCoded = RegExp(r'(?<![A-Za-z])Colors\.(?!transparent)|Color\(0x');
    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final path = entity.path.replaceAll('\\', '/');
      if (path.startsWith('lib/core/theme/') || path.startsWith('lib/l10n/')) {
        continue;
      }
      final lines = entity.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        if (hardCoded.hasMatch(lines[i])) offenders.add('$path:${i + 1}');
      }
    }
    expect(offenders, isEmpty);
  });
}
