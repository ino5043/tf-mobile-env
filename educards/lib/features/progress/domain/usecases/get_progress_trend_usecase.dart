import 'package:educards/core/usecases/usecase.dart';
import '../entities/progress_trend.dart';
import '../repositories/progress_repository.dart';

class GetProgressTrendUseCase extends UseCase<ProgressTrend, int> {
  final ProgressRepository repository;

  GetProgressTrendUseCase(this.repository);

  @override
  Future<ProgressTrend> call(int days) {
    return repository.getProgressTrend(days);
  }
}
