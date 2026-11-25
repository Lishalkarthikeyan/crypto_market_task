import 'package:flutter/material.dart';

import '../services/preferences_service.dart';

class ThemeProvider extends ChangeNotifier {
  final PreferencesService _prefs;

  ThemeProvider(this._prefs);

  ThemeMode _mode = ThemeMode.system;

  ThemeMode get mode => _mode;

  Future<void> load() async {
    final saved = await _prefs.readThemeMode();
    _mode = ThemeMode.values.firstWhere(
      (m) => m.name == saved,
      orElse: () => ThemeMode.system,
    );
    notifyListeners();
  }

  Future<void> setMode(ThemeMode mode) async {
    _mode = mode;
    notifyListeners();
    await _prefs.writeThemeMode(mode.name);
  }
}
