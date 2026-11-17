import 'package:hive/hive.dart';

import 'package:educards/core/ai/ai_provider.dart';
import '../../domain/entities/app_settings.dart';

/// Hive に保存する設定。
///
/// 欄の番号は変えない。2 番は以前 Claude の API キーを平文で入れていた欄で、
/// 今は古いデータを安全な保管場所へ移すために読むだけにしている（書くときは空にする）。
class AppSettingsModel {
  final int dailyNewCardLimit;
  final int dailyReviewCardLimit;

  /// 以前の版で保存された Claude のキー。移し替えが済めば null になる。
  final String? legacyClaudeApiKey;
  final String? aiProvider;
  final double ttsSpeed;
  final bool autoReadAloud;
  final String? locale;

  const AppSettingsModel({
    required this.dailyNewCardLimit,
    required this.dailyReviewCardLimit,
    this.legacyClaudeApiKey,
    this.aiProvider,
    this.ttsSpeed = 1.0,
    this.autoReadAloud = false,
    this.locale,
  });

  factory AppSettingsModel.fromEntity(AppSettings entity) {
    return AppSettingsModel(
      dailyNewCardLimit: entity.dailyNewCardLimit,
      dailyReviewCardLimit: entity.dailyReviewCardLimit,
      aiProvider: entity.aiProvider.name,
      ttsSpeed: entity.ttsSpeed,
      autoReadAloud: entity.autoReadAloud,
      locale: entity.locale,
    );
  }

  AppSettings toEntity() {
    return AppSettings(
      dailyNewCardLimit: dailyNewCardLimit,
      dailyReviewCardLimit: dailyReviewCardLimit,
      aiProvider: AiProvider.fromName(aiProvider),
      ttsSpeed: ttsSpeed,
      autoReadAloud: autoReadAloud,
      locale: locale,
    );
  }

  /// 古いキーを消した写しを返す（ほかの欄はそのまま）。
  AppSettingsModel withoutLegacyKey() => AppSettingsModel(
        dailyNewCardLimit: dailyNewCardLimit,
        dailyReviewCardLimit: dailyReviewCardLimit,
        aiProvider: aiProvider,
        ttsSpeed: ttsSpeed,
        autoReadAloud: autoReadAloud,
        locale: locale,
      );
}

class AppSettingsModelAdapter extends TypeAdapter<AppSettingsModel> {
  @override
  final int typeId = 4;

  @override
  AppSettingsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return AppSettingsModel(
      dailyNewCardLimit: fields[0] as int? ?? 10,
      dailyReviewCardLimit: fields[1] as int? ?? 20,
      legacyClaudeApiKey: fields[2] as String?,
      ttsSpeed: (fields[3] as double?) ?? 1.0,
      autoReadAloud: (fields[4] as bool?) ?? false,
      locale: fields[5] as String?,
      aiProvider: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, AppSettingsModel obj) {
    writer.writeByte(7);
    writer.writeByte(0);
    writer.write(obj.dailyNewCardLimit);
    writer.writeByte(1);
    writer.write(obj.dailyReviewCardLimit);
    writer.writeByte(2);
    writer.write(obj.legacyClaudeApiKey);
    writer.writeByte(3);
    writer.write(obj.ttsSpeed);
    writer.writeByte(4);
    writer.write(obj.autoReadAloud);
    writer.writeByte(5);
    writer.write(obj.locale);
    writer.writeByte(6);
    writer.write(obj.aiProvider);
  }
}
