import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:educards/features/deck/domain/usecases/get_deck_usecase.dart';
import 'package:educards/features/settings/domain/entities/app_settings.dart';
import 'package:educards/features/settings/domain/repositories/settings_repository.dart';
import 'package:educards/features/study/presentation/bloc/listen_mode_bloc.dart';
import 'package:educards/features/study/presentation/bloc/listen_mode_event.dart';
import 'package:educards/features/study/presentation/bloc/listen_mode_state.dart';
import '../../../../fixtures/test_fixtures.dart';

class MockGetDeckUseCase extends Mock implements GetDeckUseCase {}

class MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  late MockGetDeckUseCase mockGetDeck;
  late MockSettingsRepository mockSettings;

  setUp(() {
    mockGetDeck = MockGetDeckUseCase();
    mockSettings = MockSettingsRepository();
  });

  setUpAll(() {
    registerFallbackValue('');
  });

  ListenModeBloc buildBloc() => ListenModeBloc(
        getDeck: mockGetDeck,
        settingsRepository: mockSettings,
      );

  final testDeck = TestFixtures.createDeck(
    cards: [
      TestFixtures.createFlashcard(id: 'c1', front: 'Q1', back: 'A1'),
      TestFixtures.createFlashcard(id: 'c2', front: 'Q2', back: 'A2'),
      TestFixtures.createFlashcard(id: 'c3', front: 'Q3', back: 'A3'),
    ],
  );

  void stubDeckAndSettings() {
    when(() => mockGetDeck(any())).thenAnswer((_) async => testDeck);
    when(() => mockSettings.getSettings())
        .thenAnswer((_) async => const AppSettings(ttsSpeed: 1.0));
  }

  group('StartListenMode', () {
    blocTest<ListenModeBloc, ListenModeState>(
      'emits [Loading, Active] with correct initial state',
      build: () {
        stubDeckAndSettings();
        return buildBloc();
      },
      act: (bloc) => bloc.add(const StartListenMode('deck-1')),
      expect: () => [
        const ListenModeLoading(),
        isA<ListenModeActive>()
            .having((s) => s.currentIndex, 'currentIndex', 0)
            .having((s) => s.isPlaying, 'isPlaying', true)
            .having((s) => s.isShowingFront, 'isShowingFront', true)
            .having((s) => s.speed, 'speed', 1.0)
            .having((s) => s.totalCards, 'totalCards', 3)
            .having((s) => s.deckTitle, 'deckTitle', 'IT Terminology'),
      ],
    );

    blocTest<ListenModeBloc, ListenModeState>(
      'emits [Loading, Error] when deck is null',
      build: () {
        when(() => mockGetDeck(any())).thenAnswer((_) async => null);
        when(() => mockSettings.getSettings())
            .thenAnswer((_) async => const AppSettings());
        return buildBloc();
      },
      act: (bloc) => bloc.add(const StartListenMode('bad-deck')),
      expect: () => [
        const ListenModeLoading(),
        const ListenModeError(ListenModeErrorType.deckEmpty),
      ],
    );

    blocTest<ListenModeBloc, ListenModeState>(
      'emits [Loading, Error] when deck has no cards',
      build: () {
        when(() => mockGetDeck(any()))
            .thenAnswer((_) async => TestFixtures.emptyDeck);
        when(() => mockSettings.getSettings())
            .thenAnswer((_) async => const AppSettings());
        return buildBloc();
      },
      act: (bloc) => bloc.add(const StartListenMode('deck-1')),
      expect: () => [
        const ListenModeLoading(),
        const ListenModeError(ListenModeErrorType.deckEmpty),
      ],
    );

    blocTest<ListenModeBloc, ListenModeState>(
      'uses ttsSpeed from settings',
      build: () {
        when(() => mockGetDeck(any())).thenAnswer((_) async => testDeck);
        when(() => mockSettings.getSettings())
            .thenAnswer((_) async => const AppSettings(ttsSpeed: 1.5));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const StartListenMode('deck-1')),
      expect: () => [
        const ListenModeLoading(),
        isA<ListenModeActive>().having((s) => s.speed, 'speed', 1.5),
      ],
    );
  });

  group('TogglePlayPause', () {
    blocTest<ListenModeBloc, ListenModeState>(
      'toggles playing to paused',
      build: () {
        stubDeckAndSettings();
        return buildBloc();
      },
      act: (bloc) async {
        bloc.add(const StartListenMode('deck-1'));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const TogglePlayPause());
      },
      skip: 2,
      expect: () => [
        isA<ListenModeActive>().having((s) => s.isPlaying, 'isPlaying', false),
      ],
    );

    blocTest<ListenModeBloc, ListenModeState>(
      'toggles paused to playing',
      build: () {
        stubDeckAndSettings();
        return buildBloc();
      },
      act: (bloc) async {
        bloc.add(const StartListenMode('deck-1'));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const TogglePlayPause());
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const TogglePlayPause());
      },
      skip: 3,
      expect: () => [
        isA<ListenModeActive>().having((s) => s.isPlaying, 'isPlaying', true),
      ],
    );
  });

  group('AdvancePhase', () {
    blocTest<ListenModeBloc, ListenModeState>(
      'advances from front to back on same card',
      build: () {
        stubDeckAndSettings();
        return buildBloc();
      },
      act: (bloc) async {
        bloc.add(const StartListenMode('deck-1'));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const AdvancePhase());
      },
      skip: 2,
      expect: () => [
        isA<ListenModeActive>()
            .having((s) => s.isShowingFront, 'isShowingFront', false)
            .having((s) => s.currentIndex, 'currentIndex', 0),
      ],
    );

    blocTest<ListenModeBloc, ListenModeState>(
      'advances from back to next card front',
      build: () {
        stubDeckAndSettings();
        return buildBloc();
      },
      act: (bloc) async {
        bloc.add(const StartListenMode('deck-1'));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const AdvancePhase()); // front→back
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const AdvancePhase()); // back→next front
      },
      skip: 3,
      expect: () => [
        isA<ListenModeActive>()
            .having((s) => s.isShowingFront, 'isShowingFront', true)
            .having((s) => s.currentIndex, 'currentIndex', 1),
      ],
    );

    blocTest<ListenModeBloc, ListenModeState>(
      'emits Complete after last card back',
      build: () {
        final singleCardDeck = TestFixtures.createDeck(
          cards: [TestFixtures.createFlashcard(id: 'c1')],
        );
        when(() => mockGetDeck(any())).thenAnswer((_) async => singleCardDeck);
        when(() => mockSettings.getSettings())
            .thenAnswer((_) async => const AppSettings());
        return buildBloc();
      },
      act: (bloc) async {
        bloc.add(const StartListenMode('deck-1'));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const AdvancePhase()); // front→back
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const AdvancePhase()); // back→complete
      },
      skip: 3,
      expect: () => [
        isA<ListenModeComplete>()
            .having((s) => s.totalCards, 'totalCards', 1)
            .having((s) => s.deckTitle, 'deckTitle', 'IT Terminology'),
      ],
    );

    blocTest<ListenModeBloc, ListenModeState>(
      'does nothing when paused',
      build: () {
        stubDeckAndSettings();
        return buildBloc();
      },
      act: (bloc) async {
        bloc.add(const StartListenMode('deck-1'));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const TogglePlayPause()); // pause
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const AdvancePhase()); // should be ignored
      },
      skip: 3,
      expect: () => <ListenModeState>[],
    );
  });

  group('SkipNext', () {
    blocTest<ListenModeBloc, ListenModeState>(
      'skips to next card',
      build: () {
        stubDeckAndSettings();
        return buildBloc();
      },
      act: (bloc) async {
        bloc.add(const StartListenMode('deck-1'));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const SkipNext());
      },
      skip: 2,
      expect: () => [
        isA<ListenModeActive>()
            .having((s) => s.currentIndex, 'currentIndex', 1)
            .having((s) => s.isShowingFront, 'isShowingFront', true),
      ],
    );

    blocTest<ListenModeBloc, ListenModeState>(
      'emits Complete when skipping past last card',
      build: () {
        final singleCardDeck = TestFixtures.createDeck(
          cards: [TestFixtures.createFlashcard(id: 'c1')],
        );
        when(() => mockGetDeck(any())).thenAnswer((_) async => singleCardDeck);
        when(() => mockSettings.getSettings())
            .thenAnswer((_) async => const AppSettings());
        return buildBloc();
      },
      act: (bloc) async {
        bloc.add(const StartListenMode('deck-1'));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const SkipNext());
      },
      skip: 2,
      expect: () => [
        isA<ListenModeComplete>(),
      ],
    );
  });

  group('SkipPrevious', () {
    blocTest<ListenModeBloc, ListenModeState>(
      'goes to previous card',
      build: () {
        stubDeckAndSettings();
        return buildBloc();
      },
      act: (bloc) async {
        bloc.add(const StartListenMode('deck-1'));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const SkipNext()); // go to card 2
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const SkipPrevious()); // back to card 1
      },
      skip: 3,
      expect: () => [
        isA<ListenModeActive>()
            .having((s) => s.currentIndex, 'currentIndex', 0)
            .having((s) => s.isShowingFront, 'isShowingFront', true),
      ],
    );

    blocTest<ListenModeBloc, ListenModeState>(
      'resets to front when already at first card',
      build: () {
        stubDeckAndSettings();
        return buildBloc();
      },
      act: (bloc) async {
        bloc.add(const StartListenMode('deck-1'));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const AdvancePhase()); // show back
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const SkipPrevious()); // should reset to front
      },
      skip: 3,
      expect: () => [
        isA<ListenModeActive>()
            .having((s) => s.currentIndex, 'currentIndex', 0)
            .having((s) => s.isShowingFront, 'isShowingFront', true),
      ],
    );
  });

  group('UpdateSpeed', () {
    blocTest<ListenModeBloc, ListenModeState>(
      'updates playback speed',
      build: () {
        stubDeckAndSettings();
        return buildBloc();
      },
      act: (bloc) async {
        bloc.add(const StartListenMode('deck-1'));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const UpdateSpeed(1.5));
      },
      skip: 2,
      expect: () => [
        isA<ListenModeActive>().having((s) => s.speed, 'speed', 1.5),
      ],
    );
  });

  group('Full playthrough', () {
    blocTest<ListenModeBloc, ListenModeState>(
      'plays through 2-card deck: front→back→front→back→complete',
      build: () {
        final twoDeck = TestFixtures.createDeck(
          cards: [
            TestFixtures.createFlashcard(id: 'c1', front: 'Q1', back: 'A1'),
            TestFixtures.createFlashcard(id: 'c2', front: 'Q2', back: 'A2'),
          ],
        );
        when(() => mockGetDeck(any())).thenAnswer((_) async => twoDeck);
        when(() => mockSettings.getSettings())
            .thenAnswer((_) async => const AppSettings());
        return buildBloc();
      },
      act: (bloc) async {
        bloc.add(const StartListenMode('deck-1'));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const AdvancePhase()); // card1 front→back
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const AdvancePhase()); // card1 back→card2 front
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const AdvancePhase()); // card2 front→back
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const AdvancePhase()); // card2 back→complete
      },
      skip: 2,
      expect: () => [
        // card1 back
        isA<ListenModeActive>()
            .having((s) => s.currentIndex, 'currentIndex', 0)
            .having((s) => s.isShowingFront, 'isShowingFront', false),
        // card2 front
        isA<ListenModeActive>()
            .having((s) => s.currentIndex, 'currentIndex', 1)
            .having((s) => s.isShowingFront, 'isShowingFront', true),
        // card2 back
        isA<ListenModeActive>()
            .having((s) => s.currentIndex, 'currentIndex', 1)
            .having((s) => s.isShowingFront, 'isShowingFront', false),
        // complete
        isA<ListenModeComplete>()
            .having((s) => s.totalCards, 'totalCards', 2),
      ],
    );
  });
}
