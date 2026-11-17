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

/// キーを保存・削除した結果。
enum KeySaveResult { saved, deleted, failed }

/// 画面に 1 回だけ知らせるための通知。同じ結果が続いても区別できるよう [serial] を持つ。
class KeySaveNotice extends Equatable {
  final AiProvider provider;
  final KeySaveResult result;
  final int serial;

  const KeySaveNotice(this.provider, this.result, this.serial);

  @override
  List<Object?> get props => [provider, result, serial];
}

class SettingsLoaded extends SettingsState {
  final AppSettings settings;

  /// キーが保存されている AI。キーそのものは持たない。
  final Set<AiProvider> configuredProviders;

  /// 直近のキーの保存の結果。まだ保存していなければ null。
  final KeySaveNotice? keyNotice;

  const SettingsLoaded(
    this.settings, {
    this.configuredProviders = const {},
    this.keyNotice,
  });

  SettingsLoaded copyWith({
    AppSettings? settings,
    Set<AiProvider>? configuredProviders,
    KeySaveNotice? keyNotice,
  }) =>
      SettingsLoaded(
        settings ?? this.settings,
        configuredProviders: configuredProviders ?? this.configuredProviders,
        keyNotice: keyNotice ?? this.keyNotice,
      );

  @override
  List<Object?> get props => [settings, configuredProviders, keyNotice];
}

class SettingsError extends SettingsState {
  final String message;

  const SettingsError(this.message);

  @override
  List<Object?> get props => [message];
}
