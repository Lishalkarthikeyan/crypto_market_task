class AppConstants {
  static const String appName = 'CoinScope';

  static const List<String> binanceHosts = [
    'https://api.binance.com',
    'https://data-api.binance.vision',
  ];

  static const String quoteAsset = 'USDT';
  static const int maxCoins = 100;

  static const Duration requestTimeout = Duration(seconds: 10);
  static const Duration cacheTtl = Duration(seconds: 5);
  static const Duration refreshInterval = Duration(seconds: 30);

  static String iconUrl(String base) =>
      'https://assets.coincap.io/assets/icons/${base.toLowerCase()}@2x.png';
}

class StorageKeys {
  static const String users = 'auth_users';
  static const String session = 'auth_session';
  static const String themeMode = 'theme_mode';
  static String watchlist(String email) => 'watchlist_$email';
}
