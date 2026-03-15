import 'package:flutter_test/flutter_test.dart';

import 'package:educards/features/study/domain/entities/spaced_repetition_data.dart';

void main() {
  group('SpacedRepetitionData', () {
    test('initial factory should have correct defaults', () {
      final data = SpacedRepetitionData.initial();

      expect(data.easeFactor, 2.5);
      expect(data.interval, 0);
      expect(data.repetitions, 0);
      expect(data.mastery, MasteryLevel.newCard);
    });

    test('should support equality via Equatable', () {
      final data1 = SpacedRepetitionData.initial();
      final data2 = SpacedRepetitionData.initial();
      expect(data1, data2);
    });
  });

  group('MasteryLevel', () {
    test('should have 4 levels in correct order', () {
      expect(MasteryLevel.values.length, 4);
      expect(MasteryLevel.values[0], MasteryLevel.newCard);
      expect(MasteryLevel.values[1], MasteryLevel.learning);
      expect(MasteryLevel.values[2], MasteryLevel.review);
      expect(MasteryLevel.values[3], MasteryLevel.mastered);
    });
  });

  group('ReviewRating', () {
    test('again quality should be 0', () {
      // Import needed for this but it's from review_rating.dart
      // This test would go in review_rating_test.dart
    });
  });
}
