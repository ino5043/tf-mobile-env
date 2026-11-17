import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../features/audio/data/tts_service_impl.dart';
import '../../features/audio/domain/tts_service.dart';
import '../../features/deck/data/datasources/deck_local_datasource.dart';
import '../../features/deck/data/services/ai_generation_service.dart';
import '../../features/deck/data/services/deck_import_service.dart';
import '../../features/deck/data/models/deck_model.dart';
import '../../features/deck/data/models/flashcard_model.dart';
import '../../features/deck/data/repositories/deck_repository_impl.dart';
import '../../features/deck/domain/repositories/deck_repository.dart';
import '../../features/deck/domain/usecases/create_deck_usecase.dart';
import '../../features/deck/domain/usecases/delete_deck_usecase.dart';
import '../../features/deck/domain/usecases/get_all_decks_usecase.dart';
import '../../features/deck/domain/usecases/get_deck_usecase.dart';
import '../../features/deck/domain/usecases/generate_deck_usecase.dart';
import '../../features/deck/domain/usecases/generate_from_media_usecase.dart';
import '../../features/deck/domain/usecases/import_deck_usecase.dart';
import '../../features/deck/domain/usecases/update_deck_usecase.dart';
import '../../features/deck/domain/usecases/export_deck_usecase.dart';
import '../../features/deck/presentation/bloc/deck_create_bloc.dart';
import '../../features/deck/presentation/bloc/deck_detail_bloc.dart';
import '../../features/deck/presentation/bloc/deck_edit_bloc.dart';
import '../../features/deck/presentation/bloc/deck_list_bloc.dart';
import '../../features/study/data/datasources/study_local_datasource.dart';
import '../../features/study/data/models/study_record_model.dart';
import '../../features/study/data/repositories/study_repository_impl.dart';
import '../../features/study/domain/repositories/study_repository.dart';
import '../../features/study/domain/usecases/calculate_next_review_usecase.dart';
import '../../features/study/domain/usecases/get_due_cards_usecase.dart';
import '../../features/study/domain/usecases/get_study_queue_usecase.dart';
import '../../features/study/domain/usecases/review_card_usecase.dart';
import '../../features/study/presentation/bloc/listen_mode_bloc.dart';
import '../../features/study/presentation/bloc/study_plan_bloc.dart';
import '../../features/study/presentation/bloc/study_session_bloc.dart';
import '../../features/progress/data/datasources/progress_local_datasource.dart';
import '../../features/progress/data/models/study_stats_model.dart';
import '../../features/progress/data/repositories/progress_repository_impl.dart';
import '../../features/progress/domain/repositories/progress_repository.dart';
import '../../features/progress/domain/usecases/get_daily_stats_usecase.dart';
import '../../features/progress/domain/usecases/get_deck_progress_usecase.dart';
import '../../features/progress/domain/usecases/get_progress_trend_usecase.dart';
import '../../features/progress/domain/usecases/get_streak_usecase.dart';
import '../../features/progress/presentation/bloc/progress_bloc.dart';
import '../../features/settings/data/datasources/settings_local_datasource.dart';
import '../../features/settings/data/models/app_settings_model.dart';
import '../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/settings/presentation/bloc/settings_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // --- Hive ---
  await Hive.initFlutter();
  Hive.registerAdapter(DeckModelAdapter());
  Hive.registerAdapter(FlashcardModelAdapter());
  Hive.registerAdapter(StudyRecordModelAdapter());
  Hive.registerAdapter(StudyStatsModelAdapter());
  Hive.registerAdapter(AppSettingsModelAdapter());

  final deckBox = await Hive.openBox<DeckModel>('decks');
  final studyBox = await Hive.openBox<StudyRecordModel>('study_records');
  final statsBox = await Hive.openBox<StudyStatsModel>('study_stats');
  final settingsBox = await Hive.openBox<AppSettingsModel>('app_settings');

  // --- TTS Service ---
  sl.registerLazySingleton<TtsService>(() => TtsServiceImpl());

  // --- DataSources ---
  sl.registerLazySingleton<DeckLocalDataSource>(
    () => DeckLocalDataSourceImpl(deckBox),
  );
  sl.registerLazySingleton<StudyLocalDataSource>(
    () => StudyLocalDataSourceImpl(studyBox),
  );
  sl.registerLazySingleton<ProgressLocalDataSource>(
    () => ProgressLocalDataSourceImpl(statsBox),
  );
  sl.registerLazySingleton<SettingsLocalDataSource>(
    () => SettingsLocalDataSourceImpl(settingsBox),
  );

  // --- Repositories ---
  sl.registerLazySingleton<DeckRepository>(
    () => DeckRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<ProgressRepository>(
    () => ProgressRepositoryImpl(sl(), sl()),
  );
  sl.registerLazySingleton<StudyRepository>(
    () => StudyRepositoryImpl(
      studyDataSource: sl(),
      deckDataSource: sl(),
      progressRepository: sl(),
    ),
  );

  // --- UseCases ---
  sl.registerLazySingleton(() => GetAllDecksUseCase(sl()));
  sl.registerLazySingleton(() => GetDeckUseCase(sl()));
  sl.registerLazySingleton(() => CreateDeckUseCase(sl()));
  sl.registerLazySingleton(() => UpdateDeckUseCase(sl()));
  sl.registerLazySingleton(() => DeleteDeckUseCase(sl()));
  sl.registerLazySingleton(() => DeckImportService());
  sl.registerLazySingleton(() => ImportDeckUseCase(sl()));
  sl.registerLazySingleton(() => AIGenerationService());
  sl.registerLazySingleton(() => GenerateDeckUseCase(sl()));
  sl.registerLazySingleton(() => GenerateFromMediaUseCase(sl()));
  sl.registerLazySingleton(() => ExportDeckUseCase());
  sl.registerLazySingleton(() => GetDueCardsUseCase(sl()));
  sl.registerLazySingleton(() => ReviewCardUseCase(sl()));
  sl.registerLazySingleton(() => CalculateNextReviewUseCase());
  sl.registerLazySingleton(() => GetDailyStatsUseCase(sl()));
  sl.registerLazySingleton(() => GetStreakUseCase(sl()));
  sl.registerLazySingleton(() => GetProgressTrendUseCase(sl()));
  sl.registerLazySingleton(() => GetDeckProgressUseCase(sl()));
  sl.registerLazySingleton(() => GetStudyQueueUseCase(
        deckRepository: sl(),
        settingsRepository: sl(),
      ));

  // --- BLoCs ---
  sl.registerFactory(
    () => DeckListBloc(
      getAllDecks: sl(),
      createDeck: sl(),
      deleteDeck: sl(),
    ),
  );
  sl.registerFactory(
    () => StudySessionBloc(
      getDueCards: sl(),
      reviewCard: sl(),
    ),
  );
  sl.registerFactory(
    () => StudyPlanBloc(
      getStudyQueue: sl(),
    ),
  );
  sl.registerFactory(
    () => ProgressBloc(
      getDailyStats: sl(),
      getStreak: sl(),
      getProgressTrend: sl(),
      getDeckProgress: sl(),
    ),
  );
  sl.registerFactory(
    () => SettingsBloc(
      settingsRepository: sl(),
    ),
  );
  sl.registerFactory(
    () => ListenModeBloc(
      getDeck: sl(),
      settingsRepository: sl(),
    ),
  );
  sl.registerFactory(
    () => DeckDetailBloc(
      getDeck: sl(),
      exportDeck: sl(),
    ),
  );
  sl.registerFactory(
    () => DeckEditBloc(
      getDeck: sl(),
      updateDeck: sl(),
    ),
  );
  sl.registerFactory(
    () => DeckCreateBloc(
      createDeck: sl(),
      importDeck: sl(),
      generateDeck: sl(),
      generateFromMedia: sl(),
      settingsRepository: sl(),
    ),
  );
}
