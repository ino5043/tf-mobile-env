import 'package:flutter_test/flutter_test.dart';

import 'package:educards/features/settings/data/models/app_settings_model.dart';
import 'package:educards/features/settings/domain/entities/app_settings.dart';

void main() {
  group('AppSettingsModel', () {
    test('fromEntity preserves all fields', () {
      const entity = AppSettings(
        dailyNewCardLimit: 15,
        dailyReviewCardLimit: 30,
        claudeApiKey: 'sk-test',
        ttsSpeed: 1.5,
        autoReadAloud: true,
      );

      final model = AppSettingsModel.fromEntity(entity);

      expect(model.dailyNewCardLimit, 15);
      expect(model.dailyReviewCardLimit, 30);
      expect(model.claudeApiKey, 'sk-test');
      expect(model.ttsSpeed, 1.5);
      expect(model.autoReadAloud, true);
    });

    test('toEntity preserves all fields', () {
      const model = AppSettingsModel(
        dailyNewCardLimit: 20,
        dailyReviewCardLimit: 40,
        claudeApiKey: 'key-123',
        ttsSpeed: 0.8,
        autoReadAloud: true,
      );

      final entity = model.toEntity();

      expect(entity.dailyNewCardLimit, 20);
      expect(entity.dailyReviewCardLimit, 40);
      expect(entity.claudeApiKey, 'key-123');
      expect(entity.ttsSpeed, 0.8);
      expect(entity.autoReadAloud, true);
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
        ttsSpeed: 1.2,
        autoReadAloud: true,
      );

      final roundTripped =
          AppSettingsModel.fromEntity(original).toEntity();

      expect(roundTripped, original);
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

    test('copyWith autoReadAloud', () {
      const settings = AppSettings();
      final updated = settings.copyWith(autoReadAloud: true);

      expect(updated.autoReadAloud, true);
      expect(updated.ttsSpeed, 1.0); // unchanged
    });

    test('equatable includes ttsSpeed and autoReadAloud', () {
      const a = AppSettings(ttsSpeed: 1.0, autoReadAloud: false);
      const b = AppSettings(ttsSpeed: 1.0, autoReadAloud: false);
      const c = AppSettings(ttsSpeed: 1.5, autoReadAloud: false);

      expect(a, b);
      expect(a, isNot(c));
    });
  });
}
