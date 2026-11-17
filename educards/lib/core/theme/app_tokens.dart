import 'package:flutter/material.dart';

/// EduCards のデザイントークンの正本（UI/UX 標準 3-2: 正本は 1 か所）。
///
/// 色はここにだけ書く。画面のコードは Theme.of(context).colorScheme か
/// AppColors（ThemeExtension）を通して使い、HEX を直接書かない（3-1・3-3）。
/// コントラスト比の計算結果は docs/design/color-contrast.md に記録している（3-5）。
/// 配色を決めた理由は docs/adr/ADR-004 にある（3-6）。
class AppPalette {
  AppPalette._();

  // ---- 明るい表示（ミント） ----
  static const lightPrimary = Color(0xFF00796B);
  static const lightOnPrimary = Color(0xFFFFFFFF);
  static const lightPrimaryContainer = Color(0xFFD9F3EE);
  static const lightOnPrimaryContainer = Color(0xFF004D43);
  static const lightTertiary = Color(0xFFB5471B); // ピーチ。強調と「学習中」
  static const lightOnTertiary = Color(0xFFFFFFFF);
  static const lightTertiaryContainer = Color(0xFFFFE6D9);
  static const lightOnTertiaryContainer = Color(0xFF7A2E0E);
  static const lightSurface = Color(0xFFFFFFFF); // 作業の面は白（ORG-010 K7）
  static const lightBackground = Color(0xFFF5FBFA); // 作業の面の外側の地
  static const lightSurfaceContainer = Color(0xFFEAF5F3);
  static const lightOnSurface = Color(0xFF1D2430);
  static const lightOnSurfaceVariant = Color(0xFF55616F); // 補足の文字（K2）
  static const lightOutline = Color(0xFF6E8783); // 境界の意味を持つ線（3:1 以上）
  static const lightOutlineVariant = Color(0xFFC9DCD8); // 飾りの線（K3）
  static const lightError = Color(0xFFCE0000); // DADS の error_text（K1）
  static const lightInfo = Color(0xFF2B4F76); // 情報（K6）

  // ---- 暗い表示 ----
  static const darkPrimary = Color(0xFF5FD4C2);
  static const darkOnPrimary = Color(0xFF00382F);
  static const darkPrimaryContainer = Color(0xFF00504A);
  static const darkOnPrimaryContainer = Color(0xFFB6F0E5);
  static const darkTertiary = Color(0xFFFFB596);
  static const darkOnTertiary = Color(0xFF5A1C00);
  static const darkTertiaryContainer = Color(0xFF7A2E0E);
  static const darkOnTertiaryContainer = Color(0xFFFFDBCC);
  static const darkSurface = Color(0xFF161E1D);
  static const darkBackground = Color(0xFF0F1716);
  static const darkSurfaceContainer = Color(0xFF1E2826);
  static const darkOnSurface = Color(0xFFE3EDEB);
  static const darkOnSurfaceVariant = Color(0xFFB3C5C1);
  static const darkOutline = Color(0xFF8AA39F);
  static const darkOutlineVariant = Color(0xFF3A4A47);
  static const darkError = Color(0xFFFFB4AB);
  static const darkInfo = Color(0xFFA9C7EA);

  // ---- フォーカスの表示（DADS のまま。配色を変えても変えない: 4-8） ----
  static const focusRing = Color(0xFFFFD43D);
  static const focusOutline = Color(0xFF000000);
}

/// 角の丸み（3.5）。同じ部品は全画面で同じ値にする（3-9）。
class AppRadius {
  AppRadius._();

  static const double sm = 8; // 札（Chip 以外の小さな印）
  static const double md = 16; // 入力欄、評価ボタン
  static const double lg = 20; // カード、一覧の項目
  static const double xl = 24; // フラッシュカード、ダイアログ
  static const double full = 999; // ボタン、Chip（丸いかわいさの中心）
}

/// colorScheme に無い、アプリ固有の役割の色。
///
/// 意味の色（成功・エラー・警告）は飾りに使わない（4-4）。習熟度と評価は
/// 意味の色ではない専用の役割として持ち、必ず文字やアイコンと組で使う（4-3）。
@immutable
class AppColors extends ThemeExtension<AppColors> {
  /// 習熟度の 4 段階（グラフの系列にも使う。面に対して 3:1 以上）
  final Color masteryNew;
  final Color masteryLearning;
  final Color masteryReview;
  final Color masteryMastered;

  /// 評価ボタンの 4 段階。キーの色の濃淡で表す（赤・緑の組を避ける: 4-15）
  final Color ratingAgain;
  final Color ratingHard;
  final Color ratingGood;
  final Color ratingEasy;

  /// 評価ボタンの文字の色（薄い 2 段・濃い 2 段で切り替える）
  final Color onRatingLight;
  final Color onRatingStrong;

  /// グラフの「正解」「不正解」。値はグラフの外の文字でも示す（4-14）
  final Color chartCorrect;
  final Color chartIncorrect;

  /// 「今日やるカード」など、注意を引きたいがエラーではないもの
  final Color highlight;
  final Color onHighlightContainer;
  final Color highlightContainer;

  /// 情報（ORG-010 K6）
  final Color info;

  /// 警告の文字とアイコン（ORG-010 K1。警告は黄の色相）
  final Color warningText;

