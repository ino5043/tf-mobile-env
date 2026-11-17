import 'package:hive/hive.dart';

import 'package:educards/features/deck/domain/entities/deck.dart';
import 'flashcard_model.dart';

class DeckModel {
  final String id;
  final String title;
  final String description;
  final List<FlashcardModel> cards;
  final DateTime createdAt;
  final DateTime updatedAt;

  DeckModel({
    required this.id,
    required this.title,
    required this.description,
    required this.cards,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DeckModel.fromEntity(Deck entity) {
    return DeckModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      cards: entity.cards.map((c) => FlashcardModel.fromEntity(c)).toList(),
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  Deck toEntity() {
    return Deck(
      id: id,
      title: title,
      description: description,
      cards: cards.map((c) => c.toEntity()).toList(),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class DeckModelAdapter extends TypeAdapter<DeckModel> {
  @override
  final int typeId = 0;

  @override
  DeckModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return DeckModel(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      cards: (fields[3] as List).cast<FlashcardModel>(),
      createdAt: fields[4] as DateTime,
      updatedAt: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, DeckModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.cards)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.updatedAt);
  }
}
