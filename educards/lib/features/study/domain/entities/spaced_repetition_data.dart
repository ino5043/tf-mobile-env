import 'package:equatable/equatable.dart';

/// Mastery level derived from spaced repetition progress.
enum MasteryLevel { newCard, learning, review, mastered }

/// Value Object holding the SM-2 algorithm state for a flashcard.
/// Immutable — every review produces a new instance.
class SpacedRepetitionData extends Equatable {
  final double easeFactor;
  final int interval;
  final int repetitions;
  final DateTime nextReviewDate;
  final MasteryLevel mastery;

  const SpacedRepetitionData({
    required this.easeFactor,
    required this.interval,
    required this.repetitions,
    required this.nextReviewDate,
    required this.mastery,
  });

  /// Default state for a brand-new card.
  factory SpacedRepetitionData.initial() {
    return SpacedRepetitionData(
      easeFactor: 2.5,
      interval: 0,
      repetitions: 0,
      nextReviewDate: DateTime.now(),
      mastery: MasteryLevel.newCard,
    );
  }

  SpacedRepetitionData copyWith({
    double? easeFactor,
    int? interval,
    int? repetitions,
    DateTime? nextReviewDate,
    MasteryLevel? mastery,
  }) {
    return SpacedRepetitionData(
      easeFactor: easeFactor ?? this.easeFactor,
      interval: interval ?? this.interval,
      repetitions: repetitions ?? this.repetitions,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      mastery: mastery ?? this.mastery,
    );
  }

  @override
  List<Object> get props => [
        easeFactor,
        interval,
        repetitions,
        nextReviewDate,
        mastery,
      ];
}
