import 'package:educards/core/usecases/usecase.dart';
import '../entities/deck.dart';
import '../repositories/deck_repository.dart';

class GetAllDecksUseCase extends UseCase<List<Deck>, NoParams> {
  final DeckRepository repository;

  GetAllDecksUseCase(this.repository);

  @override
  Future<List<Deck>> call(NoParams params) {
    return repository.getAllDecks();
  }
}
