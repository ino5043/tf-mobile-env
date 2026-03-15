import 'package:equatable/equatable.dart';

import 'package:educards/features/progress/domain/entities/deck_progress.dart';
import 'package:educards/features/progress/domain/entities/progress_trend.dart';
import 'package:educards/features/progress/domain/entities/streak_info.dart';
import 'package:educards/features/progress/domain/entities/study_stats.dart';

sealed class ProgressState extends Equatable {
  const ProgressState();

  @override
  List<Object?> get props => [];
}

class ProgressInitial extends ProgressState {
  const ProgressInitial();
}

class ProgressLoading extends ProgressState {
  const ProgressLoading();
}

class ProgressLoaded extends ProgressState {
  final StudyStats todayStats;
  final StreakInfo streak;
  final ProgressTrend trend;
  final List<DeckProgress> deckProgressList;

  const ProgressLoaded({
    required this.todayStats,
    required this.streak,
    required this.trend,
    required this.deckProgressList,
  });

  @override
  List<Object?> get props => [todayStats, streak, trend, deckProgressList];
}

class ProgressError extends ProgressState {
  final String message;

  const ProgressError(this.message);

  @override
  List<Object?> get props => [message];
}
