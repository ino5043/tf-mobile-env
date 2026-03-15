import 'package:equatable/equatable.dart';

sealed class DeckDetailEvent extends Equatable {
  const DeckDetailEvent();

  @override
  List<Object> get props => [];
}

class LoadDeckDetail extends DeckDetailEvent {
  final String deckId;

  const LoadDeckDetail(this.deckId);

  @override
  List<Object> get props => [deckId];
}

class ExportDeck extends DeckDetailEvent {
  const ExportDeck();
}
