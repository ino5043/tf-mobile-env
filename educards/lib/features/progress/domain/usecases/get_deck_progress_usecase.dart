import 'package:educards/core/usecases/usecase.dart';
import '../entities/deck_progress.dart';
import '../repositories/progress_repository.dart';

class GetDeckProgressUseCase extends UseCase<List<DeckProgress>, NoParams> {
  final ProgressRepository repository;

  GetDeckProgressUseCase(this.repository);

  @override
  Future<List<DeckProgress>> call(NoParams params) {
    return repository.getDeckProgress();
  }
}
