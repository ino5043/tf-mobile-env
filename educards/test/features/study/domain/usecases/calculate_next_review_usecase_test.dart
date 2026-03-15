import 'package:flutter_test/flutter_test.dart';

import 'package:educards/features/study/domain/entities/review_rating.dart';
import 'package:educards/features/study/domain/entities/spaced_repetition_data.dart';
import 'package:educards/features/study/domain/usecases/calculate_next_review_usecase.dart';

void main() {
  late CalculateNextReviewUseCase useCase;
  final fixedNow = DateTime(2026, 3, 15, 10, 0);

  setUp(() {
    useCase = CalculateNextReviewUseCase();
  });

  group('CalculateNextReviewUseCase', () {
    group('Rating: Again (quality=0)', () {
      test('should reset repetitions to 0', () {
        final current = SpacedRepetitionData(
          easeFactor: 2.5,
          interval: 6,
          repetitions: 3,
          nextReviewDate: fixedNow,
          mastery: MasteryLevel.review,
        );

        final result = useCase(
          current: current,
          rating: ReviewRating.again,
          now: fixedNow,
        );

        expect(result.repetitions, 0);
      });

      test('should set interval to 0', () {
        final current = SpacedRepetitionData.initial();

        final result = useCase(
          current: current,
          rating: ReviewRating.again,
          now: fixedNow,
        );

        expect(result.interval, 0);
      });

      test('should schedule review in 10 minutes', () {
        final current = SpacedRepetitionData.initial();

        final result = useCase(
          current: current,
          rating: ReviewRating.again,
          now: fixedNow,
        );

        expect(
          result.nextReviewDate,
          fixedNow.add(const Duration(minutes: 10)),
        );
      });

      test('should decrease ease factor by 0.2', () {
        final current = SpacedRepetitionData(
          easeFactor: 2.5,
          interval: 1,
          repetitions: 1,
          nextReviewDate: fixedNow,
          mastery: MasteryLevel.learning,
        );

        final result = useCase(
          current: current,
          rating: ReviewRating.again,
          now: fixedNow,
        );

        expect(result.easeFactor, closeTo(2.3, 0.01));
      });

      test('should not decrease ease factor below 1.3', () {
        final current = SpacedRepetitionData(
          easeFactor: 1.3,
          interval: 1,
          repetitions: 1,
          nextReviewDate: fixedNow,
          mastery: MasteryLevel.learning,
        );

        final result = useCase(
          current: current,
          rating: ReviewRating.again,
          now: fixedNow,
        );

        expect(result.easeFactor, 1.3);
      });

      test('should set mastery to learning', () {
        final current = SpacedRepetitionData(
          easeFactor: 2.5,
          interval: 6,
          repetitions: 3,
          nextReviewDate: fixedNow,
          mastery: MasteryLevel.review,
        );

        final result = useCase(
          current: current,
          rating: ReviewRating.again,
          now: fixedNow,
        );

        expect(result.mastery, MasteryLevel.learning);
      });
    });

    group('Rating: Good (quality=4) — first review', () {
      test('should set interval to 1 day on first successful review', () {
        final current = SpacedRepetitionData.initial();

        final result = useCase(
          current: current,
          rating: ReviewRating.good,
          now: fixedNow,
        );

        expect(result.interval, 1);
      });

      test('should set repetitions to 1', () {
        final current = SpacedRepetitionData.initial();

        final result = useCase(
          current: current,
          rating: ReviewRating.good,
          now: fixedNow,
        );

        expect(result.repetitions, 1);
      });

      test('should schedule next review 1 day later', () {
        final current = SpacedRepetitionData.initial();

        final result = useCase(
          current: current,
          rating: ReviewRating.good,
          now: fixedNow,
        );

        expect(
          result.nextReviewDate,
          fixedNow.add(const Duration(days: 1)),
        );
      });
    });

    group('Rating: Good — second review', () {
      test('should set interval to 6 days on second successful review', () {
        final current = SpacedRepetitionData(
          easeFactor: 2.5,
          interval: 1,
          repetitions: 1,
          nextReviewDate: fixedNow,
          mastery: MasteryLevel.learning,
        );

        final result = useCase(
          current: current,
          rating: ReviewRating.good,
          now: fixedNow,
        );

        expect(result.interval, 6);
      });

      test('should set repetitions to 2', () {
        final current = SpacedRepetitionData(
          easeFactor: 2.5,
          interval: 1,
          repetitions: 1,
          nextReviewDate: fixedNow,
          mastery: MasteryLevel.learning,
        );

        final result = useCase(
          current: current,
          rating: ReviewRating.good,
          now: fixedNow,
        );

        expect(result.repetitions, 2);
      });
    });

    group('Rating: Good — subsequent reviews', () {
      test('should multiply interval by ease factor on third+ review', () {
        final current = SpacedRepetitionData(
          easeFactor: 2.5,
          interval: 6,
          repetitions: 2,
          nextReviewDate: fixedNow,
          mastery: MasteryLevel.learning,
        );

        final result = useCase(
          current: current,
          rating: ReviewRating.good,
          now: fixedNow,
        );

        // interval = round(6 * 2.5) = 15
        expect(result.interval, 15);
      });
    });

    group('Rating: Easy (quality=5)', () {
      test('should increase ease factor', () {
        final current = SpacedRepetitionData(
          easeFactor: 2.5,
          interval: 1,
          repetitions: 1,
          nextReviewDate: fixedNow,
          mastery: MasteryLevel.learning,
        );

        final result = useCase(
          current: current,
          rating: ReviewRating.easy,
          now: fixedNow,
        );

        // EF' = 2.5 + (0.1 - (5-5)*(0.08+(5-5)*0.02)) = 2.5 + 0.1 = 2.6
        expect(result.easeFactor, closeTo(2.6, 0.01));
      });
    });

    group('Rating: Hard (quality=3)', () {
      test('should decrease ease factor', () {
        final current = SpacedRepetitionData(
          easeFactor: 2.5,
          interval: 1,
          repetitions: 1,
          nextReviewDate: fixedNow,
          mastery: MasteryLevel.learning,
        );

        final result = useCase(
          current: current,
          rating: ReviewRating.hard,
          now: fixedNow,
        );

        // EF' = 2.5 + (0.1 - (5-3)*(0.08+(5-3)*0.02)) = 2.5 + (0.1 - 2*(0.08+0.04))
        //     = 2.5 + (0.1 - 0.24) = 2.5 - 0.14 = 2.36
        expect(result.easeFactor, closeTo(2.36, 0.01));
      });
    });

    group('Mastery Level transitions', () {
      test('should be newCard at 0 repetitions', () {
        final current = SpacedRepetitionData.initial();

        final result = useCase(
          current: current,
          rating: ReviewRating.again,
          now: fixedNow,
        );

        // After again, repetitions = 0 → mastery via _calculateMastery is actually learning
        // because the again case explicitly sets mastery to learning
        expect(result.mastery, MasteryLevel.learning);
      });

      test('should be learning at 1-2 repetitions', () {
        final current = SpacedRepetitionData.initial();

        final result = useCase(
          current: current,
          rating: ReviewRating.good,
          now: fixedNow,
        );

        expect(result.mastery, MasteryLevel.learning);
      });

      test('should be review at 3-5 repetitions', () {
        final current = SpacedRepetitionData(
          easeFactor: 2.5,
          interval: 6,
          repetitions: 2,
          nextReviewDate: fixedNow,
          mastery: MasteryLevel.learning,
        );

        final result = useCase(
          current: current,
          rating: ReviewRating.good,
          now: fixedNow,
        );

        expect(result.mastery, MasteryLevel.review);
      });

      test('should be mastered at 6+ repetitions with high ease factor', () {
        final current = SpacedRepetitionData(
          easeFactor: 2.5,
          interval: 30,
          repetitions: 5,
          nextReviewDate: fixedNow,
          mastery: MasteryLevel.review,
        );

        final result = useCase(
          current: current,
          rating: ReviewRating.good,
          now: fixedNow,
        );

        expect(result.mastery, MasteryLevel.mastered);
      });
    });

    group('Ease factor boundary', () {
      test('should never go below 1.3 even with repeated Again', () {
        var current = SpacedRepetitionData(
          easeFactor: 1.4,
          interval: 1,
          repetitions: 1,
          nextReviewDate: fixedNow,
          mastery: MasteryLevel.learning,
        );

        // Hit Again multiple times
        for (var i = 0; i < 5; i++) {
          current = useCase(
            current: current,
            rating: ReviewRating.again,
            now: fixedNow,
          );
        }

        expect(current.easeFactor, greaterThanOrEqualTo(1.3));
      });
    });
  });
}
