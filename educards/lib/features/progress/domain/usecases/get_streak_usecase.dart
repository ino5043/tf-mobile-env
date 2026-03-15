import 'package:educards/core/usecases/usecase.dart';
import 'package:educards/features/progress/domain/entities/streak_info.dart';
import 'package:educards/features/progress/domain/repositories/progress_repository.dart';

class GetStreakUseCase extends UseCase<StreakInfo, NoParams> {
  final ProgressRepository repository;

  GetStreakUseCase(this.repository);

  @override
  Future<StreakInfo> call(NoParams params) {
    return repository.getStreak();
  }
}
