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
