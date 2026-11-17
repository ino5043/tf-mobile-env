import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:educards/core/ai/ai_provider.dart';
import 'package:educards/features/settings/domain/repositories/api_key_repository.dart';

import 'package:educards/features/settings/domain/entities/app_settings.dart';
import 'package:educards/features/settings/domain/repositories/settings_repository.dart';
import 'package:educards/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:educards/features/settings/presentation/bloc/settings_event.dart';
import 'package:educards/features/settings/presentation/bloc/settings_state.dart';

class _FakeSettingsRepository implements SettingsRepository {
  AppSettings _settings = const AppSettings();

  @override
  Future<AppSettings> getSettings() async => _settings;

  @override
  Future<void> saveSettings(AppSettings settings) async {
    _settings = settings;
  }
}

class _FakeApiKeyRepository implements ApiKeyRepository {
  final keys = <AiProvider, String>{};

  @override
  Future<String?> getApiKey(AiProvider provider) async => keys[provider];

  @override
  Future<void> saveApiKey(AiProvider provider, String apiKey) async {
    final trimmed = apiKey.trim();
    trimmed.isEmpty ? keys.remove(provider) : keys[provider] = trimmed;
  }

  @override
  Future<Set<AiProvider>> configuredProviders() async => keys.keys.toSet();
}

