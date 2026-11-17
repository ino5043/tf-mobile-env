import 'dart:typed_data';

import 'package:equatable/equatable.dart';

import '../../domain/entities/card_type.dart';

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
  final CardType cardType;
  final String metadata;

  const AddCard({
    required this.front,
    required this.back,
    this.cardType = CardType.basic,
    this.metadata = '',
  });

  @override
  List<Object?> get props => [front, back, cardType, metadata];
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
  final CardType cardType;

  const GenerateWithAI({
    required this.topic,
    required this.cardCount,
    required this.difficulty,
    this.cardType = CardType.basic,
  });

  @override
  List<Object?> get props => [topic, cardCount, difficulty, cardType];
}

class GenerateFromMedia extends DeckCreateEvent {
  final Uint8List fileBytes;
  final String fileName;
  final String mimeType;
  final int cardCount;
  final CardType cardType;

  const GenerateFromMedia({
    required this.fileBytes,
    required this.fileName,
    required this.mimeType,
    required this.cardCount,
    this.cardType = CardType.basic,
  });

  @override
  List<Object?> get props => [fileName, mimeType, cardCount, cardType];
}

class ImportFile extends DeckCreateEvent {
  const ImportFile();
}

class SubmitDeck extends DeckCreateEvent {
  const SubmitDeck();
}
