import 'package:equatable/equatable.dart';

import 'package:educards/core/usecases/usecase.dart';
import '../entities/deck.dart';
import '../repositories/deck_repository.dart';

class CreateDeckParams extends Equatable {
  final String title;
  final String description;
  final List<Map<String, dynamic>> cards;

  const CreateDeckParams({
    required this.title,
    required this.description,
    this.cards = const [],
  });

  @override
  List<Object> get props => [title, description, cards];
}

class CreateDeckUseCase extends UseCase<Deck, CreateDeckParams> {
  final DeckRepository repository;

  CreateDeckUseCase(this.repository);

  @override
  Future<Deck> call(CreateDeckParams params) {
    if (params.title.trim().isEmpty) {
      throw ArgumentError('Deck title cannot be empty');
    }
    return repository.createDeck(
      title: params.title.trim(),
      description: params.description.trim(),
      cards: params.cards,
    );
  }
}
