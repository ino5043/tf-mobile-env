import 'package:flutter/material.dart';

import '../constants/app_dimensions.dart';

/// Screen size categories for responsive design.
enum ScreenSize { compact, medium, expanded }

/// Determines the current screen size category based on width.
ScreenSize getScreenSize(double width) {
  if (width < AppDimensions.compactMaxWidth) return ScreenSize.compact;
  if (width < AppDimensions.mediumMaxWidth) return ScreenSize.medium;
  return ScreenSize.expanded;
}

/// Adaptive layout that renders different builders based on screen size.
/// Follows Material Design 3 responsive breakpoints:
/// - Compact: < 600dp (phones)
/// - Medium: 600-839dp (tablets portrait)
/// - Expanded: >= 840dp (tablets landscape, desktop)
class AdaptiveLayout extends StatelessWidget {
  final Widget Function(BuildContext context) compact;
  final Widget Function(BuildContext context)? medium;
  final Widget Function(BuildContext context)? expanded;

  const AdaptiveLayout({
    super.key,
    required this.compact,
    this.medium,
    this.expanded,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenSize = getScreenSize(constraints.maxWidth);

        return switch (screenSize) {
          ScreenSize.expanded =>
            (expanded ?? medium ?? compact).call(context),
          ScreenSize.medium => (medium ?? compact).call(context),
          ScreenSize.compact => compact(context),
        };
      },
    );
  }
}
