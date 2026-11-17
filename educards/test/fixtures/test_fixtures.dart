import 'package:educards/features/deck/domain/entities/deck.dart';
import 'package:educards/features/deck/domain/entities/flashcard.dart';
import 'package:educards/features/study/domain/entities/spaced_repetition_data.dart';
import 'package:educards/features/progress/domain/entities/study_stats.dart';
import 'package:educards/features/progress/domain/entities/streak_info.dart';

class TestFixtures {
  static final fixedDate = DateTime(2026, 3, 15, 10, 0);

  // isDue は実行時の現在時刻と比べるため、「まだ来ていない復習日」は固定日ではなく
  // 現在時刻から見た未来にする。等価テストが壊れないよう、値は実行ごとに 1 回だけ決める。
  static final futureReviewDate = DateTime.now().add(const Duration(days: 10));

  static SpacedRepetitionData get initialSrData => SpacedRepetitionData(
    easeFactor: 2.5,
    interval: 0,
    repetitions: 0,
    nextReviewDate: fixedDate,
    mastery: MasteryLevel.newCard,
  );

  static SpacedRepetitionData get learningSrData => SpacedRepetitionData(
    easeFactor: 2.5,
    interval: 1,
    repetitions: 1,
    nextReviewDate: fixedDate.subtract(const Duration(hours: 1)),
    mastery: MasteryLevel.learning,
  );

  static SpacedRepetitionData get reviewSrData => SpacedRepetitionData(
    easeFactor: 2.5,
    interval: 6,
    repetitions: 3,
    nextReviewDate: fixedDate.subtract(const Duration(hours: 1)),
    mastery: MasteryLevel.review,
  );

  static SpacedRepetitionData get masteredSrData => SpacedRepetitionData(
    easeFactor: 2.7,
    interval: 30,
    repetitions: 8,
    nextReviewDate: futureReviewDate,
    mastery: MasteryLevel.mastered,
  );

  static Flashcard createFlashcard({
    String id = 'card-1',
    String deckId = 'deck-1',
    String front = 'What is Flutter?',
    String back = 'A UI toolkit for building natively compiled applications.',
    SpacedRepetitionData? srData,
    DateTime? createdAt,
  }) {
    return Flashcard(
      id: id,
      deckId: deckId,
      front: front,
      back: back,
      srData: srData ?? initialSrData,
      createdAt: createdAt ?? fixedDate,
    );
  }

  static Flashcard get dueFlashcard => createFlashcard(
    srData: learningSrData,
  );

  static Flashcard get notDueFlashcard => createFlashcard(
    srData: masteredSrData,
  );

  static Deck createDeck({
    String id = 'deck-1',
    String title = 'IT Terminology',
    String description = 'Basic IT terms for beginners',
    List<Flashcard>? cards,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Deck(
      id: id,
      title: title,
      description: description,
      cards: cards ?? [dueFlashcard, notDueFlashcard],
      createdAt: createdAt ?? fixedDate,
      updatedAt: updatedAt ?? fixedDate,
    );
  }

  static Deck get emptyDeck => createDeck(cards: []);

  static StudyStats createStudyStats({
    DateTime? date,
    int cardsReviewed = 10,
    int correctCount = 8,
    int incorrectCount = 2,
  }) {
    return StudyStats(
      date: date ?? fixedDate,
      cardsReviewed: cardsReviewed,
      correctCount: correctCount,
      incorrectCount: incorrectCount,
    );
  }

  static StreakInfo createStreakInfo({
    int currentStreak = 5,
    int longestStreak = 10,
    DateTime? lastStudyDate,
  }) {
    return StreakInfo(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      lastStudyDate: lastStudyDate ?? DateTime.now(),
    );
  }
}
