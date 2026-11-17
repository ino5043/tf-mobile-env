import 'package:flutter_test/flutter_test.dart';

import 'package:educards/core/ai/ai_provider.dart';
import 'package:educards/features/settings/data/datasources/secret_store.dart';
import 'package:educards/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:educards/features/settings/data/models/app_settings_model.dart';
import 'package:educards/features/settings/data/repositories/api_key_repository_impl.dart';

class _MemorySecretStore implements SecretStore {
  final values = <String, String>{};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);
}

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
  late _MemorySecretStore secrets;
  late _MemorySettingsSource settings;
  late ApiKeyRepositoryImpl repository;

  setUp(() {
    secrets = _MemorySecretStore();
    settings = _MemorySettingsSource(null);
    repository = ApiKeyRepositoryImpl(secrets, settings);
  });

  test('keeps a separate key for each provider', () async {
    await repository.saveApiKey(AiProvider.claude, 'sk-ant-1');
    await repository.saveApiKey(AiProvider.openai, 'sk-proj-2');

    expect(await repository.getApiKey(AiProvider.claude), 'sk-ant-1');
    expect(await repository.getApiKey(AiProvider.openai), 'sk-proj-2');
    expect(await repository.getApiKey(AiProvider.gemini), isNull);
    expect(await repository.configuredProviders(),
        {AiProvider.claude, AiProvider.openai});
  });

  test('trims the key and deletes it when saved empty', () async {
    await repository.saveApiKey(AiProvider.gemini, '  AIza-3  ');
    expect(await repository.getApiKey(AiProvider.gemini), 'AIza-3');

    await repository.saveApiKey(AiProvider.gemini, '   ');
    expect(await repository.getApiKey(AiProvider.gemini), isNull);
    expect(secrets.values, isEmpty);
  });

  test('moves an old Claude key out of the plain settings box', () async {
    settings.model = const AppSettingsModel(
      dailyNewCardLimit: 12,
      dailyReviewCardLimit: 34,
      legacyClaudeApiKey: 'sk-ant-old',
    );

    await repository.migrateLegacyKey();

    expect(await repository.getApiKey(AiProvider.claude), 'sk-ant-old');
    expect(settings.model!.legacyClaudeApiKey, isNull);
    // ほかの設定は残す
    expect(settings.model!.dailyNewCardLimit, 12);
    expect(settings.model!.dailyReviewCardLimit, 34);
  });

  test('does not overwrite a key that is already in secure storage',
      () async {
    await repository.saveApiKey(AiProvider.claude, 'sk-ant-new');
    settings.model = const AppSettingsModel(
      dailyNewCardLimit: 10,
      dailyReviewCardLimit: 20,
      legacyClaudeApiKey: 'sk-ant-old',
    );

    await repository.migrateLegacyKey();

    expect(await repository.getApiKey(AiProvider.claude), 'sk-ant-new');
    expect(settings.model!.legacyClaudeApiKey, isNull);
  });

  test('migration does nothing when there is no old key', () async {
    await repository.migrateLegacyKey();

    expect(secrets.values, isEmpty);
    expect(settings.model, isNull);
  });
}
