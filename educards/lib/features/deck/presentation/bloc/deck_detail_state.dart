import 'package:equatable/equatable.dart';

import '../../domain/entities/deck.dart';

sealed class DeckDetailState extends Equatable {
  const DeckDetailState();

  @override
  List<Object?> get props => [];
}

class DeckDetailLoading extends DeckDetailState {
  const DeckDetailLoading();
}

class DeckDetailLoaded extends DeckDetailState {
  final Deck deck;
  final String? exportedJson;

  const DeckDetailLoaded({required this.deck, this.exportedJson});

  DeckDetailLoaded copyWith({Deck? deck, String? Function()? exportedJson}) {
    return DeckDetailLoaded(
      deck: deck ?? this.deck,
      exportedJson: exportedJson != null ? exportedJson() : this.exportedJson,
    );
  }

  @override
  List<Object?> get props => [deck, exportedJson];
}

class DeckDetailError extends DeckDetailState {
  final String message;

  const DeckDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
