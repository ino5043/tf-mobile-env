import 'package:flutter/material.dart';

import 'app_tokens.dart';

/// アプリのテーマ。色・文字・角の丸みは app_tokens.dart の値だけを使う。
///
/// UI/UX 標準（00_開発標準/UIUX標準）の第 2 部に合わせている。主な決まり:
/// - 文字は 4.5:1、枠や部品は 3:1 以上（4-1・4-2）
/// - 本文とボタンの文字は 16、最小でも 14（5-4・5-5）
/// - 浮いた要素は影ではなく枠線で境界を示す（3-11）
/// - フォーカスの表示は DADS の黄と黒（4-8）
class AppTheme {
  AppTheme._();

  /// 日本語は Noto Sans JP を優先し、無い端末では OS の日本語書体を使う（5-1）。
  /// 書体ファイルは同梱していない（ADR-004）。
  static const _fontFamilyFallback = [
    'Noto Sans JP',
    'Noto Sans CJK JP',
    'Hiragino Sans',
    'Yu Gothic UI',
    'Meiryo',
    'sans-serif',
  ];

  static ThemeData get light => _build(
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: AppPalette.lightPrimary,
          onPrimary: AppPalette.lightOnPrimary,
          primaryContainer: AppPalette.lightPrimaryContainer,
          onPrimaryContainer: AppPalette.lightOnPrimaryContainer,
          secondary: AppPalette.lightPrimary,
          onSecondary: AppPalette.lightOnPrimary,
          secondaryContainer: AppPalette.lightPrimaryContainer,
          onSecondaryContainer: AppPalette.lightOnPrimaryContainer,
          tertiary: AppPalette.lightTertiary,
          onTertiary: AppPalette.lightOnTertiary,
          tertiaryContainer: AppPalette.lightTertiaryContainer,
          onTertiaryContainer: AppPalette.lightOnTertiaryContainer,
          error: AppPalette.lightError,
          onError: Color(0xFFFFFFFF),
          errorContainer: Color(0xFFFFE5E5),
          onErrorContainer: Color(0xFF8A0000),
          surface: AppPalette.lightSurface,
          onSurface: AppPalette.lightOnSurface,
          onSurfaceVariant: AppPalette.lightOnSurfaceVariant,
          surfaceContainerLowest: AppPalette.lightSurface,
          surfaceContainerLow: AppPalette.lightBackground,
          surfaceContainer: AppPalette.lightSurfaceContainer,
          surfaceContainerHigh: AppPalette.lightSurfaceContainer,
          surfaceContainerHighest: AppPalette.lightPrimaryContainer,
          outline: AppPalette.lightOutline,
          outlineVariant: AppPalette.lightOutlineVariant,
          inverseSurface: AppPalette.lightOnSurface,
          onInverseSurface: AppPalette.lightSurface,
          inversePrimary: AppPalette.darkPrimary,
        ),
        scaffoldBackground: AppPalette.lightBackground,
        appColors: AppColors.light,
      );

  static ThemeData get dark => _build(
        colorScheme: const ColorScheme(
          brightness: Brightness.dark,
          primary: AppPalette.darkPrimary,
          onPrimary: AppPalette.darkOnPrimary,
          primaryContainer: AppPalette.darkPrimaryContainer,
          onPrimaryContainer: AppPalette.darkOnPrimaryContainer,
          secondary: AppPalette.darkPrimary,
          onSecondary: AppPalette.darkOnPrimary,
          secondaryContainer: AppPalette.darkPrimaryContainer,
          onSecondaryContainer: AppPalette.darkOnPrimaryContainer,
          tertiary: AppPalette.darkTertiary,
          onTertiary: AppPalette.darkOnTertiary,
          tertiaryContainer: AppPalette.darkTertiaryContainer,
          onTertiaryContainer: AppPalette.darkOnTertiaryContainer,
          error: AppPalette.darkError,
          onError: Color(0xFF690005),
          errorContainer: Color(0xFF93000A),
          onErrorContainer: Color(0xFFFFDAD6),
          surface: AppPalette.darkSurface,
          onSurface: AppPalette.darkOnSurface,
          onSurfaceVariant: AppPalette.darkOnSurfaceVariant,
          surfaceContainerLowest: AppPalette.darkBackground,
          surfaceContainerLow: AppPalette.darkSurface,
          surfaceContainer: AppPalette.darkSurfaceContainer,
          surfaceContainerHigh: AppPalette.darkSurfaceContainer,
          surfaceContainerHighest: AppPalette.darkPrimaryContainer,
          outline: AppPalette.darkOutline,
          outlineVariant: AppPalette.darkOutlineVariant,
          inverseSurface: AppPalette.darkOnSurface,
          onInverseSurface: AppPalette.darkSurface,
          inversePrimary: AppPalette.lightPrimary,
        ),
        scaffoldBackground: AppPalette.darkBackground,
        appColors: AppColors.dark,
      );

  static ThemeData _build({
    required ColorScheme colorScheme,
    required Color scaffoldBackground,
    required AppColors appColors,
  }) {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamilyFallback: _fontFamilyFallback,
    );
    final focusSide = _focusSide();
    final pill = WidgetStateProperty.all<OutlinedBorder>(const StadiumBorder());

    return base.copyWith(
      scaffoldBackgroundColor: scaffoldBackground,
      textTheme: _textTheme(base.textTheme, colorScheme),
      extensions: [appColors],
      // フォーカスの表示（4-8）: 黄の面と黒の線。各ボタンにも同じ線を付ける
      focusColor: AppPalette.focusRing.withValues(alpha: 0.6),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: scaffoldBackground,
        foregroundColor: colorScheme.onSurface,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: colorScheme.surface,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          // 浮いた要素は 3:1 以上の枠線で境界を示す（3-11）
          side: BorderSide(color: colorScheme.outline),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: BorderSide(color: colorScheme.outline),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
          side: BorderSide(color: colorScheme.outline),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          minimumSize: WidgetStateProperty.all(const Size(48, 48)),
          shape: pill,
          side: focusSide,
          textStyle: WidgetStateProperty.all(
            const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          minimumSize: WidgetStateProperty.all(const Size(48, 48)),
          shape: pill,
          side: focusSide,
          elevation: WidgetStateProperty.all(0),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          minimumSize: WidgetStateProperty.all(const Size(48, 48)),
          shape: pill,
          side: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.focused)) return _focusBorder;
            return BorderSide(color: colorScheme.outline);
          }),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          minimumSize: WidgetStateProperty.all(const Size(48, 48)),
          shape: pill,
          side: focusSide,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          minimumSize: WidgetStateProperty.all(const Size(48, 48)),
          side: focusSide,
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          minimumSize: WidgetStateProperty.all(const Size(48, 48)),
          shape: pill,
          side: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.focused)) return _focusBorder;
            return BorderSide(color: colorScheme.outline);
          }),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        shape: const StadiumBorder(),
      ),
      chipTheme: ChipThemeData(
        shape: const StadiumBorder(),
        side: BorderSide(color: colorScheme.outline),
        labelStyle: const TextStyle(fontSize: 14),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 14,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
            color: states.contains(WidgetState.selected)
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: _focusBorder,
        ),
        helperStyle: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
    );
  }

  static const _focusBorder =
      BorderSide(color: AppPalette.focusOutline, width: 3);

  static WidgetStateProperty<BorderSide?> _focusSide() =>
      WidgetStateProperty.resolveWith(
        (states) =>
            states.contains(WidgetState.focused) ? _focusBorder : null,
      );

  /// 文字の大きさ（5.3）。本文とボタンは 16、小さい文字も 14 を下回らない
  static TextTheme _textTheme(TextTheme base, ColorScheme scheme) {
    TextStyle? size(TextStyle? s, double fontSize,
            {FontWeight? weight, double? height}) =>
        s?.copyWith(
          fontSize: fontSize,
          fontWeight: weight,
          height: height,
          color: scheme.onSurface,
        );
    return base.copyWith(
      headlineLarge: size(base.headlineLarge, 32, weight: FontWeight.w700),
      headlineMedium: size(base.headlineMedium, 28, weight: FontWeight.w700),
      headlineSmall: size(base.headlineSmall, 24, weight: FontWeight.w700),
      titleLarge: size(base.titleLarge, 22, weight: FontWeight.w700),
      titleMedium: size(base.titleMedium, 18, weight: FontWeight.w700),
      titleSmall: size(base.titleSmall, 16, weight: FontWeight.w700),
      bodyLarge: size(base.bodyLarge, 16, height: 1.7),
      bodyMedium: size(base.bodyMedium, 16, height: 1.7),
      bodySmall: size(base.bodySmall, 14, height: 1.6),
      labelLarge: size(base.labelLarge, 16, weight: FontWeight.w700),
      labelMedium: size(base.labelMedium, 14, weight: FontWeight.w500),
      labelSmall: size(base.labelSmall, 14, weight: FontWeight.w500),
    );
  }
}
