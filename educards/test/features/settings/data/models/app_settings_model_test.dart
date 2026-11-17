import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:educards/core/ai/ai_provider.dart';
import 'package:educards/features/settings/data/models/app_settings_model.dart';
import 'package:educards/features/settings/domain/entities/app_settings.dart';

void main() {
  group('AppSettingsModel', () {
    test('fromEntity preserves all fields', () {
      const entity = AppSettings(
        dailyNewCardLimit: 15,
        dailyReviewCardLimit: 30,
        aiProvider: AiProvider.gemini,
        ttsSpeed: 1.5,
        autoReadAloud: true,
        locale: 'ja',
      );

      final model = AppSettingsModel.fromEntity(entity);

      expect(model.dailyNewCardLimit, 15);
      expect(model.dailyReviewCardLimit, 30);
      expect(model.aiProvider, 'gemini');
      expect(model.ttsSpeed, 1.5);
      expect(model.autoReadAloud, true);
      expect(model.locale, 'ja');
    });

    test('never carries an API key (keys live in secure storage)', () {
      final model = AppSettingsModel.fromEntity(const AppSettings());
      expect(model.legacyClaudeApiKey, isNull);
    });

    test('toEntity preserves all fields', () {
      const model = AppSettingsModel(
        dailyNewCardLimit: 20,
        dailyReviewCardLimit: 40,
        aiProvider: 'openai',
        ttsSpeed: 0.8,
        autoReadAloud: true,
        locale: 'en',
      );

      final entity = model.toEntity();

      expect(entity.dailyNewCardLimit, 20);
      expect(entity.dailyReviewCardLimit, 40);
      expect(entity.aiProvider, AiProvider.openai);
      expect(entity.ttsSpeed, 0.8);
      expect(entity.autoReadAloud, true);
      expect(entity.locale, 'en');
    });

    test('an unknown or missing provider falls back to Claude', () {
      const unknown = AppSettingsModel(
        dailyNewCardLimit: 10,
        dailyReviewCardLimit: 20,
        aiProvider: 'something-else',
      );
      const missing = AppSettingsModel(
        dailyNewCardLimit: 10,
        dailyReviewCardLimit: 20,
      );

      expect(unknown.toEntity().aiProvider, AiProvider.claude);
      expect(missing.toEntity().aiProvider, AiProvider.claude);
    });

    test('default values for ttsSpeed and autoReadAloud', () {
      const model = AppSettingsModel(
        dailyNewCardLimit: 10,
        dailyReviewCardLimit: 20,
      );

      expect(model.ttsSpeed, 1.0);
      expect(model.autoReadAloud, false);
    });

    test('toEntity and fromEntity roundtrip', () {
      const original = AppSettings(
        dailyNewCardLimit: 5,
        dailyReviewCardLimit: 50,
        aiProvider: AiProvider.openai,
        ttsSpeed: 1.2,
        autoReadAloud: true,
      );

      final roundTripped =
          AppSettingsModel.fromEntity(original).toEntity();

      expect(roundTripped, original);
    });
  });

  group('AppSettingsModelAdapter', () {
    test('writes and reads the provider through Hive', () async {
      Hive.init('./.dart_tool/test_hive');
      if (!Hive.isAdapterRegistered(4)) {
        Hive.registerAdapter(AppSettingsModelAdapter());
      }
      final box = await Hive.openBox<AppSettingsModel>('adapter_test');
      await box.put(
        's',
        const AppSettingsModel(
          dailyNewCardLimit: 7,
          dailyReviewCardLimit: 8,
          aiProvider: 'gemini',
        ),
      );
      await box.close();

      final reopened = await Hive.openBox<AppSettingsModel>('adapter_test');
      final read = reopened.get('s')!;
      expect(read.aiProvider, 'gemini');
      expect(read.legacyClaudeApiKey, isNull);
      expect(read.dailyNewCardLimit, 7);
      await reopened.deleteFromDisk();
    });
  });

  group('AppSettings entity', () {
    test('copyWith ttsSpeed', () {
      const settings = AppSettings();
      final updated = settings.copyWith(ttsSpeed: 1.5);

      expect(updated.ttsSpeed, 1.5);
      expect(updated.dailyNewCardLimit, 10); // unchanged
      expect(updated.autoReadAloud, false); // unchanged
    });

    test('copyWith aiProvider', () {
      const settings = AppSettings();
      expect(settings.aiProvider, AiProvider.claude);

      final updated = settings.copyWith(aiProvider: AiProvider.gemini);
      expect(updated.aiProvider, AiProvider.gemini);
      expect(updated.ttsSpeed, 1.0); // unchanged
    });

    test('copyWith autoReadAloud', () {
      const settings = AppSettings();
      final updated = settings.copyWith(autoReadAloud: true);

      expect(updated.autoReadAloud, true);
      expect(updated.ttsSpeed, 1.0); // unchanged
    });

    test('equatable includes ttsSpeed, autoReadAloud and aiProvider', () {
      const a = AppSettings(ttsSpeed: 1.0, autoReadAloud: false);
      const b = AppSettings(ttsSpeed: 1.0, autoReadAloud: false);
      const c = AppSettings(ttsSpeed: 1.5, autoReadAloud: false);
      const d = AppSettings(aiProvider: AiProvider.openai);

      expect(a, b);
      expect(a, isNot(c));
      expect(a, isNot(d));
    });
  });
}
