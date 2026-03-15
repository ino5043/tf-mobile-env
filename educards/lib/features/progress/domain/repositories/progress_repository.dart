import 'package:educards/features/progress/domain/entities/deck_progress.dart';
import 'package:educards/features/progress/domain/entities/progress_trend.dart';
import 'package:educards/features/progress/domain/entities/streak_info.dart';
import 'package:educards/features/progress/domain/entities/study_stats.dart';

/// Repository interface for progress tracking persistence.
abstract class ProgressRepository {
  Future<StudyStats> getDailyStats(DateTime date);
  Future<StreakInfo> getStreak();
  Future<void> recordStudy({
    required DateTime date,
    required bool wasCorrect,
  });
  Future<ProgressTrend> getProgressTrend(int days);
  Future<List<DeckProgress>> getDeckProgress();
}
