import 'package:hive/hive.dart';

import '../models/app_settings_model.dart';

abstract class SettingsLocalDataSource {
  AppSettingsModel? getSettings();
  Future<void> saveSettings(AppSettingsModel settings);
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  final Box<AppSettingsModel> _box;

  SettingsLocalDataSourceImpl(this._box);

  @override
  AppSettingsModel? getSettings() {
    return _box.get('settings');
  }

  @override
  Future<void> saveSettings(AppSettingsModel settings) async {
    await _box.put('settings', settings);
  }
}
