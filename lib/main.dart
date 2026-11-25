import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'providers/auth_provider.dart';
import 'providers/market_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/watchlist_provider.dart';
import 'services/auth_service.dart';
import 'services/binance_api.dart';
import 'services/coin_service.dart';
import 'services/preferences_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final coinService = CoinService(BinanceApi());
  final preferences = PreferencesService();

  runApp(
    MultiProvider(
      providers: [
        Provider<CoinService>.value(value: coinService),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(AuthService())..restore(),
        ),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(preferences)..load(),
        ),
        ChangeNotifierProvider(create: (_) => WatchlistProvider(preferences)),
        ChangeNotifierProvider(create: (_) => MarketProvider(coinService)),
      ],
      child: const CoinScopeApp(),
    ),
  );
}
