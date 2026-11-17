import 'package:equatable/equatable.dart';

import 'package:educards/core/ai/ai_provider.dart';

/// Application settings for study plan configuration.
///
/// API キーはここには持たない。端末の安全な保管場所に別に置く
/// （[ApiKeyRepository]）。
class AppSettings extends Equatable {
  final int dailyNewCardLimit;
  final int dailyReviewCardLimit;

  /// カード作りに使う AI。
  final AiProvider aiProvider;
  final double ttsSpeed;
  final bool autoReadAloud;
  /// Locale code ('en', 'ja') or null for system default.
  final String? locale;

  const AppSettings({
    this.dailyNewCardLimit = 10,
    this.dailyReviewCardLimit = 20,
    this.aiProvider = AiProvider.claude,
    this.ttsSpeed = 1.0,
    this.autoReadAloud = false,
    this.locale,
  });

  AppSettings copyWith({
    int? dailyNewCardLimit,
    int? dailyReviewCardLimit,
    AiProvider? aiProvider,
    double? ttsSpeed,
    bool? autoReadAloud,
    String? Function()? locale,
  }) {
    return AppSettings(
      dailyNewCardLimit: dailyNewCardLimit ?? this.dailyNewCardLimit,
      dailyReviewCardLimit: dailyReviewCardLimit ?? this.dailyReviewCardLimit,
      aiProvider: aiProvider ?? this.aiProvider,
      ttsSpeed: ttsSpeed ?? this.ttsSpeed,
      autoReadAloud: autoReadAloud ?? this.autoReadAloud,
      locale: locale != null ? locale() : this.locale,
    );
  }

  @override
  List<Object?> get props => [
        dailyNewCardLimit,
        dailyReviewCardLimit,
        aiProvider,
        ttsSpeed,
        autoReadAloud,
        locale,
      ];
}
