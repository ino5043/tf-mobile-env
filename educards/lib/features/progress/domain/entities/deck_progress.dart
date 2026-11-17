import 'package:equatable/equatable.dart';

/// Progress statistics for a single deck.
class DeckProgress extends Equatable {
  final String deckId;
  final String deckTitle;
  final int totalCards;
  final int masteredCount;
  final int reviewCount;
  final int learningCount;
  final int newCount;
  final int dueCount;

  const DeckProgress({
    required this.deckId,
    required this.deckTitle,
    required this.totalCards,
    required this.masteredCount,
    required this.reviewCount,
    required this.learningCount,
    required this.newCount,
    required this.dueCount,
  });

  double get masteryPercentage {
    if (totalCards == 0) return 0;
    return (masteredCount + reviewCount) / totalCards;
  }

  @override
  List<Object> get props => [
        deckId,
        deckTitle,
        totalCards,
        masteredCount,
        reviewCount,
        learningCount,
        newCount,
        dueCount,
      ];
}
