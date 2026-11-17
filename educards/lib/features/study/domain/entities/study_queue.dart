import 'package:equatable/equatable.dart';

import 'package:educards/features/deck/domain/entities/flashcard.dart';

/// Represents today's study queue with daily limits applied.
class StudyQueue extends Equatable {
  final List<Flashcard> newCards;
  final List<Flashcard> reviewCards;
  final int remainingNew;
  final int remainingReview;

  const StudyQueue({
    required this.newCards,
    required this.reviewCards,
    required this.remainingNew,
    required this.remainingReview,
  });

  int get totalCards => newCards.length + reviewCards.length;
  bool get isEmpty => totalCards == 0;
  bool get hasOverflow => remainingNew > 0 || remainingReview > 0;

  List<Flashcard> get allCards => [...newCards, ...reviewCards];

  @override
  List<Object> get props => [newCards, reviewCards, remainingNew, remainingReview];
}
