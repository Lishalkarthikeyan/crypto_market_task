import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';

class PreferencesService {
  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<Set<String>> readWatchlist(String email) async {
    final prefs = await _prefs;
    return (prefs.getStringList(StorageKeys.watchlist(email)) ?? []).toSet();
  }

  Future<void> writeWatchlist(String email, Set<String> symbols) async {
    final prefs = await _prefs;
    await prefs.setStringList(StorageKeys.watchlist(email), symbols.toList());
  }

  Future<String?> readThemeMode() async {
    final prefs = await _prefs;
    return prefs.getString(StorageKeys.themeMode);
  }

  Future<void> writeThemeMode(String value) async {
    final prefs = await _prefs;
    await prefs.setString(StorageKeys.themeMode, value);
  }
}
