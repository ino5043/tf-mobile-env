import 'package:equatable/equatable.dart';

sealed class DeckCreateEvent extends Equatable {
  const DeckCreateEvent();

  @override
  List<Object?> get props => [];
}

class UpdateTitle extends DeckCreateEvent {
  final String title;

  const UpdateTitle(this.title);

  @override
  List<Object?> get props => [title];
}

class UpdateDescription extends DeckCreateEvent {
  final String description;

  const UpdateDescription(this.description);

  @override
  List<Object?> get props => [description];
}

class AddCard extends DeckCreateEvent {
  final String front;
  final String back;

  const AddCard({required this.front, required this.back});

  @override
  List<Object?> get props => [front, back];
}

class RemoveCard extends DeckCreateEvent {
  final int index;

  const RemoveCard(this.index);

  @override
  List<Object?> get props => [index];
}

class ImportCards extends DeckCreateEvent {
  final List<Map<String, String>> cards;

  const ImportCards(this.cards);

  @override
  List<Object?> get props => [cards];
}

class GenerateWithAI extends DeckCreateEvent {
  final String topic;
  final int cardCount;
  final String difficulty;

  const GenerateWithAI({
    required this.topic,
    required this.cardCount,
    required this.difficulty,
  });

  @override
  List<Object?> get props => [topic, cardCount, difficulty];
}

class ImportFile extends DeckCreateEvent {
  const ImportFile();
}

class SubmitDeck extends DeckCreateEvent {
  const SubmitDeck();
}
