import 'package:flutter_test/flutter_test.dart';

import '../../../../fixtures/test_fixtures.dart';
import 'package:educards/features/progress/domain/entities/study_stats.dart';

void main() {
  group('StudyStats', () {
    test('accuracy should return correct ratio', () {
      final stats = TestFixtures.createStudyStats(
        cardsReviewed: 10,
        correctCount: 8,
      );
      expect(stats.accuracy, 0.8);
    });

    test('accuracy should return 0 when no cards reviewed', () {
      final stats = TestFixtures.createStudyStats(cardsReviewed: 0, correctCount: 0, incorrectCount: 0);
      expect(stats.accuracy, 0);
    });

    test('empty factory should create zeroed stats', () {
      final date = DateTime(2026, 3, 15);
      final stats = StudyStats.empty(date);
      expect(stats.cardsReviewed, 0);
      expect(stats.correctCount, 0);
      expect(stats.incorrectCount, 0);
      expect(stats.date, date);
    });
  });
}
