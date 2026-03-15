import '../../../deck/domain/entities/flashcard.dart';
import '../entities/review_rating.dart';

/// Repository interface for study session persistence.
abstract class StudyRepository {
  Future<List<Flashcard>> getDueCards(String deckId);
  Future<Flashcard> reviewCard({
    required String cardId,
    required String deckId,
    required ReviewRating rating,
  });
}
