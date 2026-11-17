import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app.dart';
import '../../domain/repositories/api_key_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import 'settings_event.dart';
import 'settings_state.dart';

/// 設定の変更は、種類を問わず 1 つずつ順に処理する。キーの保存（安全な保管場所への書き込み）は
/// 遅いことがあり、並べて処理すると、待っている間の別の変更を古い状態で上書きしてしまう。
Stream<E> _oneAtATime<E>(Stream<E> events, Stream<E> Function(E) mapper) =>
    events.asyncExpand(mapper);

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository settingsRepository;
  final ApiKeyRepository apiKeyRepository;

  SettingsBloc({
    required this.settingsRepository,
    required this.apiKeyRepository,
  }) : super(const SettingsInitial()) {
    // 種類ごとに on<> を分けると、種類の違う変更は並んで処理される。
    // 全部を 1 つの入り口で受け、1 つずつ順に処理する。
    on<SettingsEvent>(
      (event, emit) => switch (event) {
        LoadSettings() => _onLoadSettings(event, emit),
        UpdateDailyNewCardLimit() => _onUpdateNewCardLimit(event, emit),
        UpdateDailyReviewCardLimit() => _onUpdateReviewCardLimit(event, emit),
        UpdateAiProvider() => _onUpdateAiProvider(event, emit),
        UpdateApiKey() => _onUpdateApiKey(event, emit),
        UpdateTtsSpeed() => _onUpdateTtsSpeed(event, emit),
        UpdateAutoReadAloud() => _onUpdateAutoReadAloud(event, emit),
        UpdateLocale() => _onUpdateLocale(event, emit),
      },
      transformer: _oneAtATime,
    );
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

  int _noticeSerial = 0;

  Future<void> _onUpdateApiKey(
    UpdateApiKey event,
    Emitter<SettingsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! SettingsLoaded) return;

    final deleting = event.apiKey.trim().isEmpty;
    KeySaveResult result;
    var configured = currentState.configuredProviders;
    try {
      await apiKeyRepository.saveApiKey(event.provider, event.apiKey);
      configured = await apiKeyRepository.configuredProviders();
      result = deleting ? KeySaveResult.deleted : KeySaveResult.saved;
    } catch (e) {
      // 失敗を画面に知らせる。キーの値は出さない。
      addError(Exception('API key save failed: ${e.runtimeType}'));
      result = KeySaveResult.failed;
    }
    emit(currentState.copyWith(
      configuredProviders: configured,
      keyNotice: KeySaveNotice(event.provider, result, ++_noticeSerial),
    ));
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
