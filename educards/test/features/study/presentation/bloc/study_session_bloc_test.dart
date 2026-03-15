import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:educards/features/study/domain/entities/review_rating.dart';
import 'package:educards/features/study/domain/usecases/get_due_cards_usecase.dart';
import 'package:educards/features/study/domain/usecases/review_card_usecase.dart';
import 'package:educards/features/study/presentation/bloc/study_session_bloc.dart';
import 'package:educards/features/study/presentation/bloc/study_session_event.dart';
import 'package:educards/features/study/presentation/bloc/study_session_state.dart';
import '../../../../fixtures/test_fixtures.dart';

class MockGetDueCardsUseCase extends Mock implements GetDueCardsUseCase {}
class MockReviewCardUseCase extends Mock implements ReviewCardUseCase {}

void main() {
  late MockGetDueCardsUseCase mockGetDueCards;
  late MockReviewCardUseCase mockReviewCard;

  setUp(() {
    mockGetDueCards = MockGetDueCardsUseCase();
    mockReviewCard = MockReviewCardUseCase();
  });

  setUpAll(() {
    registerFallbackValue(const ReviewCardParams(
      cardId: '',
      deckId: '',
      rating: ReviewRating.good,
    ));
  });

  StudySessionBloc buildBloc() => StudySessionBloc(
    getDueCards: mockGetDueCards,
    reviewCard: mockReviewCard,
  );

  group('StudySessionBloc', () {
    final testCards = [
      TestFixtures.dueFlashcard,
      TestFixtures.createFlashcard(
        id: 'card-2',
        front: 'What is Dart?',
        back: 'A programming language.',
        srData: TestFixtures.learningSrData,
      ),
    ];

    blocTest<StudySessionBloc, StudySessionState>(
      'emits [Loading, CardPresented] when StartStudySession has due cards',
      build: () {
        when(() => mockGetDueCards(any())).thenAnswer((_) async => testCards);
        return buildBloc();
      },
      act: (bloc) => bloc.add(const StartStudySession('deck-1')),
      expect: () => [
        const StudySessionLoading(),
        isA<CardPresented>()
            .having((s) => s.currentIndex, 'currentIndex', 0)
            .having((s) => s.totalCards, 'totalCards', 2)
            .having((s) => s.isFlipped, 'isFlipped', false),
      ],
    );

    blocTest<StudySessionBloc, StudySessionState>(
      'emits [Loading, Empty] when StartStudySession has no due cards',
      build: () {
        when(() => mockGetDueCards(any())).thenAnswer((_) async => []);
        return buildBloc();
      },
      act: (bloc) => bloc.add(const StartStudySession('deck-1')),
      expect: () => [
        const StudySessionLoading(),
        const StudySessionEmpty(),
      ],
    );

    blocTest<StudySessionBloc, StudySessionState>(
      'emits [CardPresented(flipped)] when FlipCard is dispatched',
      build: () {
        when(() => mockGetDueCards(any())).thenAnswer((_) async => testCards);
        return buildBloc();
      },
      act: (bloc) async {
        bloc.add(const StartStudySession('deck-1'));
        await Future.delayed(const Duration(milliseconds: 100));
        bloc.add(const FlipCard());
      },
      skip: 2, // skip Loading and first CardPresented
      expect: () => [
        isA<CardPresented>().having((s) => s.isFlipped, 'isFlipped', true),
      ],
    );
  });
}
