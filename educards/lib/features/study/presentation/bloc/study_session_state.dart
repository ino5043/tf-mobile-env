import 'package:equatable/equatable.dart';

import 'package:educards/features/deck/domain/entities/flashcard.dart';

sealed class StudySessionState extends Equatable {
  const StudySessionState();

  @override
  List<Object?> get props => [];
}

class StudySessionInitial extends StudySessionState {
  const StudySessionInitial();
}

class StudySessionLoading extends StudySessionState {
  const StudySessionLoading();
}

class CardPresented extends StudySessionState {
  final Flashcard card;
  final int currentIndex;
  final int totalCards;
  final bool isFlipped;

  const CardPresented({
    required this.card,
    required this.currentIndex,
    required this.totalCards,
    this.isFlipped = false,
  });

  CardPresented copyWith({bool? isFlipped}) {
    return CardPresented(
      card: card,
      currentIndex: currentIndex,
      totalCards: totalCards,
      isFlipped: isFlipped ?? this.isFlipped,
    );
  }

  @override
  List<Object?> get props => [card, currentIndex, totalCards, isFlipped];
}

class StudySessionComplete extends StudySessionState {
  final int cardsReviewed;
  final int correctCount;

  const StudySessionComplete({
    required this.cardsReviewed,
    required this.correctCount,
  });

  @override
  List<Object?> get props => [cardsReviewed, correctCount];
}

class StudySessionEmpty extends StudySessionState {
  const StudySessionEmpty();
}

class StudySessionError extends StudySessionState {
  final String message;

  const StudySessionError(this.message);

  @override
  List<Object?> get props => [message];
}
