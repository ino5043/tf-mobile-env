import 'package:hive/hive.dart';

import 'package:educards/features/progress/domain/entities/study_stats.dart';

class StudyStatsModel {
  final DateTime date;
  final int cardsReviewed;
  final int correctCount;
  final int incorrectCount;

  StudyStatsModel({
    required this.date,
    required this.cardsReviewed,
    required this.correctCount,
    required this.incorrectCount,
  });

  factory StudyStatsModel.fromEntity(StudyStats entity) {
    return StudyStatsModel(
      date: entity.date,
      cardsReviewed: entity.cardsReviewed,
      correctCount: entity.correctCount,
      incorrectCount: entity.incorrectCount,
    );
  }

  StudyStats toEntity() {
    return StudyStats(
      date: date,
      cardsReviewed: cardsReviewed,
      correctCount: correctCount,
      incorrectCount: incorrectCount,
    );
  }
}

class StudyStatsModelAdapter extends TypeAdapter<StudyStatsModel> {
  @override
  final int typeId = 3;

  @override
  StudyStatsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return StudyStatsModel(
      date: fields[0] as DateTime,
      cardsReviewed: fields[1] as int,
      correctCount: fields[2] as int,
      incorrectCount: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, StudyStatsModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.cardsReviewed)
      ..writeByte(2)
      ..write(obj.correctCount)
      ..writeByte(3)
      ..write(obj.incorrectCount);
  }
}
