import 'package:equatable/equatable.dart';

import 'package:educards/features/study/domain/entities/review_rating.dart';

sealed class StudySessionEvent extends Equatable {
  const StudySessionEvent();

  @override
  List<Object?> get props => [];
}

class StartStudySession extends StudySessionEvent {
  final String deckId;

  const StartStudySession(this.deckId);

  @override
  List<Object?> get props => [deckId];
}

class FlipCard extends StudySessionEvent {
  const FlipCard();
}

class RateCard extends StudySessionEvent {
  final ReviewRating rating;

  const RateCard(this.rating);

  @override
  List<Object?> get props => [rating];
}
