import 'package:equatable/equatable.dart';

sealed class DeckEditEvent extends Equatable {
  const DeckEditEvent();

  @override
  List<Object> get props => [];
}

class LoadDeckForEdit extends DeckEditEvent {
  final String deckId;

  const LoadDeckForEdit(this.deckId);

  @override
  List<Object> get props => [deckId];
}

class UpdateEditTitle extends DeckEditEvent {
  final String title;

  const UpdateEditTitle(this.title);

  @override
  List<Object> get props => [title];
}

class UpdateEditDescription extends DeckEditEvent {
  final String description;

  const UpdateEditDescription(this.description);

  @override
  List<Object> get props => [description];
}

class AddEditCard extends DeckEditEvent {
  final String front;
  final String back;

  const AddEditCard({required this.front, required this.back});

  @override
  List<Object> get props => [front, back];
}

class UpdateEditCard extends DeckEditEvent {
  final int index;
  final String front;
  final String back;

  const UpdateEditCard({
    required this.index,
    required this.front,
    required this.back,
  });

  @override
  List<Object> get props => [index, front, back];
}

class RemoveEditCard extends DeckEditEvent {
  final int index;

  const RemoveEditCard(this.index);

  @override
  List<Object> get props => [index];
}

class SaveDeckEdit extends DeckEditEvent {
  const SaveDeckEdit();
}
