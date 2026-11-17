import 'package:flutter/material.dart';

import 'app.dart';
import 'core/data/seed_data_service.dart';
import 'core/di/injection_container.dart';
import 'features/deck/domain/repositories/deck_repository.dart';
import 'features/settings/domain/repositories/settings_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  await SeedDataService(sl<DeckRepository>()).seedIfEmpty();

  // Restore persisted locale before first frame
  final settings = await sl<SettingsRepository>().getSettings();
  if (settings.locale != null) {
    localeNotifier.value = Locale(settings.locale!);
  }

  runApp(const EduCardsApp());
}
