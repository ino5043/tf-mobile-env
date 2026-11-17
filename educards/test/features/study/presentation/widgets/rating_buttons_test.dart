import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:educards/core/theme/app_theme.dart';
import 'package:educards/features/study/domain/entities/review_rating.dart';
import 'package:educards/features/study/presentation/widgets/rating_buttons.dart';
import 'package:educards/l10n/app_localizations.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: AppTheme.light,
      locale: const Locale('ja'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: Padding(padding: const EdgeInsets.all(16), child: child)),
    );

void main() {
  testWidgets('shows a text label with every rating (icon is not the only cue)',
      (tester) async {
    await tester.pumpWidget(_wrap(RatingButtons(onRate: (_) {})));
    await tester.pumpAndSettle();

    for (final label in ['もう一度', '難しい', '普通', '簡単']) {
      expect(find.text(label), findsOneWidget);
    }
  });

  testWidgets('sends the rating of the pressed button', (tester) async {
    final pressed = <ReviewRating>[];
    await tester.pumpWidget(_wrap(RatingButtons(onRate: pressed.add)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('もう一度'));
    await tester.tap(find.text('簡単'));

    expect(pressed, [ReviewRating.again, ReviewRating.easy]);
  });

  testWidgets('every button is at least 48 x 48 (6-8)', (tester) async {
    await tester.pumpWidget(_wrap(RatingButtons(onRate: (_) {})));
    await tester.pumpAndSettle();

    final buttons = find.byType(FilledButton);
    expect(buttons, findsNWidgets(4));
    for (final element in buttons.evaluate()) {
      final size = (element.renderObject! as RenderBox).size;
      expect(size.width, greaterThanOrEqualTo(48));
      expect(size.height, greaterThanOrEqualTo(48));
    }
  });
}
