import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

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

void main() {
  late _FakeSettingsRepository repository;

  setUp(() {
    repository = _FakeSettingsRepository();
  });

  group('SettingsBloc — TTS settings', () {
    blocTest<SettingsBloc, SettingsState>(
      'LoadSettings emits SettingsLoaded with default TTS values',
      build: () => SettingsBloc(settingsRepository: repository),
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
      build: () => SettingsBloc(settingsRepository: repository),
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
      build: () => SettingsBloc(settingsRepository: repository),
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
      build: () => SettingsBloc(settingsRepository: repository),
      act: (bloc) => bloc.add(const UpdateTtsSpeed(1.5)),
      expect: () => <SettingsState>[],
    );

    blocTest<SettingsBloc, SettingsState>(
      'UpdateAutoReadAloud does nothing when not in SettingsLoaded state',
      build: () => SettingsBloc(settingsRepository: repository),
      act: (bloc) => bloc.add(const UpdateAutoReadAloud(true)),
      expect: () => <SettingsState>[],
    );

    blocTest<SettingsBloc, SettingsState>(
      'Sequential TTS speed updates preserve latest value',
      build: () => SettingsBloc(settingsRepository: repository),
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
      build: () => SettingsBloc(settingsRepository: repository),
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
        return SettingsBloc(settingsRepository: repository);
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
      build: () => SettingsBloc(settingsRepository: repository),
      act: (bloc) => bloc.add(const UpdateLocale('en')),
      expect: () => <SettingsState>[],
    );
  });
}
