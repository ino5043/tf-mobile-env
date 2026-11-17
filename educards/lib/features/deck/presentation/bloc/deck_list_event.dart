import 'package:equatable/equatable.dart';

sealed class DeckListEvent extends Equatable {
  const DeckListEvent();

  @override
  List<Object?> get props => [];
}

class LoadDecks extends DeckListEvent {
  const LoadDecks();
}

class CreateDeckRequested extends DeckListEvent {
  final String title;
  final String description;
  final List<Map<String, String>> cards;

  const CreateDeckRequested({
    required this.title,
    required this.description,
    this.cards = const [],
  });

  @override
  List<Object?> get props => [title, description, cards];
}

class DeleteDeckRequested extends DeckListEvent {
  final String deckId;

  const DeleteDeckRequested(this.deckId);

  @override
  List<Object?> get props => [deckId];
}
