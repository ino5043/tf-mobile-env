import 'package:equatable/equatable.dart';

/// Application settings for study plan configuration.
class AppSettings extends Equatable {
  final int dailyNewCardLimit;
  final int dailyReviewCardLimit;
  final String? claudeApiKey;
  final double ttsSpeed;
  final bool autoReadAloud;

  const AppSettings({
    this.dailyNewCardLimit = 10,
    this.dailyReviewCardLimit = 20,
    this.claudeApiKey,
    this.ttsSpeed = 1.0,
    this.autoReadAloud = false,
  });

  AppSettings copyWith({
    int? dailyNewCardLimit,
    int? dailyReviewCardLimit,
    String? claudeApiKey,
    double? ttsSpeed,
    bool? autoReadAloud,
  }) {
    return AppSettings(
      dailyNewCardLimit: dailyNewCardLimit ?? this.dailyNewCardLimit,
      dailyReviewCardLimit: dailyReviewCardLimit ?? this.dailyReviewCardLimit,
      claudeApiKey: claudeApiKey ?? this.claudeApiKey,
      ttsSpeed: ttsSpeed ?? this.ttsSpeed,
      autoReadAloud: autoReadAloud ?? this.autoReadAloud,
    );
  }

  @override
  List<Object?> get props => [
        dailyNewCardLimit,
        dailyReviewCardLimit,
        claudeApiKey,
        ttsSpeed,
        autoReadAloud,
      ];
}
