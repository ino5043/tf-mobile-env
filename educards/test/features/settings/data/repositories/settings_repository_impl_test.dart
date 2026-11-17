import 'package:flutter_test/flutter_test.dart';

import 'package:educards/core/ai/ai_provider.dart';
import 'package:educards/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:educards/features/settings/data/models/app_settings_model.dart';
import 'package:educards/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:educards/features/settings/domain/entities/app_settings.dart';

class _MemorySettingsSource implements SettingsLocalDataSource {
  AppSettingsModel? model;

  _MemorySettingsSource(this.model);

  @override
  AppSettingsModel? getSettings() => model;

  @override
  Future<void> saveSettings(AppSettingsModel settings) async =>
      model = settings;
}

void main() {
  test('saving settings keeps an old key that has not been moved yet',
      () async {
    // 起動時の移し替えに失敗したあとで設定を変えても、古いキーを消さない。
    // 消してよいのは移し替え（ApiKeyRepositoryImpl.migrateLegacyKey）だけ。
    final source = _MemorySettingsSource(const AppSettingsModel(
      dailyNewCardLimit: 10,
      dailyReviewCardLimit: 20,
      legacyClaudeApiKey: 'sk-ant-old',
    ));
    final repository = SettingsRepositoryImpl(source);

    await repository.saveSettings(
        const AppSettings(ttsSpeed: 1.5, aiProvider: AiProvider.gemini));

    expect(source.model!.legacyClaudeApiKey, 'sk-ant-old');
    expect(source.model!.ttsSpeed, 1.5);
    expect(source.model!.aiProvider, 'gemini');
  });

  test('saving settings on a fresh install stores no key', () async {
    final source = _MemorySettingsSource(null);

    await SettingsRepositoryImpl(source).saveSettings(const AppSettings());

    expect(source.model!.legacyClaudeApiKey, isNull);
  });
}
