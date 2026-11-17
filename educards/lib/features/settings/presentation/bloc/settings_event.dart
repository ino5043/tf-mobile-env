import 'package:equatable/equatable.dart';

import 'package:educards/core/ai/ai_provider.dart';

sealed class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSettings extends SettingsEvent {
  const LoadSettings();
}

class UpdateDailyNewCardLimit extends SettingsEvent {
  final int limit;
  const UpdateDailyNewCardLimit(this.limit);

  @override
  List<Object?> get props => [limit];
}

class UpdateDailyReviewCardLimit extends SettingsEvent {
  final int limit;
  const UpdateDailyReviewCardLimit(this.limit);

  @override
  List<Object?> get props => [limit];
}

class UpdateAiProvider extends SettingsEvent {
  final AiProvider provider;
  const UpdateAiProvider(this.provider);

  @override
  List<Object?> get props => [provider];
}

/// [apiKey] が空ならそのAIのキーを消す。
class UpdateApiKey extends SettingsEvent {
  final AiProvider provider;
  final String apiKey;
  const UpdateApiKey(this.provider, this.apiKey);

  @override
  List<Object?> get props => [provider, apiKey];

  /// ログに出ることがあるので、キーそのものは出さない。
  @override
  String toString() => 'UpdateApiKey(${provider.name})';
}

class UpdateTtsSpeed extends SettingsEvent {
  final double speed;
  const UpdateTtsSpeed(this.speed);

  @override
  List<Object?> get props => [speed];
}

class UpdateAutoReadAloud extends SettingsEvent {
  final bool enabled;
  const UpdateAutoReadAloud(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class UpdateLocale extends SettingsEvent {
  /// Locale code ('en', 'ja') or null for system default.
  final String? locale;
  const UpdateLocale(this.locale);

  @override
  List<Object?> get props => [locale];
}
