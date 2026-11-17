import 'dart:math';

import '../entities/review_rating.dart';
import '../entities/spaced_repetition_data.dart';

/// Pure function implementing the SM-2 spaced repetition algorithm.
/// No external dependencies — ideal for TDD.
///
/// Algorithm:
/// - If rating is "Again" (quality < 3): reset repetitions, review in 10 min
/// - If rating is "Hard/Good/Easy" (quality >= 3):
///   - Adjust ease factor: EF' = EF + (0.1 - (5-q)*(0.08+(5-q)*0.02))
///   - Clamp ease factor minimum at 1.3
///   - Calculate interval: rep 0 -> 1 day, rep 1 -> 6 days, rep N -> prev * EF
class CalculateNextReviewUseCase {
  SpacedRepetitionData call({
    required SpacedRepetitionData current,
    required ReviewRating rating,
    DateTime? now,
  }) {
    final currentTime = now ?? DateTime.now();

    if (rating == ReviewRating.again) {
      return SpacedRepetitionData(
        easeFactor: max(1.3, current.easeFactor - 0.2),
        interval: 0,
        repetitions: 0,
        nextReviewDate: currentTime.add(const Duration(minutes: 10)),
        mastery: MasteryLevel.learning,
      );
    }

    final q = rating.quality;
    final newEaseFactor = max(
      1.3,
      current.easeFactor + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02)),
    );

    int newInterval;
    final newRepetitions = current.repetitions + 1;

    if (current.repetitions == 0) {
      newInterval = 1;
    } else if (current.repetitions == 1) {
      newInterval = 6;
    } else {
      newInterval = (current.interval * newEaseFactor).round();
    }

    return SpacedRepetitionData(
      easeFactor: newEaseFactor,
      interval: newInterval,
      repetitions: newRepetitions,
      nextReviewDate: currentTime.add(Duration(days: newInterval)),
      mastery: _calculateMastery(newRepetitions, newEaseFactor),
    );
  }

  MasteryLevel _calculateMastery(int repetitions, double easeFactor) {
    if (repetitions == 0) return MasteryLevel.newCard;
    if (repetitions <= 2) return MasteryLevel.learning;
    if (repetitions <= 5 || easeFactor < 2.0) return MasteryLevel.review;
    return MasteryLevel.mastered;
  }
}
