import 'package:educards/core/usecases/usecase.dart';
import '../entities/deck.dart';
import '../repositories/deck_repository.dart';

class UpdateDeckUseCase extends UseCase<Deck, Deck> {
  final DeckRepository repository;

  UpdateDeckUseCase(this.repository);

  @override
  Future<Deck> call(Deck params) {
    return repository.updateDeck(params);
  }
}
