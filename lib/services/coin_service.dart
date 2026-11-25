import '../core/constants.dart';
import '../data/supply_data.dart';
import '../models/coin.dart';
import '../models/kline.dart';
import 'binance_api.dart';

class _CacheEntry {
  final dynamic value;
  final DateTime expires;

  _CacheEntry(this.value, this.expires);
}

class CoinService {
  final BinanceApi _api;
  final Map<String, _CacheEntry> _cache = {};

  CoinService(this._api);

  Future<T> _cached<T>(String key, Duration ttl, Future<T> Function() load) async {
    final hit = _cache[key];
    if (hit != null && hit.expires.isAfter(DateTime.now())) {
      return hit.value as T;
    }
    final value = await load();
    _cache[key] = _CacheEntry(value, DateTime.now().add(ttl));
    return value;
  }

  bool _isLeveraged(String base) {
    for (final suffix in leveragedSuffixes) {
      if (base.endsWith(suffix) &&
          supplyData.containsKey(base.substring(0, base.length - suffix.length))) {
        return true;
      }
    }
    return false;
  }

  Future<List<Coin>> fetchCoins() {
    return _cached('coins', AppConstants.cacheTtl, () async {
      final data = await _api.get('/api/v3/ticker/24hr') as List;

      final coins = data
          .cast<Map<String, dynamic>>()
          .where((t) => (t['symbol'] as String).endsWith(AppConstants.quoteAsset))
          .where((t) => double.parse(t['lastPrice'].toString()) > 0)
          .where((t) => double.parse(t['quoteVolume'].toString()) > 0)
          .map(Coin.fromTicker)
          .where((c) => !stableBases.contains(c.base) && !_isLeveraged(c.base))
          .toList()
        ..sort((a, b) => b.quoteVolume.compareTo(a.quoteVolume));

      return coins.take(AppConstants.maxCoins).toList();
    });
  }

  Future<Coin> fetchCoin(String symbol) {
    return _cached('coin:$symbol', AppConstants.cacheTtl, () async {
      final data = await _api.get(
        '/api/v3/ticker/24hr',
        query: {'symbol': symbol},
      );
      return Coin.fromTicker(data as Map<String, dynamic>);
    });
  }

  Future<List<Kline>> fetchKlines(String symbol, ChartRange range) {
    return _cached(
      'klines:$symbol:${range.interval}:${range.limit}',
      const Duration(seconds: 20),
      () async {
        final data = await _api.get(
          '/api/v3/klines',
          query: {
            'symbol': symbol,
            'interval': range.interval,
            'limit': '${range.limit}',
          },
        ) as List;
        return data.map((row) => Kline.fromRow(row as List)).toList();
      },
    );
  }
}