  const AppColors({
    required this.masteryNew,
    required this.masteryLearning,
    required this.masteryReview,
    required this.masteryMastered,
    required this.ratingAgain,
    required this.ratingHard,
    required this.ratingGood,
    required this.ratingEasy,
    required this.onRatingLight,
    required this.onRatingStrong,
    required this.chartCorrect,
    required this.chartIncorrect,
    required this.highlight,
    required this.onHighlightContainer,
    required this.highlightContainer,
    required this.info,
    required this.warningText,
  });

  static const light = AppColors(
    masteryNew: Color(0xFF6B7B8D),
    masteryLearning: AppPalette.lightTertiary,
    masteryReview: Color(0xFF1565C0),
    masteryMastered: AppPalette.lightPrimary,
    ratingAgain: Color(0xFFEEF9F7),
    ratingHard: Color(0xFFC9EEE6),
    ratingGood: AppPalette.lightPrimary,
    ratingEasy: Color(0xFF00564C),
    onRatingLight: AppPalette.lightOnPrimaryContainer,
    onRatingStrong: AppPalette.lightOnPrimary,
    chartCorrect: AppPalette.lightPrimary,
    chartIncorrect: AppPalette.lightTertiary,
    highlight: AppPalette.lightTertiary,
    onHighlightContainer: AppPalette.lightOnTertiaryContainer,
    highlightContainer: AppPalette.lightTertiaryContainer,
    info: AppPalette.lightInfo,
    warningText: Color(0xFF927200),
  );

  static const dark = AppColors(
    masteryNew: Color(0xFFA9B6C4),
    masteryLearning: AppPalette.darkTertiary,
    masteryReview: Color(0xFF9CC7FF),
    masteryMastered: AppPalette.darkPrimary,
    ratingAgain: Color(0xFF1E2F2C),
    ratingHard: Color(0xFF2B4A45),
    ratingGood: AppPalette.darkPrimary,
    ratingEasy: Color(0xFF9EEBDD),
    onRatingLight: AppPalette.darkOnPrimaryContainer,
    onRatingStrong: AppPalette.darkOnPrimary,
    chartCorrect: AppPalette.darkPrimary,
    chartIncorrect: AppPalette.darkTertiary,
    highlight: AppPalette.darkTertiary,
    onHighlightContainer: AppPalette.darkOnTertiaryContainer,
    highlightContainer: AppPalette.darkTertiaryContainer,
    info: AppPalette.darkInfo,
    warningText: Color(0xFFF0CF5B),
  );

  /// 画面から使う入口。テーマに登録が無いときは明るい表示の値を返す
  static AppColors of(BuildContext context) =>
      Theme.of(context).extension<AppColors>() ?? light;

  @override
  AppColors copyWith({
    Color? masteryNew,
    Color? masteryLearning,
    Color? masteryReview,
    Color? masteryMastered,
    Color? ratingAgain,
    Color? ratingHard,
    Color? ratingGood,
    Color? ratingEasy,
    Color? onRatingLight,
    Color? onRatingStrong,
    Color? chartCorrect,
    Color? chartIncorrect,
    Color? highlight,
    Color? onHighlightContainer,
    Color? highlightContainer,
    Color? info,
    Color? warningText,
  }) {
    return AppColors(
      masteryNew: masteryNew ?? this.masteryNew,
      masteryLearning: masteryLearning ?? this.masteryLearning,
      masteryReview: masteryReview ?? this.masteryReview,
      masteryMastered: masteryMastered ?? this.masteryMastered,
      ratingAgain: ratingAgain ?? this.ratingAgain,
      ratingHard: ratingHard ?? this.ratingHard,
      ratingGood: ratingGood ?? this.ratingGood,
      ratingEasy: ratingEasy ?? this.ratingEasy,
      onRatingLight: onRatingLight ?? this.onRatingLight,
      onRatingStrong: onRatingStrong ?? this.onRatingStrong,
      chartCorrect: chartCorrect ?? this.chartCorrect,
      chartIncorrect: chartIncorrect ?? this.chartIncorrect,
      highlight: highlight ?? this.highlight,
      onHighlightContainer: onHighlightContainer ?? this.onHighlightContainer,
      highlightContainer: highlightContainer ?? this.highlightContainer,
      info: info ?? this.info,
      warningText: warningText ?? this.warningText,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColors(
      masteryNew: mix(masteryNew, other.masteryNew),
      masteryLearning: mix(masteryLearning, other.masteryLearning),
      masteryReview: mix(masteryReview, other.masteryReview),
      masteryMastered: mix(masteryMastered, other.masteryMastered),
      ratingAgain: mix(ratingAgain, other.ratingAgain),
      ratingHard: mix(ratingHard, other.ratingHard),
      ratingGood: mix(ratingGood, other.ratingGood),
      ratingEasy: mix(ratingEasy, other.ratingEasy),
      onRatingLight: mix(onRatingLight, other.onRatingLight),
      onRatingStrong: mix(onRatingStrong, other.onRatingStrong),
      chartCorrect: mix(chartCorrect, other.chartCorrect),
      chartIncorrect: mix(chartIncorrect, other.chartIncorrect),
      highlight: mix(highlight, other.highlight),
      onHighlightContainer: mix(onHighlightContainer, other.onHighlightContainer),
      highlightContainer: mix(highlightContainer, other.highlightContainer),
      info: mix(info, other.info),
      warningText: mix(warningText, other.warningText),
    );
  }
}
