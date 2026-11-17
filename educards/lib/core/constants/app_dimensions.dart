/// Responsive breakpoints following Material Design 3.
/// Compact: < 600 dp (phones portrait)
/// Medium: 600–839 dp (tablets portrait, foldables)
/// Expanded: >= 840 dp (tablets landscape, desktop)
class AppDimensions {
  AppDimensions._();

  // Breakpoints
  static const double compactMaxWidth = 600;
  static const double mediumMaxWidth = 840;

  // Spacing
  static const double spacingXs = 4;
  static const double spacingSm = 8;
  static const double spacingMd = 16;
  static const double spacingLg = 24;
  static const double spacingXl = 32;

  // Touch targets (WCAG / Material Design 3)
  static const double minTouchTarget = 48;

  // Card
  static const double cardBorderRadius = 12;
  static const double cardElevation = 2;

  // Content
  static const double maxContentWidth = 1200;
}
