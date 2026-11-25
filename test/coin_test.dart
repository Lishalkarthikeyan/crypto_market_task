import 'package:crypto_market/models/coin.dart';
import 'package:crypto_market/models/market_stats.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _ticker(String symbol, String last, String percent) => {
      'symbol': symbol,
      'priceChange': '10.5',
      'priceChangePercent': percent,
      'openPrice': '100',
      'highPrice': '120',
      'lowPrice': '90',
      'lastPrice': last,
      'volume': '5000',
      'quoteVolume': '9000000',
      'count': 12345,
    };

void main() {
  test('Coin.fromTicker parses binance payload and adds supply data', () {
    final coin = Coin.fromTicker(_ticker('BTCUSDT', '67000.5', '1.8'));

    expect(coin.base, 'BTC');
    expect(coin.name, 'Bitcoin');
    expect(coin.price, 67000.5);
    expect(coin.isUp, isTrue);
    expect(coin.marketCap, closeTo(67000.5 * 19900000, 1));
    expect(coin.maxSupply, 21000000);
  });

  test('unknown coins have no market cap', () {
    final coin = Coin.fromTicker(_ticker('ZZZUSDT', '2', '-3'));

    expect(coin.name, 'ZZZ');
    expect(coin.marketCap, isNull);
    expect(coin.isUp, isFalse);
  });

  test('MarketStats.fromCoins calculates totals and dominance', () {
    final coins = [
      Coin.fromTicker(_ticker('BTCUSDT', '60000', '2')),
      Coin.fromTicker(_ticker('ETHUSDT', '3000', '-1')),
      Coin.fromTicker(_ticker('ZZZUSDT', '2', '5')),
    ];
    final stats = MarketStats.fromCoins(coins);

    expect(stats.trackedCoins, 3);
    expect(stats.gainers, 2);
    expect(stats.losers, 1);
    expect(stats.topGainers.first.base, 'ZZZ');
    expect(stats.btcDominance, greaterThan(70));
  });
}
