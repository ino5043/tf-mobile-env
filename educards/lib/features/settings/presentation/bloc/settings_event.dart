import 'package:equatable/equatable.dart';

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

class UpdateClaudeApiKey extends SettingsEvent {
  final String apiKey;
  const UpdateClaudeApiKey(this.apiKey);

  @override
  List<Object?> get props => [apiKey];
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
