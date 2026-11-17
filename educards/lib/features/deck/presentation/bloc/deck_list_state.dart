import 'package:equatable/equatable.dart';

import '../../domain/entities/deck.dart';

sealed class DeckListState extends Equatable {
  const DeckListState();

  @override
  List<Object?> get props => [];
}

class DeckListInitial extends DeckListState {
  const DeckListInitial();
}

class DeckListLoading extends DeckListState {
  const DeckListLoading();
}

class DeckListLoaded extends DeckListState {
  final List<Deck> decks;

  const DeckListLoaded(this.decks);

  @override
  List<Object?> get props => [decks];
}

class DeckListError extends DeckListState {
  final String message;

  const DeckListError(this.message);

  @override
  List<Object?> get props => [message];
}
