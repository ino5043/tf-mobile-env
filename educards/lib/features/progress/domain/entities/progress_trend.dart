import 'package:equatable/equatable.dart';

import 'study_stats.dart';

/// Represents study trend data over a period of days.
class ProgressTrend extends Equatable {
  final List<StudyStats> dailyStats;

  const ProgressTrend({required this.dailyStats});

  int get totalCardsReviewed =>
      dailyStats.fold(0, (sum, s) => sum + s.cardsReviewed);

  int get totalCorrect =>
      dailyStats.fold(0, (sum, s) => sum + s.correctCount);

  double get averageAccuracy {
    if (totalCardsReviewed == 0) return 0;
    return totalCorrect / totalCardsReviewed;
  }

  @override
  List<Object> get props => [dailyStats];
}
