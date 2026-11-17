import 'package:equatable/equatable.dart';

/// Application settings for study plan configuration.
class AppSettings extends Equatable {
  final int dailyNewCardLimit;
  final int dailyReviewCardLimit;
  final String? claudeApiKey;
  final double ttsSpeed;
  final bool autoReadAloud;
  /// Locale code ('en', 'ja') or null for system default.
  final String? locale;

  const AppSettings({
    this.dailyNewCardLimit = 10,
    this.dailyReviewCardLimit = 20,
    this.claudeApiKey,
    this.ttsSpeed = 1.0,
    this.autoReadAloud = false,
    this.locale,
  });

  AppSettings copyWith({
    int? dailyNewCardLimit,
    int? dailyReviewCardLimit,
    String? claudeApiKey,
    double? ttsSpeed,
    bool? autoReadAloud,
    String? Function()? locale,
  }) {
    return AppSettings(
      dailyNewCardLimit: dailyNewCardLimit ?? this.dailyNewCardLimit,
      dailyReviewCardLimit: dailyReviewCardLimit ?? this.dailyReviewCardLimit,
      claudeApiKey: claudeApiKey ?? this.claudeApiKey,
      ttsSpeed: ttsSpeed ?? this.ttsSpeed,
      autoReadAloud: autoReadAloud ?? this.autoReadAloud,
      locale: locale != null ? locale() : this.locale,
    );
  }

  @override
  List<Object?> get props => [
        dailyNewCardLimit,
        dailyReviewCardLimit,
        claudeApiKey,
        ttsSpeed,
        autoReadAloud,
        locale,
      ];
}
