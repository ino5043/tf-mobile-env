import 'package:educards/features/deck/data/datasources/deck_local_datasource.dart';
import 'package:educards/features/deck/data/models/deck_model.dart';
import 'package:educards/features/deck/domain/entities/flashcard.dart';
import 'package:educards/features/progress/domain/repositories/progress_repository.dart';
import 'package:educards/features/study/domain/entities/review_rating.dart';
import 'package:educards/features/study/domain/repositories/study_repository.dart';
import 'package:educards/features/study/domain/usecases/calculate_next_review_usecase.dart';
import '../datasources/study_local_datasource.dart';
import '../models/study_record_model.dart';

class StudyRepositoryImpl implements StudyRepository {
  final StudyLocalDataSource studyDataSource;
  final DeckLocalDataSource deckDataSource;
  final ProgressRepository progressRepository;
  final CalculateNextReviewUseCase _calculateNextReview = CalculateNextReviewUseCase();

  StudyRepositoryImpl({
    required this.studyDataSource,
    required this.deckDataSource,
    required this.progressRepository,
  });

  @override
  Future<List<Flashcard>> getDueCards(String deckId) async {
    final deckModel = deckDataSource.getDeckById(deckId);
    if (deckModel == null) return [];

    final deck = deckModel.toEntity();
    return deck.cards.where((c) => c.isDue).toList();
  }

  @override
  Future<Flashcard> reviewCard({
    required String cardId,
    required String deckId,
    required ReviewRating rating,
  }) async {
    final deckModel = deckDataSource.getDeckById(deckId);
    if (deckModel == null) {
      throw Exception('Deck not found: $deckId');
    }

    final deck = deckModel.toEntity();
    final cardIndex = deck.cards.indexWhere((c) => c.id == cardId);
    if (cardIndex == -1) {
      throw Exception('Card not found: $cardId');
    }

    final card = deck.cards[cardIndex];
    final newSrData = _calculateNextReview(
      current: card.srData,
      rating: rating,
    );

    final updatedCard = card.copyWith(srData: newSrData);
    final updatedCards = List<Flashcard>.from(deck.cards);
    updatedCards[cardIndex] = updatedCard;

    final updatedDeck = deck.copyWith(
      cards: updatedCards,
      updatedAt: DateTime.now(),
    );
    await deckDataSource.saveDeck(DeckModel.fromEntity(updatedDeck));

    // Save study record
    await studyDataSource.saveStudyRecord(StudyRecordModel(
      cardId: cardId,
      deckId: deckId,
      ratingQuality: rating.quality,
      reviewedAt: DateTime.now(),
    ));

    // Update progress stats
    await progressRepository.recordStudy(
      date: DateTime.now(),
      wasCorrect: rating.quality >= 3,
    );

    return updatedCard;
  }
}
