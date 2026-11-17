import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:educards/core/usecases/usecase.dart';
import 'package:educards/features/deck/domain/usecases/create_deck_usecase.dart';
import 'package:educards/features/deck/domain/usecases/delete_deck_usecase.dart';
import 'package:educards/features/deck/domain/usecases/get_all_decks_usecase.dart';
import 'package:educards/features/deck/presentation/bloc/deck_list_bloc.dart';
import 'package:educards/features/deck/presentation/bloc/deck_list_event.dart';
import 'package:educards/features/deck/presentation/bloc/deck_list_state.dart';
import '../../../../fixtures/test_fixtures.dart';

class MockGetAllDecksUseCase extends Mock implements GetAllDecksUseCase {}
class MockCreateDeckUseCase extends Mock implements CreateDeckUseCase {}
class MockDeleteDeckUseCase extends Mock implements DeleteDeckUseCase {}

void main() {
  late MockGetAllDecksUseCase mockGetAllDecks;
  late MockCreateDeckUseCase mockCreateDeck;
  late MockDeleteDeckUseCase mockDeleteDeck;

  setUp(() {
    mockGetAllDecks = MockGetAllDecksUseCase();
    mockCreateDeck = MockCreateDeckUseCase();
    mockDeleteDeck = MockDeleteDeckUseCase();
  });

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(const CreateDeckParams(title: '', description: ''));
  });

  DeckListBloc buildBloc() => DeckListBloc(
    getAllDecks: mockGetAllDecks,
    createDeck: mockCreateDeck,
    deleteDeck: mockDeleteDeck,
  );

  group('DeckListBloc', () {
    final testDecks = [TestFixtures.createDeck()];

    blocTest<DeckListBloc, DeckListState>(
      'emits [Loading, Loaded] when LoadDecks succeeds',
      build: () {
        when(() => mockGetAllDecks(any())).thenAnswer((_) async => testDecks);
        return buildBloc();
      },
      act: (bloc) => bloc.add(const LoadDecks()),
      expect: () => [
        const DeckListLoading(),
        DeckListLoaded(testDecks),
      ],
    );

    blocTest<DeckListBloc, DeckListState>(
      'emits [Loading, Error] when LoadDecks fails',
      build: () {
        when(() => mockGetAllDecks(any())).thenThrow(Exception('DB error'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const LoadDecks()),
      expect: () => [
        const DeckListLoading(),
        isA<DeckListError>(),
      ],
    );

    blocTest<DeckListBloc, DeckListState>(
      'emits [Loading, Loaded] when CreateDeckRequested succeeds',
      build: () {
        when(() => mockCreateDeck(any()))
            .thenAnswer((_) async => TestFixtures.createDeck());
        when(() => mockGetAllDecks(any())).thenAnswer((_) async => testDecks);
        return buildBloc();
      },
      act: (bloc) => bloc.add(const CreateDeckRequested(
        title: 'New Deck',
        description: 'Desc',
      )),
      expect: () => [
        const DeckListLoading(),
        DeckListLoaded(testDecks),
      ],
    );

    blocTest<DeckListBloc, DeckListState>(
      'emits [Loading, Loaded] when DeleteDeckRequested succeeds',
      build: () {
        when(() => mockDeleteDeck(any())).thenAnswer((_) async {});
        when(() => mockGetAllDecks(any())).thenAnswer((_) async => []);
        return buildBloc();
      },
      act: (bloc) => bloc.add(const DeleteDeckRequested('deck-1')),
      expect: () => [
        const DeckListLoading(),
        const DeckListLoaded([]),
      ],
    );
  });
}
