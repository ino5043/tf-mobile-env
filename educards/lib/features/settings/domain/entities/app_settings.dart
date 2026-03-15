import 'package:equatable/equatable.dart';

/// Application settings for study plan configuration.
class AppSettings extends Equatable {
  final int dailyNewCardLimit;
  final int dailyReviewCardLimit;
  final String? claudeApiKey;

  const AppSettings({
    this.dailyNewCardLimit = 10,
    this.dailyReviewCardLimit = 20,
    this.claudeApiKey,
  });

  AppSettings copyWith({
    int? dailyNewCardLimit,
    int? dailyReviewCardLimit,
    String? claudeApiKey,
  }) {
    return AppSettings(
      dailyNewCardLimit: dailyNewCardLimit ?? this.dailyNewCardLimit,
      dailyReviewCardLimit: dailyReviewCardLimit ?? this.dailyReviewCardLimit,
      claudeApiKey: claudeApiKey ?? this.claudeApiKey,
    );
  }

  @override
  List<Object?> get props => [dailyNewCardLimit, dailyReviewCardLimit, claudeApiKey];
}
