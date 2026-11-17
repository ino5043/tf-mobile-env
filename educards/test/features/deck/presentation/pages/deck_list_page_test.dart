import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:educards/features/deck/presentation/bloc/deck_list_bloc.dart';
import 'package:educards/features/deck/presentation/bloc/deck_list_event.dart';
import 'package:educards/features/deck/presentation/bloc/deck_list_state.dart';
import 'package:educards/features/deck/presentation/pages/deck_list_page.dart';
import 'package:educards/l10n/app_localizations.dart';

class MockDeckListBloc extends MockBloc<DeckListEvent, DeckListState>
    implements DeckListBloc {}

void main() {
  testWidgets('the deck list has a button that opens Settings',
      (tester) async {
    final bloc = MockDeckListBloc();
    when(() => bloc.state).thenReturn(const DeckListLoaded([]));

    final router = GoRouter(
      initialLocation: '/decks',
      routes: [
        GoRoute(
          path: '/decks',
          builder: (_, _) => BlocProvider<DeckListBloc>.value(
            value: bloc,
            child: const DeckListPage(),
          ),
        ),
        GoRoute(
          path: '/settings',
          builder: (_, _) => const Scaffold(body: Text('settings page')),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(
      routerConfig: router,
      locale: const Locale('ja'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    ));
    await tester.pumpAndSettle();

    final button = find.byTooltip('設定');
    expect(button, findsOneWidget);

    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(find.text('settings page'), findsOneWidget);
  });
}
