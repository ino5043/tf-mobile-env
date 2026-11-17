import 'package:equatable/equatable.dart';

import '../../../study/domain/entities/spaced_repetition_data.dart';
import 'card_type.dart';

/// A flashcard with a front (question) and back (answer).
/// Contains spaced repetition state for scheduling reviews.
///
/// [cardType] determines how the card is rendered and interacted with.
/// [metadata] holds type-specific data as a JSON string.
class Flashcard extends Equatable {
  final String id;
  final String deckId;
  final String front;
  final String back;
  final CardType cardType;
  final String metadata;
  final SpacedRepetitionData srData;
  final DateTime createdAt;

  const Flashcard({
    required this.id,
    required this.deckId,
    required this.front,
    required this.back,
    this.cardType = CardType.basic,
    this.metadata = '',
    required this.srData,
    required this.createdAt,
  });

  bool get isDue => srData.nextReviewDate.isBefore(DateTime.now());

  Flashcard copyWith({
    String? id,
    String? deckId,
    String? front,
    String? back,
    CardType? cardType,
    String? metadata,
    SpacedRepetitionData? srData,
    DateTime? createdAt,
  }) {
    return Flashcard(
      id: id ?? this.id,
      deckId: deckId ?? this.deckId,
      front: front ?? this.front,
      back: back ?? this.back,
      cardType: cardType ?? this.cardType,
      metadata: metadata ?? this.metadata,
      srData: srData ?? this.srData,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object> get props =>
      [id, deckId, front, back, cardType, metadata, srData, createdAt];
}
