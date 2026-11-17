import 'package:equatable/equatable.dart';

import '../../../deck/domain/entities/card_type.dart';

class CardEntry extends Equatable {
  final String front;
  final String back;
  final CardType cardType;
  final String metadata;

  const CardEntry({
    required this.front,
    required this.back,
    this.cardType = CardType.basic,
    this.metadata = '',
  });

  @override
  List<Object> get props => [front, back, cardType, metadata];
}

sealed class DeckCreateState extends Equatable {
  const DeckCreateState();

  @override
  List<Object?> get props => [];
}

class DeckCreateEditing extends DeckCreateState {
  final String title;
  final String description;
  final List<CardEntry> cards;
  final bool isGenerating;
  final String? error;

  const DeckCreateEditing({
    this.title = '',
    this.description = '',
    this.cards = const [],
    this.isGenerating = false,
    this.error,
  });

  bool get canSubmit => title.trim().isNotEmpty && cards.isNotEmpty;

  DeckCreateEditing copyWith({
    String? title,
    String? description,
    List<CardEntry>? cards,
    bool? isGenerating,
    String? Function()? error,
  }) {
    return DeckCreateEditing(
      title: title ?? this.title,
      description: description ?? this.description,
      cards: cards ?? this.cards,
      isGenerating: isGenerating ?? this.isGenerating,
      error: error != null ? error() : this.error,
    );
  }

  @override
  List<Object?> get props => [title, description, cards, isGenerating, error];
}

class DeckCreateSuccess extends DeckCreateState {
  const DeckCreateSuccess();
}

class DeckCreateFailure extends DeckCreateState {
  final String message;

  const DeckCreateFailure(this.message);

  @override
  List<Object?> get props => [message];
}
