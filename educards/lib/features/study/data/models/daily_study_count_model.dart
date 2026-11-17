import 'package:hive/hive.dart';

class DailyStudyCountModel {
  final DateTime date;
  final int newCardsStudied;
  final int reviewCardsStudied;

  const DailyStudyCountModel({
    required this.date,
    required this.newCardsStudied,
    required this.reviewCardsStudied,
  });
}

class DailyStudyCountModelAdapter extends TypeAdapter<DailyStudyCountModel> {
  @override
  final int typeId = 5;

  @override
  DailyStudyCountModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return DailyStudyCountModel(
      date: fields[0] as DateTime,
      newCardsStudied: fields[1] as int? ?? 0,
      reviewCardsStudied: fields[2] as int? ?? 0,
    );
  }

  @override
  void write(BinaryWriter writer, DailyStudyCountModel obj) {
    writer.writeByte(3);
    writer.writeByte(0);
    writer.write(obj.date);
    writer.writeByte(1);
    writer.write(obj.newCardsStudied);
    writer.writeByte(2);
    writer.write(obj.reviewCardsStudied);
  }
}
