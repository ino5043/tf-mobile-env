import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:educards/l10n/app_localizations.dart';

void main() {
  group('AppLocalizations', () {
    testWidgets('resolves English strings', (tester) async {
      late AppLocalizations l10n;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              l10n = AppLocalizations.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(l10n.appTitle, 'EduCards');
      expect(l10n.navDecks, 'Decks');
      expect(l10n.navStudy, 'Study');
      expect(l10n.navProgress, 'Progress');
    });

    testWidgets('resolves Japanese strings', (tester) async {
      late AppLocalizations l10n;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ja'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              l10n = AppLocalizations.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(l10n.appTitle, 'EduCards');
      expect(l10n.navDecks, 'デッキ');
      expect(l10n.navStudy, '学習');
      expect(l10n.navProgress, '進捗');
    });

    testWidgets('parameterized messages work correctly', (tester) async {
      late AppLocalizations l10n;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              l10n = AppLocalizations.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(l10n.deckDetailCardsCount(5), contains('5'));
      expect(l10n.studyCardProgress(3, 10), contains('3'));
    });

    test('supportedLocales includes en and ja', () {
      final codes =
          AppLocalizations.supportedLocales.map((l) => l.languageCode);
      expect(codes, contains('en'));
      expect(codes, contains('ja'));
    });
  });
}
