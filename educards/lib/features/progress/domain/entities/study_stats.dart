import 'package:equatable/equatable.dart';

/// Value Object: daily study statistics.
class StudyStats extends Equatable {
  final DateTime date;
  final int cardsReviewed;
  final int correctCount;
  final int incorrectCount;

  const StudyStats({
    required this.date,
    required this.cardsReviewed,
    required this.correctCount,
    required this.incorrectCount,
  });

  factory StudyStats.empty(DateTime date) {
    return StudyStats(
      date: date,
      cardsReviewed: 0,
      correctCount: 0,
      incorrectCount: 0,
    );
  }

  double get accuracy =>
      cardsReviewed > 0 ? correctCount / cardsReviewed : 0;

  @override
  List<Object> get props => [date, cardsReviewed, correctCount, incorrectCount];
}
