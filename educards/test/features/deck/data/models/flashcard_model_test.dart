import 'package:flutter_test/flutter_test.dart';

import 'package:educards/features/deck/domain/entities/card_type.dart';
import 'package:educards/features/deck/domain/entities/flashcard.dart';
import 'package:educards/features/deck/data/models/flashcard_model.dart';
import 'package:educards/features/study/domain/entities/spaced_repetition_data.dart';

void main() {
  final now = DateTime(2026, 3, 15, 10, 0, 0);

  Flashcard _makeFlashcard({
    CardType cardType = CardType.basic,
    String metadata = '',
  }) {
    return Flashcard(
      id: 'card-1',
      deckId: 'deck-1',
      front: 'What is 2+2?',
      back: '4',
      cardType: cardType,
      metadata: metadata,
      srData: SpacedRepetitionData(
        easeFactor: 2.5,
        interval: 1,
        repetitions: 1,
        nextReviewDate: now,
        mastery: MasteryLevel.learning,
      ),
      createdAt: now,
    );
  }

  group('FlashcardModel', () {
    test('fromEntity preserves cardType and metadata for basic card', () {
      final entity = _makeFlashcard();
      final model = FlashcardModel.fromEntity(entity);

      expect(model.cardTypeIndex, 0);
      expect(model.metadata, '');
    });

    test('fromEntity preserves cardType and metadata for cloze card', () {
      final entity = _makeFlashcard(
        cardType: CardType.cloze,
        metadata: '{"blanks":["capital"]}',
      );
      final model = FlashcardModel.fromEntity(entity);

      expect(model.cardTypeIndex, CardType.cloze.index);
      expect(model.metadata, '{"blanks":["capital"]}');
    });

    test('toEntity reconstructs cardType and metadata', () {
      final model = FlashcardModel(
        id: 'card-1',
        deckId: 'deck-1',
        front: 'Q',
        back: 'A',
        easeFactor: 2.5,
        interval: 1,
        repetitions: 1,
        nextReviewDate: now,
        masteryIndex: 1,
        createdAt: now,
        cardTypeIndex: CardType.multiChoice.index,
        metadata: '{"options":["A","B","C","D"],"correctIndex":0}',
      );

      final entity = model.toEntity();

      expect(entity.cardType, CardType.multiChoice);
      expect(entity.metadata, '{"options":["A","B","C","D"],"correctIndex":0}');
    });

    test('toEntity defaults to basic when cardTypeIndex is 0', () {
      final model = FlashcardModel(
        id: 'card-1',
        deckId: 'deck-1',
        front: 'Q',
        back: 'A',
        easeFactor: 2.5,
        interval: 0,
        repetitions: 0,
        nextReviewDate: now,
        masteryIndex: 0,
        createdAt: now,
      );

      final entity = model.toEntity();

      expect(entity.cardType, CardType.basic);
      expect(entity.metadata, '');
    });

    test('toEntity handles unknown cardTypeIndex gracefully', () {
      final model = FlashcardModel(
        id: 'card-1',
        deckId: 'deck-1',
        front: 'Q',
        back: 'A',
        easeFactor: 2.5,
        interval: 0,
        repetitions: 0,
        nextReviewDate: now,
        masteryIndex: 0,
        createdAt: now,
        cardTypeIndex: 99,
        metadata: '',
      );

      final entity = model.toEntity();

      expect(entity.cardType, CardType.basic);
    });

    test('roundtrip preserves all fields', () {
      final original = _makeFlashcard(
        cardType: CardType.stepByStep,
        metadata: '{"hints":["hint1"],"steps":["step1"]}',
      );

      final model = FlashcardModel.fromEntity(original);
      final restored = model.toEntity();

      expect(restored.id, original.id);
      expect(restored.front, original.front);
      expect(restored.back, original.back);
      expect(restored.cardType, original.cardType);
      expect(restored.metadata, original.metadata);
      expect(restored.srData.easeFactor, original.srData.easeFactor);
    });
  });
}
