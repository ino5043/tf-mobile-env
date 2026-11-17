import 'package:educards/features/deck/data/datasources/deck_local_datasource.dart';
import 'package:educards/features/progress/domain/entities/deck_progress.dart';
import 'package:educards/features/progress/domain/entities/progress_trend.dart';
import 'package:educards/features/progress/domain/entities/streak_info.dart';
import 'package:educards/features/progress/domain/entities/study_stats.dart';
import 'package:educards/features/progress/domain/repositories/progress_repository.dart';
import 'package:educards/features/study/domain/entities/spaced_repetition_data.dart';
import '../datasources/progress_local_datasource.dart';
import '../models/study_stats_model.dart';

class ProgressRepositoryImpl implements ProgressRepository {
  final ProgressLocalDataSource localDataSource;
  final DeckLocalDataSource deckDataSource;

  ProgressRepositoryImpl(this.localDataSource, this.deckDataSource);

  @override
  Future<StudyStats> getDailyStats(DateTime date) async {
    final model = localDataSource.getStatsByDate(date);
    return model?.toEntity() ?? StudyStats.empty(date);
  }

  @override
  Future<StreakInfo> getStreak() async {
    final allStats = localDataSource.getAllStats()
      ..sort((a, b) => b.date.compareTo(a.date));

    if (allStats.isEmpty) return StreakInfo.empty();

    int currentStreak = 0;
    int longestStreak = 0;
    int tempStreak = 0;
    final today = DateTime.now();

    for (int i = 0; i < allStats.length; i++) {
      final stat = allStats[i];
      if (stat.cardsReviewed == 0) continue;

      final expectedDate = DateTime(
        today.year,
        today.month,
        today.day - i,
      );

      final statDate = DateTime(
        stat.date.year,
        stat.date.month,
        stat.date.day,
      );

      if (statDate == expectedDate) {
        tempStreak++;
      } else {
        break;
      }
    }
    currentStreak = tempStreak;

    // Calculate longest streak
    tempStreak = 0;
    DateTime? prevDate;
    for (final stat in allStats.reversed) {
      if (stat.cardsReviewed == 0) {
        if (tempStreak > longestStreak) longestStreak = tempStreak;
        tempStreak = 0;
        prevDate = null;
        continue;
      }

      final statDate = DateTime(stat.date.year, stat.date.month, stat.date.day);
      if (prevDate == null ||
          statDate.difference(prevDate).inDays == 1) {
        tempStreak++;
      } else {
        if (tempStreak > longestStreak) longestStreak = tempStreak;
        tempStreak = 1;
      }
      prevDate = statDate;
    }
    if (tempStreak > longestStreak) longestStreak = tempStreak;

    return StreakInfo(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      lastStudyDate: allStats.isNotEmpty ? allStats.first.date : null,
    );
  }

  @override
  Future<void> recordStudy({
    required DateTime date,
    required bool wasCorrect,
  }) async {
    final existing = localDataSource.getStatsByDate(date);
    final current = existing?.toEntity() ?? StudyStats.empty(date);

    final updated = StudyStats(
      date: date,
      cardsReviewed: current.cardsReviewed + 1,
      correctCount: current.correctCount + (wasCorrect ? 1 : 0),
      incorrectCount: current.incorrectCount + (wasCorrect ? 0 : 1),
    );

    await localDataSource.saveStats(StudyStatsModel.fromEntity(updated));
  }

  @override
  Future<ProgressTrend> getProgressTrend(int days) async {
    final now = DateTime.now();
    final stats = <StudyStats>[];

    for (int i = days - 1; i >= 0; i--) {
      final date = DateTime(now.year, now.month, now.day - i);
      final model = localDataSource.getStatsByDate(date);
      stats.add(model?.toEntity() ?? StudyStats.empty(date));
    }

    return ProgressTrend(dailyStats: stats);
  }

  @override
  Future<List<DeckProgress>> getDeckProgress() async {
    final deckModels = deckDataSource.getAllDecks();
    return deckModels.map((model) {
      final deck = model.toEntity();
      int mastered = 0, review = 0, learning = 0, newCount = 0, due = 0;

      for (final card in deck.cards) {
        switch (card.srData.mastery) {
          case MasteryLevel.mastered:
            mastered++;
          case MasteryLevel.review:
            review++;
          case MasteryLevel.learning:
            learning++;
          case MasteryLevel.newCard:
            newCount++;
        }
        if (card.isDue) due++;
      }

      return DeckProgress(
        deckId: deck.id,
        deckTitle: deck.title,
        totalCards: deck.totalCards,
        masteredCount: mastered,
        reviewCount: review,
        learningCount: learning,
        newCount: newCount,
        dueCount: due,
      );
    }).toList();
  }
}