void main() {
  late _FakeSettingsRepository repository;
  late _FakeApiKeyRepository keys;

  setUp(() {
    repository = _FakeSettingsRepository();
    keys = _FakeApiKeyRepository();
  });

  group('SettingsBloc — AI provider and keys', () {
    blocTest<SettingsBloc, SettingsState>(
      'LoadSettings reports which providers already have a key',
      setUp: () => keys.keys[AiProvider.openai] = 'sk-proj',
      build: () => SettingsBloc(settingsRepository: repository, apiKeyRepository: keys),
      act: (bloc) => bloc.add(const LoadSettings()),
      expect: () => [
        isA<SettingsLoading>(),
        isA<SettingsLoaded>()
            .having((s) => s.configuredProviders, 'configured',
                {AiProvider.openai})
            .having((s) => s.settings.aiProvider, 'provider',
                AiProvider.claude),
      ],
    );

    blocTest<SettingsBloc, SettingsState>(
      'UpdateAiProvider switches and saves the provider',
      build: () => SettingsBloc(settingsRepository: repository, apiKeyRepository: keys),
      seed: () => const SettingsLoaded(AppSettings()),
      act: (bloc) => bloc.add(const UpdateAiProvider(AiProvider.gemini)),
      expect: () => [
        isA<SettingsLoaded>().having(
            (s) => s.settings.aiProvider, 'provider', AiProvider.gemini),
      ],
      verify: (_) async {
        expect((await repository.getSettings()).aiProvider, AiProvider.gemini);
      },
    );

    blocTest<SettingsBloc, SettingsState>(
      'UpdateApiKey stores the key for that provider only',
      build: () => SettingsBloc(settingsRepository: repository, apiKeyRepository: keys),
      seed: () => const SettingsLoaded(AppSettings()),
      act: (bloc) => bloc.add(const UpdateApiKey(AiProvider.gemini, 'AIza')),
      expect: () => [
        isA<SettingsLoaded>().having((s) => s.configuredProviders,
            'configured', {AiProvider.gemini}),
      ],
      verify: (_) {
        expect(keys.keys, {AiProvider.gemini: 'AIza'});
      },
    );

    blocTest<SettingsBloc, SettingsState>(
      'UpdateApiKey with an empty value removes the key',
      setUp: () => keys.keys[AiProvider.claude] = 'sk-ant',
      build: () => SettingsBloc(settingsRepository: repository, apiKeyRepository: keys),
      seed: () => const SettingsLoaded(AppSettings(),
          configuredProviders: {AiProvider.claude}),
      act: (bloc) => bloc.add(const UpdateApiKey(AiProvider.claude, '')),
      expect: () => [
        isA<SettingsLoaded>()
            .having((s) => s.configuredProviders, 'configured', isEmpty),
      ],
    );
  });

  group('SettingsBloc — TTS settings', () {
    blocTest<SettingsBloc, SettingsState>(
      'LoadSettings emits SettingsLoaded with default TTS values',
      build: () => SettingsBloc(settingsRepository: repository, apiKeyRepository: keys),
      act: (bloc) => bloc.add(const LoadSettings()),
      expect: () => [
        isA<SettingsLoading>(),
        isA<SettingsLoaded>().having(
          (s) => s.settings.ttsSpeed,
          'ttsSpeed',
          1.0,
        ),
      ],
    );

    blocTest<SettingsBloc, SettingsState>(
      'UpdateTtsSpeed updates speed in settings',
      build: () => SettingsBloc(settingsRepository: repository, apiKeyRepository: keys),
      seed: () => const SettingsLoaded(AppSettings()),
      act: (bloc) => bloc.add(const UpdateTtsSpeed(1.5)),
      expect: () => [
        isA<SettingsLoaded>().having(
          (s) => s.settings.ttsSpeed,
          'ttsSpeed',
          1.5,
        ),
      ],
      verify: (_) async {
        final saved = await repository.getSettings();
        expect(saved.ttsSpeed, 1.5);
      },
    );

    blocTest<SettingsBloc, SettingsState>(
      'UpdateAutoReadAloud toggles auto read setting',
      build: () => SettingsBloc(settingsRepository: repository, apiKeyRepository: keys),
      seed: () => const SettingsLoaded(AppSettings()),
      act: (bloc) => bloc.add(const UpdateAutoReadAloud(true)),
      expect: () => [
        isA<SettingsLoaded>().having(
          (s) => s.settings.autoReadAloud,
          'autoReadAloud',
          true,
        ),
      ],
      verify: (_) async {
        final saved = await repository.getSettings();
        expect(saved.autoReadAloud, true);
      },
    );

    blocTest<SettingsBloc, SettingsState>(
      'UpdateTtsSpeed does nothing when not in SettingsLoaded state',
      build: () => SettingsBloc(settingsRepository: repository, apiKeyRepository: keys),
      act: (bloc) => bloc.add(const UpdateTtsSpeed(1.5)),
      expect: () => <SettingsState>[],
    );

    blocTest<SettingsBloc, SettingsState>(
      'UpdateAutoReadAloud does nothing when not in SettingsLoaded state',
      build: () => SettingsBloc(settingsRepository: repository, apiKeyRepository: keys),
      act: (bloc) => bloc.add(const UpdateAutoReadAloud(true)),
      expect: () => <SettingsState>[],
    );

    blocTest<SettingsBloc, SettingsState>(
      'Sequential TTS speed updates preserve latest value',
      build: () => SettingsBloc(settingsRepository: repository, apiKeyRepository: keys),
      seed: () => const SettingsLoaded(AppSettings()),
      act: (bloc) {
        bloc.add(const UpdateTtsSpeed(0.8));
        bloc.add(const UpdateTtsSpeed(1.2));
      },
      expect: () => [
        isA<SettingsLoaded>().having(
          (s) => s.settings.ttsSpeed,
          'ttsSpeed',
          0.8,
        ),
        isA<SettingsLoaded>().having(
          (s) => s.settings.ttsSpeed,
          'ttsSpeed',
          1.2,
        ),
      ],
    );
  });

  group('SettingsBloc — Locale', () {
    blocTest<SettingsBloc, SettingsState>(
      'UpdateLocale sets locale to ja',
      build: () => SettingsBloc(settingsRepository: repository, apiKeyRepository: keys),
      seed: () => const SettingsLoaded(AppSettings()),
      act: (bloc) => bloc.add(const UpdateLocale('ja')),
      expect: () => [
        isA<SettingsLoaded>().having(
          (s) => s.settings.locale,
          'locale',
          'ja',
        ),
      ],
      verify: (_) async {
        final saved = await repository.getSettings();
        expect(saved.locale, 'ja');
      },
    );

    blocTest<SettingsBloc, SettingsState>(
      'UpdateLocale with null resets to system default',
      build: () {
        repository._settings = const AppSettings(locale: 'ja');
        return SettingsBloc(settingsRepository: repository, apiKeyRepository: keys);
      },
      seed: () => const SettingsLoaded(AppSettings(locale: 'ja')),
      act: (bloc) => bloc.add(const UpdateLocale(null)),
      expect: () => [
        isA<SettingsLoaded>().having(
          (s) => s.settings.locale,
          'locale',
          null,
        ),
      ],
      verify: (_) async {
        final saved = await repository.getSettings();
        expect(saved.locale, null);
      },
    );

    blocTest<SettingsBloc, SettingsState>(
      'UpdateLocale does nothing when not in SettingsLoaded state',
      build: () => SettingsBloc(settingsRepository: repository, apiKeyRepository: keys),
      act: (bloc) => bloc.add(const UpdateLocale('en')),
      expect: () => <SettingsState>[],
    );
  });
}
