import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:educards/core/usecases/usecase.dart';
import 'package:educards/features/progress/domain/entities/deck_progress.dart';
import 'package:educards/features/progress/domain/entities/progress_trend.dart';
import 'package:educards/features/progress/domain/usecases/get_daily_stats_usecase.dart';
import 'package:educards/features/progress/domain/usecases/get_deck_progress_usecase.dart';
import 'package:educards/features/progress/domain/usecases/get_progress_trend_usecase.dart';
import 'package:educards/features/progress/domain/usecases/get_streak_usecase.dart';
import 'package:educards/features/progress/presentation/bloc/progress_bloc.dart';
import 'package:educards/features/progress/presentation/bloc/progress_event.dart';
import 'package:educards/features/progress/presentation/bloc/progress_state.dart';
import '../../../../fixtures/test_fixtures.dart';

class MockGetDailyStatsUseCase extends Mock implements GetDailyStatsUseCase {}
class MockGetStreakUseCase extends Mock implements GetStreakUseCase {}
class MockGetProgressTrendUseCase extends Mock implements GetProgressTrendUseCase {}
class MockGetDeckProgressUseCase extends Mock implements GetDeckProgressUseCase {}

void main() {
  late MockGetDailyStatsUseCase mockGetDailyStats;
  late MockGetStreakUseCase mockGetStreak;
  late MockGetProgressTrendUseCase mockGetProgressTrend;
  late MockGetDeckProgressUseCase mockGetDeckProgress;

  setUp(() {
    mockGetDailyStats = MockGetDailyStatsUseCase();
    mockGetStreak = MockGetStreakUseCase();
    mockGetProgressTrend = MockGetProgressTrendUseCase();
    mockGetDeckProgress = MockGetDeckProgressUseCase();
  });

  setUpAll(() {
    registerFallbackValue(DateTime(2026, 3, 15));
    registerFallbackValue(const NoParams());
    registerFallbackValue(7);
  });

  ProgressBloc buildBloc() => ProgressBloc(
    getDailyStats: mockGetDailyStats,
    getStreak: mockGetStreak,
    getProgressTrend: mockGetProgressTrend,
    getDeckProgress: mockGetDeckProgress,
  );

  group('ProgressBloc', () {
    final testStats = TestFixtures.createStudyStats();
    final testStreak = TestFixtures.createStreakInfo();
    const testTrend = ProgressTrend(dailyStats: []);
    const testDeckProgress = <DeckProgress>[];

    blocTest<ProgressBloc, ProgressState>(
      'emits [Loading, Loaded] when LoadProgress succeeds',
      build: () {
        when(() => mockGetDailyStats(any())).thenAnswer((_) async => testStats);
        when(() => mockGetStreak(any())).thenAnswer((_) async => testStreak);
        when(() => mockGetProgressTrend(any())).thenAnswer((_) async => testTrend);
        when(() => mockGetDeckProgress(any())).thenAnswer((_) async => testDeckProgress);
        return buildBloc();
      },
      act: (bloc) => bloc.add(const LoadProgress()),
      expect: () => [
        const ProgressLoading(),
        ProgressLoaded(
          todayStats: testStats,
          streak: testStreak,
          trend: testTrend,
          deckProgressList: testDeckProgress,
        ),
      ],
    );

    blocTest<ProgressBloc, ProgressState>(
      'emits [Loading, Error] when LoadProgress fails',
      build: () {
        when(() => mockGetDailyStats(any())).thenThrow(Exception('Failed'));
        when(() => mockGetStreak(any())).thenThrow(Exception('Failed'));
        when(() => mockGetProgressTrend(any())).thenThrow(Exception('Failed'));
        when(() => mockGetDeckProgress(any())).thenThrow(Exception('Failed'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const LoadProgress()),
      expect: () => [
        const ProgressLoading(),
        isA<ProgressError>(),
      ],
    );
  });
}
