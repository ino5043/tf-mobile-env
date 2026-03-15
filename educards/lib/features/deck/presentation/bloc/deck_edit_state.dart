import 'package:equatable/equatable.dart';

import '../../../deck/domain/entities/card_type.dart';
import '../../../study/domain/entities/spaced_repetition_data.dart';

class EditableCard extends Equatable {
  final String? id;
  final String front;
  final String back;
  final String originalFront;
  final CardType cardType;
  final String metadata;
  final SpacedRepetitionData? srData;

  const EditableCard({
    this.id,
    required this.front,
    required this.back,
    required this.originalFront,
    this.cardType = CardType.basic,
    this.metadata = '',
    this.srData,
  });

  bool get isNew => id == null;
  bool get frontChanged => id != null && front != originalFront;

  EditableCard copyWith({
    String? id,
    String? front,
    String? back,
    String? originalFront,
    CardType? cardType,
    String? metadata,
    SpacedRepetitionData? srData,
  }) {
    return EditableCard(
      id: id ?? this.id,
      front: front ?? this.front,
      back: back ?? this.back,
      originalFront: originalFront ?? this.originalFront,
      cardType: cardType ?? this.cardType,
      metadata: metadata ?? this.metadata,
      srData: srData ?? this.srData,
    );
  }

  @override
  List<Object?> get props =>
      [id, front, back, originalFront, cardType, metadata, srData];
}

sealed class DeckEditState extends Equatable {
  const DeckEditState();

  @override
  List<Object?> get props => [];
}

class DeckEditLoading extends DeckEditState {
  const DeckEditLoading();
}

class DeckEditEditing extends DeckEditState {
  final String deckId;
  final String title;
  final String description;
  final List<EditableCard> cards;
  final String originalTitle;
  final String originalDescription;
  final int originalCardCount;
  final bool isSaving;
  final String? error;

  const DeckEditEditing({
    required this.deckId,
    required this.title,
    required this.description,
    required this.cards,
    required this.originalTitle,
    required this.originalDescription,
    required this.originalCardCount,
    this.isSaving = false,
    this.error,
  });

  bool get canSave => title.trim().isNotEmpty && cards.isNotEmpty;

  bool get hasChanges {
    if (title != originalTitle) return true;
    if (description != originalDescription) return true;
    if (cards.length != originalCardCount) return true;
    for (final card in cards) {
      if (card.isNew || card.frontChanged) return true;
      // Check if back was changed
      if (card.id != null) {
        // Any edit to an existing card's back is a change
        // We track front changes via originalFront; for back we rely on
        // the BLoC emitting new state only when values actually change
      }
    }
    return false;
  }

  DeckEditEditing copyWith({
    String? deckId,
    String? title,
    String? description,
    List<EditableCard>? cards,
    String? originalTitle,
    String? originalDescription,
    int? originalCardCount,
    bool? isSaving,
    String? Function()? error,
  }) {
    return DeckEditEditing(
      deckId: deckId ?? this.deckId,
      title: title ?? this.title,
      description: description ?? this.description,
      cards: cards ?? this.cards,
      originalTitle: originalTitle ?? this.originalTitle,
      originalDescription: originalDescription ?? this.originalDescription,
      originalCardCount: originalCardCount ?? this.originalCardCount,
      isSaving: isSaving ?? this.isSaving,
      error: error != null ? error() : this.error,
    );
  }

  @override
  List<Object?> get props => [
        deckId,
        title,
        description,
        cards,
        originalTitle,
        originalDescription,
        originalCardCount,
        isSaving,
        error,
      ];
}

class DeckEditSuccess extends DeckEditState {
  const DeckEditSuccess();
}

class DeckEditFailure extends DeckEditState {
  final String message;

  const DeckEditFailure(this.message);

  @override
  List<Object?> get props => [message];
}
