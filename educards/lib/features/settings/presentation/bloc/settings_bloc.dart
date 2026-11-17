import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app.dart';
import '../../domain/repositories/api_key_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository settingsRepository;
  final ApiKeyRepository apiKeyRepository;

  SettingsBloc({
    required this.settingsRepository,
    required this.apiKeyRepository,
  })
      : super(const SettingsInitial()) {
    on<LoadSettings>(_onLoadSettings);
    on<UpdateDailyNewCardLimit>(_onUpdateNewCardLimit);
    on<UpdateDailyReviewCardLimit>(_onUpdateReviewCardLimit);
    on<UpdateAiProvider>(_onUpdateAiProvider);
    on<UpdateApiKey>(_onUpdateApiKey);
    on<UpdateTtsSpeed>(_onUpdateTtsSpeed);
    on<UpdateAutoReadAloud>(_onUpdateAutoReadAloud);
    on<UpdateLocale>(_onUpdateLocale);
  }

  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsLoading());
    try {
      final settings = await settingsRepository.getSettings();
      // Restore persisted locale
      localeNotifier.value =
          settings.locale != null ? Locale(settings.locale!) : null;
      final configured = await apiKeyRepository.configuredProviders();
      emit(SettingsLoaded(settings, configuredProviders: configured));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> _onUpdateNewCardLimit(
    UpdateDailyNewCardLimit event,
    Emitter<SettingsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! SettingsLoaded) return;

    final updated = currentState.settings.copyWith(
      dailyNewCardLimit: event.limit,
    );
    await settingsRepository.saveSettings(updated);
    emit(currentState.copyWith(settings: updated));
  }

  Future<void> _onUpdateReviewCardLimit(
    UpdateDailyReviewCardLimit event,
    Emitter<SettingsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! SettingsLoaded) return;

    final updated = currentState.settings.copyWith(
      dailyReviewCardLimit: event.limit,
    );
    await settingsRepository.saveSettings(updated);
    emit(currentState.copyWith(settings: updated));
  }

  Future<void> _onUpdateAiProvider(
    UpdateAiProvider event,
    Emitter<SettingsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! SettingsLoaded) return;

    final updated = currentState.settings.copyWith(aiProvider: event.provider);
    await settingsRepository.saveSettings(updated);
    emit(currentState.copyWith(settings: updated));
  }

  Future<void> _onUpdateApiKey(
    UpdateApiKey event,
    Emitter<SettingsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! SettingsLoaded) return;

    await apiKeyRepository.saveApiKey(event.provider, event.apiKey);
    final configured = await apiKeyRepository.configuredProviders();
    emit(currentState.copyWith(configuredProviders: configured));
  }

  Future<void> _onUpdateTtsSpeed(
    UpdateTtsSpeed event,
    Emitter<SettingsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! SettingsLoaded) return;

    final updated = currentState.settings.copyWith(
      ttsSpeed: event.speed,
    );
    await settingsRepository.saveSettings(updated);
    emit(currentState.copyWith(settings: updated));
  }

  Future<void> _onUpdateAutoReadAloud(
    UpdateAutoReadAloud event,
    Emitter<SettingsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! SettingsLoaded) return;

    final updated = currentState.settings.copyWith(
      autoReadAloud: event.enabled,
    );
    await settingsRepository.saveSettings(updated);
    emit(currentState.copyWith(settings: updated));
  }

  Future<void> _onUpdateLocale(
    UpdateLocale event,
    Emitter<SettingsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! SettingsLoaded) return;

    final updated = currentState.settings.copyWith(
      locale: () => event.locale,
    );
    await settingsRepository.saveSettings(updated);
    localeNotifier.value =
        event.locale != null ? Locale(event.locale!) : null;
    emit(currentState.copyWith(settings: updated));
  }
}
