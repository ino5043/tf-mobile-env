import 'package:hive/hive.dart';

import '../../domain/entities/app_settings.dart';

class AppSettingsModel {
  final int dailyNewCardLimit;
  final int dailyReviewCardLimit;
  final String? claudeApiKey;
  final double ttsSpeed;
  final bool autoReadAloud;

  const AppSettingsModel({
    required this.dailyNewCardLimit,
    required this.dailyReviewCardLimit,
    this.claudeApiKey,
    this.ttsSpeed = 1.0,
    this.autoReadAloud = false,
  });

  factory AppSettingsModel.fromEntity(AppSettings entity) {
    return AppSettingsModel(
      dailyNewCardLimit: entity.dailyNewCardLimit,
      dailyReviewCardLimit: entity.dailyReviewCardLimit,
      claudeApiKey: entity.claudeApiKey,
      ttsSpeed: entity.ttsSpeed,
      autoReadAloud: entity.autoReadAloud,
    );
  }

  AppSettings toEntity() {
    return AppSettings(
      dailyNewCardLimit: dailyNewCardLimit,
      dailyReviewCardLimit: dailyReviewCardLimit,
      claudeApiKey: claudeApiKey,
      ttsSpeed: ttsSpeed,
      autoReadAloud: autoReadAloud,
    );
  }
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
      claudeApiKey: fields[2] as String?,
      ttsSpeed: (fields[3] as double?) ?? 1.0,
      autoReadAloud: (fields[4] as bool?) ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, AppSettingsModel obj) {
    writer.writeByte(5);
    writer.writeByte(0);
    writer.write(obj.dailyNewCardLimit);
    writer.writeByte(1);
    writer.write(obj.dailyReviewCardLimit);
    writer.writeByte(2);
    writer.write(obj.claudeApiKey);
    writer.writeByte(3);
    writer.write(obj.ttsSpeed);
    writer.writeByte(4);
    writer.write(obj.autoReadAloud);
  }
}
