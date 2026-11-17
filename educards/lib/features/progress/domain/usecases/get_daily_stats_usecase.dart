import 'package:educards/core/usecases/usecase.dart';
import 'package:educards/features/progress/domain/entities/study_stats.dart';
import 'package:educards/features/progress/domain/repositories/progress_repository.dart';

class GetDailyStatsUseCase extends UseCase<StudyStats, DateTime> {
  final ProgressRepository repository;

  GetDailyStatsUseCase(this.repository);

  @override
  Future<StudyStats> call(DateTime date) {
    return repository.getDailyStats(date);
  }
}
