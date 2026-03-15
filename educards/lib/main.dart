import 'package:flutter/material.dart';

import 'app.dart';
import 'core/data/seed_data_service.dart';
import 'core/di/injection_container.dart';
import 'features/deck/domain/repositories/deck_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  await SeedDataService(sl<DeckRepository>()).seedIfEmpty();
  runApp(const EduCardsApp());
}
