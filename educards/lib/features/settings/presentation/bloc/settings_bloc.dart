import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/settings_repository.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository settingsRepository;

  SettingsBloc({required this.settingsRepository})
      : super(const SettingsInitial()) {
    on<LoadSettings>(_onLoadSettings);
    on<UpdateDailyNewCardLimit>(_onUpdateNewCardLimit);
    on<UpdateDailyReviewCardLimit>(_onUpdateReviewCardLimit);
    on<UpdateClaudeApiKey>(_onUpdateClaudeApiKey);
  }

  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsLoading());
    try {
      final settings = await settingsRepository.getSettings();
      emit(SettingsLoaded(settings));
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
    emit(SettingsLoaded(updated));
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
    emit(SettingsLoaded(updated));
  }

  Future<void> _onUpdateClaudeApiKey(
    UpdateClaudeApiKey event,
    Emitter<SettingsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! SettingsLoaded) return;

    final updated = currentState.settings.copyWith(
      claudeApiKey: event.apiKey,
    );
    await settingsRepository.saveSettings(updated);
    emit(SettingsLoaded(updated));
  }
}
