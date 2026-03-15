import 'package:educards/core/usecases/usecase.dart';
import 'package:educards/features/deck/domain/entities/flashcard.dart';
import 'package:educards/features/deck/domain/repositories/deck_repository.dart';
import 'package:educards/features/settings/domain/repositories/settings_repository.dart';
import 'package:educards/features/study/domain/entities/spaced_repetition_data.dart';
import '../entities/study_queue.dart';

class GetStudyQueueUseCase extends UseCase<StudyQueue, NoParams> {
  final DeckRepository deckRepository;
  final SettingsRepository settingsRepository;

  GetStudyQueueUseCase({
    required this.deckRepository,
    required this.settingsRepository,
  });

  @override
  Future<StudyQueue> call(NoParams params) async {
    final settings = await settingsRepository.getSettings();
    final decks = await deckRepository.getAllDecks();

    final allCards = decks.expand((d) => d.cards).toList();
    final now = DateTime.now();

    // Separate new cards and review cards
    final newCards = <Flashcard>[];
    final reviewCards = <Flashcard>[];

    for (final card in allCards) {
      if (card.srData.mastery == MasteryLevel.newCard &&
          card.srData.repetitions == 0) {
        newCards.add(card);
      } else if (card.srData.nextReviewDate.isBefore(now) ||
          card.srData.nextReviewDate.isAtSameMomentAs(now)) {
        reviewCards.add(card);
      }
    }

    // Sort review cards by nextReviewDate (oldest first)
    reviewCards.sort(
        (a, b) => a.srData.nextReviewDate.compareTo(b.srData.nextReviewDate));

    // Apply daily limits
    final limitedNew = newCards.take(settings.dailyNewCardLimit).toList();
    final limitedReview =
        reviewCards.take(settings.dailyReviewCardLimit).toList();

    return StudyQueue(
      newCards: limitedNew,
      reviewCards: limitedReview,
      remainingNew:
          (newCards.length - limitedNew.length).clamp(0, newCards.length),
      remainingReview: (reviewCards.length - limitedReview.length)
          .clamp(0, reviewCards.length),
    );
  }
}
