import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'core/di/injection_container.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'features/deck/presentation/bloc/deck_create_bloc.dart';
import 'features/deck/presentation/bloc/deck_detail_bloc.dart';
import 'features/deck/presentation/bloc/deck_detail_event.dart';
import 'features/deck/presentation/bloc/deck_edit_bloc.dart';
import 'features/deck/presentation/bloc/deck_edit_event.dart';
import 'features/deck/presentation/bloc/deck_list_bloc.dart';
import 'features/deck/presentation/bloc/deck_list_event.dart';
import 'features/deck/presentation/pages/deck_create_page.dart';
import 'features/deck/presentation/pages/deck_detail_page.dart';
import 'features/deck/presentation/pages/deck_edit_page.dart';
import 'features/deck/presentation/pages/deck_list_page.dart';
import 'features/progress/presentation/bloc/progress_bloc.dart';
import 'features/progress/presentation/bloc/progress_event.dart';
import 'features/progress/presentation/pages/progress_page.dart';
import 'features/settings/presentation/bloc/settings_bloc.dart';
import 'features/settings/presentation/bloc/settings_event.dart';
import 'features/settings/presentation/pages/settings_page.dart';
import 'features/study/presentation/bloc/study_plan_bloc.dart';
import 'features/study/presentation/bloc/study_plan_event.dart';
import 'features/study/presentation/bloc/listen_mode_bloc.dart';
import 'features/study/presentation/bloc/listen_mode_event.dart';
import 'features/study/presentation/bloc/study_session_bloc.dart';
import 'features/study/presentation/bloc/study_session_event.dart';
import 'features/study/presentation/pages/listen_mode_page.dart';
import 'features/study/presentation/pages/study_plan_page.dart';
import 'features/study/presentation/pages/study_session_page.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final _router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/decks',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavigation(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/decks',
              builder: (context, state) => BlocProvider(
                create: (_) => sl<DeckListBloc>()..add(const LoadDecks()),
                child: const DeckListPage(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/study-plan',
              builder: (context, state) => BlocProvider(
                create: (_) =>
                    sl<StudyPlanBloc>()..add(const LoadStudyPlan()),
                child: const StudyPlanPage(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/progress',
              builder: (context, state) => BlocProvider(
                create: (_) =>
                    sl<ProgressBloc>()..add(const LoadProgress()),
                child: const ProgressPage(),
              ),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/decks/create',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => BlocProvider(
        create: (_) => sl<DeckCreateBloc>(),
        child: const DeckCreatePage(),
      ),
    ),
    GoRoute(
      path: '/decks/:deckId',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final deckId = state.pathParameters['deckId']!;
        return BlocProvider(
          create: (_) =>
              sl<DeckDetailBloc>()..add(LoadDeckDetail(deckId)),
          child: const DeckDetailPage(),
        );
      },
    ),
    GoRoute(
      path: '/decks/:deckId/edit',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final deckId = state.pathParameters['deckId']!;
        return BlocProvider(
          create: (_) =>
              sl<DeckEditBloc>()..add(LoadDeckForEdit(deckId)),
          child: const DeckEditPage(),
        );
      },
    ),
    GoRoute(
      path: '/study/:deckId',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final deckId = state.pathParameters['deckId']!;
        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) =>
                  sl<StudySessionBloc>()..add(StartStudySession(deckId)),
            ),
            BlocProvider(
              create: (_) => sl<SettingsBloc>()..add(const LoadSettings()),
            ),
          ],
          child: const StudySessionPage(),
        );
      },
    ),
    GoRoute(
      path: '/listen/:deckId',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final deckId = state.pathParameters['deckId']!;
        return BlocProvider(
          create: (_) =>
              sl<ListenModeBloc>()..add(StartListenMode(deckId)),
          child: const ListenModePage(),
        );
      },
    ),
    GoRoute(
      path: '/settings',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => BlocProvider(
        create: (_) => sl<SettingsBloc>()..add(const LoadSettings()),
        child: const SettingsPage(),
      ),
    ),
  ],
);

/// Global locale notifier — controlled by SettingsBloc.
final localeNotifier = ValueNotifier<Locale?>(null);

class EduCardsApp extends StatelessWidget {
  const EduCardsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale?>(
      valueListenable: localeNotifier,
      builder: (context, locale, _) {
        return MaterialApp.router(
          title: 'EduCards',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.system,
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: _router,
        );
      },
    );
  }
}

class ScaffoldWithNavigation extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavigation({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.style_outlined),
            selectedIcon: const Icon(Icons.style),
            label: AppLocalizations.of(context).navDecks,
          ),
          NavigationDestination(
            icon: const Icon(Icons.today_outlined),
            selectedIcon: const Icon(Icons.today),
            label: AppLocalizations.of(context).navStudy,
          ),
          NavigationDestination(
            icon: const Icon(Icons.bar_chart_outlined),
            selectedIcon: const Icon(Icons.bar_chart),
            label: AppLocalizations.of(context).navProgress,
          ),
        ],
      ),
    );
  }
}
