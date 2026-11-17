import 'package:flutter/material.dart';

import 'package:educards/l10n/app_localizations.dart';

/// Wraps [child] with the minimum MaterialApp needed to resolve
/// [AppLocalizations].  Use in widget tests that render l10n-aware widgets.
Widget makeLocalizedTestWidget(
  Widget child, {
  Locale locale = const Locale('en'),
}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}
