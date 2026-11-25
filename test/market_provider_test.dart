import 'package:crypto_market/models/coin.dart';
import 'package:crypto_market/models/kline.dart';
import 'package:crypto_market/providers/market_provider.dart';
import 'package:crypto_market/services/binance_api.dart';
import 'package:crypto_market/services/coin_service.dart';
import 'package:flutter_test/flutter_test.dart';

Coin _coin(String base, double price, double percent, double volume) {
  return Coin(
    symbol: '${base}USDT',
    base: base,
    name: base,
    price: price,
    change: 0,
    changePercent: percent,
    open: price,
    high: price,
    low: price,
    volume: volume,
    quoteVolume: volume,
    trades: 1,
    marketCap: price * 10,
  );
}

class _FakeService extends CoinService {
  final List<Coin> coins;

  _FakeService(this.coins) : super(BinanceApi());

  @override
  Future<List<Coin>> fetchCoins() async => coins;

  @override
  Future<Coin> fetchCoin(String symbol) async =>
      coins.firstWhere((c) => c.symbol == symbol);

  @override
  Future<List<Kline>> fetchKlines(String symbol, ChartRange range) async => [];
}

void main() {
  late MarketProvider market;

  setUp(() async {
    market = MarketProvider(_FakeService([
      _coin('BTC', 60000, 2, 900),
      _coin('ETH', 3000, -1, 500),
      _coin('ADA', 1, 5, 100),
      _coin('SOL', 150, -3, 300),
    ]));
    await market.refresh();
  });

  test('default order is market cap high to low', () {
    expect(market.visibleCoins.map((c) => c.base), ['BTC', 'ETH', 'SOL', 'ADA']);
  });

  test('search matches name or symbol', () {
    market.setQuery('so');
    expect(market.visibleCoins.map((c) => c.base), ['SOL']);
  });

  test('gainers filter keeps positive changes', () {
    market.setFilter(CoinFilter.gainers);
    expect(market.visibleCoins.map((c) => c.base), ['BTC', 'ADA']);
  });

  test('sorting by change toggles direction on repeat', () {
    market.setSort(CoinSort.change);
    expect(market.visibleCoins.first.base, 'ADA');
    market.setSort(CoinSort.change);
    expect(market.visibleCoins.first.base, 'SOL');
  });
}
