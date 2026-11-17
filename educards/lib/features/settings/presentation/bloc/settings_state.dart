import 'package:equatable/equatable.dart';

import 'package:educards/core/ai/ai_provider.dart';

import '../../domain/entities/app_settings.dart';

sealed class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

class SettingsLoading extends SettingsState {
  const SettingsLoading();
}

class SettingsLoaded extends SettingsState {
  final AppSettings settings;

  /// キーが保存されている AI。キーそのものは持たない。
  final Set<AiProvider> configuredProviders;

  const SettingsLoaded(this.settings, {this.configuredProviders = const {}});

  SettingsLoaded copyWith({
    AppSettings? settings,
    Set<AiProvider>? configuredProviders,
  }) =>
      SettingsLoaded(
        settings ?? this.settings,
        configuredProviders: configuredProviders ?? this.configuredProviders,
      );

  @override
  List<Object?> get props => [settings, configuredProviders];
}

class SettingsError extends SettingsState {
  final String message;

  const SettingsError(this.message);

  @override
  List<Object?> get props => [message];
}
