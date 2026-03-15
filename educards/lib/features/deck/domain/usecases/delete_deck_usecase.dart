import 'package:educards/core/usecases/usecase.dart';
import '../repositories/deck_repository.dart';

class DeleteDeckUseCase extends UseCase<void, String> {
  final DeckRepository repository;

  DeleteDeckUseCase(this.repository);

  @override
  Future<void> call(String params) {
    return repository.deleteDeck(params);
  }
}
