import 'package:flutter_test/flutter_test.dart';

import '../../../../fixtures/test_fixtures.dart';

void main() {
  group('Flashcard', () {
    test('isDue should return true when nextReviewDate is in the past', () {
      final card = TestFixtures.dueFlashcard;
      expect(card.isDue, isTrue);
    });

    test('isDue should return false when nextReviewDate is in the future', () {
      final card = TestFixtures.notDueFlashcard;
      expect(card.isDue, isFalse);
    });

    test('copyWith should create new instance with updated srData', () {
      final card = TestFixtures.createFlashcard();
      final newSrData = TestFixtures.learningSrData;
      final updated = card.copyWith(srData: newSrData);

      expect(updated.srData, newSrData);
      expect(updated.id, card.id);
      expect(updated.front, card.front);
    });

    test('should support equality via Equatable', () {
      final card1 = TestFixtures.createFlashcard();
      final card2 = TestFixtures.createFlashcard();
      expect(card1, card2);
    });
  });
}
