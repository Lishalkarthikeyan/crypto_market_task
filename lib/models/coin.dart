import '../core/constants.dart';
import '../data/supply_data.dart';

class Coin {
  final String symbol;
  final String base;
  final String name;
  final double price;
  final double change;
  final double changePercent;
  final double open;
  final double high;
  final double low;
  final double volume;
  final double quoteVolume;
  final int trades;
  final double? marketCap;
  final double? circulatingSupply;
  final double? maxSupply;

  const Coin({
    required this.symbol,
    required this.base,
    required this.name,
    required this.price,
    required this.change,
    required this.changePercent,
    required this.open,
    required this.high,
    required this.low,
    required this.volume,
    required this.quoteVolume,
    required this.trades,
    this.marketCap,
    this.circulatingSupply,
    this.maxSupply,
  });

  bool get isUp => changePercent >= 0;

  factory Coin.fromTicker(Map<String, dynamic> json) {
    double read(String key) => double.parse(json[key].toString());

    final symbol = json['symbol'] as String;
    final base = symbol.substring(0, symbol.length - AppConstants.quoteAsset.length);
    final info = supplyData[base];
    final price = read('lastPrice');

    return Coin(
      symbol: symbol,
      base: base,
      name: info?.name ?? base,
      price: price,
      change: read('priceChange'),
      changePercent: read('priceChangePercent'),
      open: read('openPrice'),
      high: read('highPrice'),
      low: read('lowPrice'),
      volume: read('volume'),
      quoteVolume: read('quoteVolume'),
      trades: int.parse(json['count'].toString()),
      marketCap: info == null ? null : price * info.circulating,
      circulatingSupply: info?.circulating,
      maxSupply: info?.max,
    );
  }
}
