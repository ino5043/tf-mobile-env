import 'package:educards/core/ai/ai_provider.dart';

import '../../domain/repositories/api_key_repository.dart';
import '../datasources/secret_store.dart';
import '../datasources/settings_local_datasource.dart';

class ApiKeyRepositoryImpl implements ApiKeyRepository {
  final SecretStore _secrets;
  final SettingsLocalDataSource _settings;

  ApiKeyRepositoryImpl(this._secrets, this._settings);

  static String _keyName(AiProvider provider) => 'api_key.${provider.name}';

  @override
  Future<String?> getApiKey(AiProvider provider) async {
    final value = await _secrets.read(_keyName(provider));
    return (value == null || value.isEmpty) ? null : value;
  }

  @override
  Future<void> saveApiKey(AiProvider provider, String apiKey) async {
    final trimmed = apiKey.trim();
    if (trimmed.isEmpty) {
      await _secrets.delete(_keyName(provider));
    } else {
      await _secrets.write(_keyName(provider), trimmed);
    }
  }

  @override
  Future<Set<AiProvider>> configuredProviders() async {
    final configured = <AiProvider>{};
    for (final provider in AiProvider.values) {
      if (await getApiKey(provider) != null) configured.add(provider);
    }
    return configured;
  }

  /// 以前の版は Claude のキーを通常の設定（暗号化なし）に入れていた。
  /// 起動時に一度呼び、安全な保管場所へ移してから元の欄を空にする。
  /// 安全な保管場所に新しいキーがあれば、そちらを優先する。
  Future<void> migrateLegacyKey() async {
    final model = _settings.getSettings();
    final legacy = model?.legacyClaudeApiKey?.trim();
    if (model == null || legacy == null) return;

    if (legacy.isNotEmpty && await getApiKey(AiProvider.claude) == null) {
      await saveApiKey(AiProvider.claude, legacy);
    }
    await _settings.saveSettings(model.withoutLegacyKey());
  }
}
