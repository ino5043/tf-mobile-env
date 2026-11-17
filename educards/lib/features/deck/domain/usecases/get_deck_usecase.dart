import 'package:educards/core/usecases/usecase.dart';
import '../entities/deck.dart';
import '../repositories/deck_repository.dart';

class GetDeckUseCase extends UseCase<Deck?, String> {
  final DeckRepository repository;

  GetDeckUseCase(this.repository);

  @override
  Future<Deck?> call(String params) {
    return repository.getDeckById(params);
  }
}
