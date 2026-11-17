import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_datasource.dart';
import '../models/app_settings_model.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource localDataSource;

  SettingsRepositoryImpl(this.localDataSource);

  @override
  Future<AppSettings> getSettings() async {
    final model = localDataSource.getSettings();
    return model?.toEntity() ?? const AppSettings();
  }

  @override
  Future<void> saveSettings(AppSettings settings) async {
    // 古い版のキー（2 番の欄）は、安全な保管場所へ移すまで残す。
    // 消してよいのは ApiKeyRepositoryImpl.migrateLegacyKey だけ。
    final legacyKey = localDataSource.getSettings()?.legacyClaudeApiKey;
    await localDataSource.saveSettings(
      AppSettingsModel.fromEntity(settings, legacyClaudeApiKey: legacyKey),
    );
  }
}
