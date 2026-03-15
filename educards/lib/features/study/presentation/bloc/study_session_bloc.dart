import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:educards/features/deck/domain/entities/flashcard.dart';
import 'package:educards/features/study/domain/entities/review_rating.dart';
import '../../domain/usecases/get_due_cards_usecase.dart';
import '../../domain/usecases/review_card_usecase.dart';
import 'study_session_event.dart';
import 'study_session_state.dart';

class StudySessionBloc extends Bloc<StudySessionEvent, StudySessionState> {
  final GetDueCardsUseCase getDueCards;
  final ReviewCardUseCase reviewCard;

  List<Flashcard> _cards = [];
  int _currentIndex = 0;
  int _correctCount = 0;
  String _deckId = '';

  StudySessionBloc({
    required this.getDueCards,
    required this.reviewCard,
  }) : super(const StudySessionInitial()) {
    on<StartStudySession>(_onStartSession);
    on<FlipCard>(_onFlipCard);
    on<RateCard>(_onRateCard);
  }

  Future<void> _onStartSession(
    StartStudySession event,
    Emitter<StudySessionState> emit,
  ) async {
    emit(const StudySessionLoading());
    try {
      _deckId = event.deckId;
      _cards = await getDueCards(event.deckId);
      _currentIndex = 0;
      _correctCount = 0;

      if (_cards.isEmpty) {
        emit(const StudySessionEmpty());
      } else {
        emit(CardPresented(
          card: _cards[0],
          currentIndex: 0,
          totalCards: _cards.length,
        ));
      }
    } catch (e) {
      emit(StudySessionError(e.toString()));
    }
  }

  void _onFlipCard(
    FlipCard event,
    Emitter<StudySessionState> emit,
  ) {
    final currentState = state;
    if (currentState is CardPresented && !currentState.isFlipped) {
      emit(currentState.copyWith(isFlipped: true));
    }
  }

  Future<void> _onRateCard(
    RateCard event,
    Emitter<StudySessionState> emit,
  ) async {
    try {
      final card = _cards[_currentIndex];
      await reviewCard(ReviewCardParams(
        cardId: card.id,
        deckId: _deckId,
        rating: event.rating,
      ));

      if (event.rating != ReviewRating.again) {
        _correctCount++;
      }

      _currentIndex++;

      if (_currentIndex >= _cards.length) {
        emit(StudySessionComplete(
          cardsReviewed: _cards.length,
          correctCount: _correctCount,
        ));
      } else {
        emit(CardPresented(
          card: _cards[_currentIndex],
          currentIndex: _currentIndex,
          totalCards: _cards.length,
        ));
      }
    } catch (e) {
      emit(StudySessionError(e.toString()));
    }
  }
}
