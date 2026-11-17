import 'package:hive/hive.dart';

import 'package:educards/features/deck/domain/entities/card_type.dart';
import 'package:educards/features/deck/domain/entities/flashcard.dart';
import 'package:educards/features/study/domain/entities/spaced_repetition_data.dart';

class FlashcardModel {
  final String id;
  final String deckId;
  final String front;
  final String back;
  final double easeFactor;
  final int interval;
  final int repetitions;
  final DateTime nextReviewDate;
  final int masteryIndex;
  final DateTime createdAt;
  final int cardTypeIndex;
  final String metadata;

  FlashcardModel({
    required this.id,
    required this.deckId,
    required this.front,
    required this.back,
    required this.easeFactor,
    required this.interval,
    required this.repetitions,
    required this.nextReviewDate,
    required this.masteryIndex,
    required this.createdAt,
    this.cardTypeIndex = 0,
    this.metadata = '',
  });

  factory FlashcardModel.fromEntity(Flashcard entity) {
    return FlashcardModel(
      id: entity.id,
      deckId: entity.deckId,
      front: entity.front,
      back: entity.back,
      easeFactor: entity.srData.easeFactor,
      interval: entity.srData.interval,
      repetitions: entity.srData.repetitions,
      nextReviewDate: entity.srData.nextReviewDate,
      masteryIndex: entity.srData.mastery.index,
      createdAt: entity.createdAt,
      cardTypeIndex: entity.cardType.index,
      metadata: entity.metadata,
    );
  }

  Flashcard toEntity() {
    return Flashcard(
      id: id,
      deckId: deckId,
      front: front,
      back: back,
      cardType: cardTypeIndex < CardType.values.length
          ? CardType.values[cardTypeIndex]
          : CardType.basic,
      metadata: metadata,
      srData: SpacedRepetitionData(
        easeFactor: easeFactor,
        interval: interval,
        repetitions: repetitions,
        nextReviewDate: nextReviewDate,
        mastery: MasteryLevel.values[masteryIndex],
      ),
      createdAt: createdAt,
    );
  }
}

class FlashcardModelAdapter extends TypeAdapter<FlashcardModel> {
  @override
  final int typeId = 1;

  @override
  FlashcardModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return FlashcardModel(
      id: fields[0] as String,
      deckId: fields[1] as String,
      front: fields[2] as String,
      back: fields[3] as String,
      easeFactor: fields[4] as double,
      interval: fields[5] as int,
      repetitions: fields[6] as int,
      nextReviewDate: fields[7] as DateTime,
      masteryIndex: fields[8] as int,
      createdAt: fields[9] as DateTime,
      // Backward compatible: old data has only 10 fields
      cardTypeIndex: fields[10] as int? ?? 0,
      metadata: fields[11] as String? ?? '',
    );
  }

  @override
  void write(BinaryWriter writer, FlashcardModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.deckId)
      ..writeByte(2)
      ..write(obj.front)
      ..writeByte(3)
      ..write(obj.back)
      ..writeByte(4)
      ..write(obj.easeFactor)
      ..writeByte(5)
      ..write(obj.interval)
      ..writeByte(6)
      ..write(obj.repetitions)
      ..writeByte(7)
      ..write(obj.nextReviewDate)
      ..writeByte(8)
      ..write(obj.masteryIndex)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.cardTypeIndex)
      ..writeByte(11)
      ..write(obj.metadata);
  }
}
