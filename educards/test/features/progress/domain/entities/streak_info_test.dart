import 'package:flutter_test/flutter_test.dart';

import 'package:educards/features/progress/domain/entities/streak_info.dart';

void main() {
  group('StreakInfo', () {
    test('isActiveToday should return true when lastStudyDate is today', () {
      final now = DateTime.now();
      final streak = StreakInfo(
        currentStreak: 1,
        longestStreak: 1,
        lastStudyDate: now,
      );
      expect(streak.isActiveToday, isTrue);
    });

    test('isActiveToday should return false when lastStudyDate is yesterday', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final streak = StreakInfo(
        currentStreak: 0,
        longestStreak: 1,
        lastStudyDate: yesterday,
      );
      expect(streak.isActiveToday, isFalse);
    });

    test('isActiveToday should return false when lastStudyDate is null', () {
      final streak = StreakInfo.empty();
      expect(streak.isActiveToday, isFalse);
    });

    test('empty factory should create zeroed streak', () {
      final streak = StreakInfo.empty();
      expect(streak.currentStreak, 0);
      expect(streak.longestStreak, 0);
      expect(streak.lastStudyDate, isNull);
    });
  });
}
