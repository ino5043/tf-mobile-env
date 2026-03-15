import 'package:equatable/equatable.dart';

/// Value Object: consecutive study day tracking.
class StreakInfo extends Equatable {
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastStudyDate;

  const StreakInfo({
    required this.currentStreak,
    required this.longestStreak,
    this.lastStudyDate,
  });

  factory StreakInfo.empty() {
    return const StreakInfo(
      currentStreak: 0,
      longestStreak: 0,
    );
  }

  bool get isActiveToday {
    if (lastStudyDate == null) return false;
    final now = DateTime.now();
    return lastStudyDate!.year == now.year &&
        lastStudyDate!.month == now.month &&
        lastStudyDate!.day == now.day;
  }

  @override
  List<Object?> get props => [currentStreak, longestStreak, lastStudyDate];
}
