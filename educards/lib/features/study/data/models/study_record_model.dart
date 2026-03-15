import 'package:hive/hive.dart';

class StudyRecordModel {
  final String cardId;
  final String deckId;
  final int ratingQuality;
  final DateTime reviewedAt;

  StudyRecordModel({
    required this.cardId,
    required this.deckId,
    required this.ratingQuality,
    required this.reviewedAt,
  });
}

class StudyRecordModelAdapter extends TypeAdapter<StudyRecordModel> {
  @override
  final int typeId = 2;

  @override
  StudyRecordModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return StudyRecordModel(
      cardId: fields[0] as String,
      deckId: fields[1] as String,
      ratingQuality: fields[2] as int,
      reviewedAt: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, StudyRecordModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.cardId)
      ..writeByte(1)
      ..write(obj.deckId)
      ..writeByte(2)
      ..write(obj.ratingQuality)
      ..writeByte(3)
      ..write(obj.reviewedAt);
  }
}
