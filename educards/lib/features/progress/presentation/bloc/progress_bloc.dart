import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:educards/core/usecases/usecase.dart';
import '../../domain/usecases/get_daily_stats_usecase.dart';
import '../../domain/usecases/get_deck_progress_usecase.dart';
import '../../domain/usecases/get_progress_trend_usecase.dart';
import '../../domain/usecases/get_streak_usecase.dart';
import 'progress_event.dart';
import 'progress_state.dart';

class ProgressBloc extends Bloc<ProgressEvent, ProgressState> {
  final GetDailyStatsUseCase getDailyStats;
  final GetStreakUseCase getStreak;
  final GetProgressTrendUseCase getProgressTrend;
  final GetDeckProgressUseCase getDeckProgress;

  ProgressBloc({
    required this.getDailyStats,
    required this.getStreak,
    required this.getProgressTrend,
    required this.getDeckProgress,
  }) : super(const ProgressInitial()) {
    on<LoadProgress>(_onLoadProgress);
  }

  Future<void> _onLoadProgress(
    LoadProgress event,
    Emitter<ProgressState> emit,
  ) async {
    emit(const ProgressLoading());
    try {
      final stats = await getDailyStats(DateTime.now());
      final streak = await getStreak(const NoParams());
      final trend = await getProgressTrend(7);
      final deckProgress = await getDeckProgress(const NoParams());
      emit(ProgressLoaded(
        todayStats: stats,
        streak: streak,
        trend: trend,
        deckProgressList: deckProgress,
      ));
    } catch (e) {
      emit(ProgressError(e.toString()));
    }
  }
}
