import 'package:flutter/foundation.dart';

import '../services/preferences_service.dart';

class WatchlistProvider extends ChangeNotifier {
  final PreferencesService _prefs;

  WatchlistProvider(this._prefs);

  String? _email;
  Set<String> _symbols = {};

  Set<String> get symbols => _symbols;
  int get count => _symbols.length;

  bool contains(String symbol) => _symbols.contains(symbol);

  Future<void> bindUser(String? email) async {
    if (email == _email) return;
    _email = email;
    _symbols = email == null ? {} : await _prefs.readWatchlist(email);
    notifyListeners();
  }

  Future<void> toggle(String symbol) async {
    final email = _email;
    if (email == null) return;

    final next = {..._symbols};
    if (!next.remove(symbol)) next.add(symbol);
    _symbols = next;
    notifyListeners();
    await _prefs.writeWatchlist(email, next);
  }
}
