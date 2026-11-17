import 'package:equatable/equatable.dart';

import 'package:educards/features/study/domain/entities/spaced_repetition_data.dart';
import 'flashcard.dart';

/// A deck of flashcards. Aggregate root in the Deck bounded context.
class Deck extends Equatable {
  final String id;
  final String title;
  final String description;
  final List<Flashcard> cards;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Deck({
    required this.id,
    required this.title,
    required this.description,
    required this.cards,
    required this.createdAt,
    required this.updatedAt,
  });

  int get totalCards => cards.length;

  int get dueCards => cards.where((c) => c.isDue).length;

  double get masteryPercentage {
    if (cards.isEmpty) return 0;
    final masteredCount = cards
        .where((c) =>
            c.srData.mastery == MasteryLevel.mastered ||
            c.srData.mastery == MasteryLevel.review)
        .length;
    return masteredCount / cards.length;
  }

  Deck copyWith({
    String? id,
    String? title,
    String? description,
    List<Flashcard>? cards,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Deck(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      cards: cards ?? this.cards,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object> get props => [id, title, description, cards, createdAt, updatedAt];
}
