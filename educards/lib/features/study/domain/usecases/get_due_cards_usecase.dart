import 'package:educards/core/usecases/usecase.dart';
import '../../../deck/domain/entities/flashcard.dart';
import '../repositories/study_repository.dart';

class GetDueCardsUseCase extends UseCase<List<Flashcard>, String> {
  final StudyRepository repository;

  GetDueCardsUseCase(this.repository);

  @override
  Future<List<Flashcard>> call(String deckId) {
    return repository.getDueCards(deckId);
  }
}
