import 'package:flutter_test/flutter_test.dart';

import 'package:educards/features/study/domain/entities/spaced_repetition_data.dart';
import '../../../../fixtures/test_fixtures.dart';

void main() {
  group('Deck', () {
    test('should return correct totalCards', () {
      final deck = TestFixtures.createDeck();
      expect(deck.totalCards, 2);
    });

    test('should return 0 totalCards for empty deck', () {
      final deck = TestFixtures.emptyDeck;
      expect(deck.totalCards, 0);
    });

    test('should return correct dueCards count', () {
      final deck = TestFixtures.createDeck();
      // dueFlashcard is due, notDueFlashcard is not
      expect(deck.dueCards, 1);
    });

    test('should return 0 masteryPercentage for empty deck', () {
      final deck = TestFixtures.emptyDeck;
      expect(deck.masteryPercentage, 0);
    });

    test('should calculate masteryPercentage correctly', () {
      final deck = TestFixtures.createDeck(
        cards: [
          TestFixtures.createFlashcard(
            id: 'c1',
            srData: TestFixtures.masteredSrData,
          ),
          TestFixtures.createFlashcard(
            id: 'c2',
            srData: TestFixtures.reviewSrData,
          ),
          TestFixtures.createFlashcard(
            id: 'c3',
            srData: SpacedRepetitionData.initial(),
          ),
        ],
      );
      // 2 out of 3 are mastered or review
      expect(deck.masteryPercentage, closeTo(2 / 3, 0.01));
    });

    test('copyWith should create new instance with updated fields', () {
      final deck = TestFixtures.createDeck();
      final updated = deck.copyWith(title: 'New Title');

      expect(updated.title, 'New Title');
      expect(updated.id, deck.id);
      expect(updated.cards, deck.cards);
    });

    test('should support equality via Equatable', () {
      final deck1 = TestFixtures.createDeck();
      final deck2 = TestFixtures.createDeck();
      expect(deck1, deck2);
    });
  });
}
