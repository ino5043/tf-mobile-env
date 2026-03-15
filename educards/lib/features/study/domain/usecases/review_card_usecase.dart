import 'package:equatable/equatable.dart';

import 'package:educards/core/usecases/usecase.dart';
import '../../../deck/domain/entities/flashcard.dart';
import '../entities/review_rating.dart';
import '../repositories/study_repository.dart';

class ReviewCardParams extends Equatable {
  final String cardId;
  final String deckId;
  final ReviewRating rating;

  const ReviewCardParams({
    required this.cardId,
    required this.deckId,
    required this.rating,
  });

  @override
  List<Object> get props => [cardId, deckId, rating];
}

class ReviewCardUseCase extends UseCase<Flashcard, ReviewCardParams> {
  final StudyRepository repository;

  ReviewCardUseCase(this.repository);

  @override
  Future<Flashcard> call(ReviewCardParams params) {
    return repository.reviewCard(
      cardId: params.cardId,
      deckId: params.deckId,
      rating: params.rating,
    );
  }
}
