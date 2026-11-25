import 'coin.dart';

class DominanceSlice {
  final String base;
  final double percent;

  const DominanceSlice(this.base, this.percent);
}

class MarketStats {
  final double totalMarketCap;
  final double totalVolume24h;
  final double btcDominance;
  final int trackedCoins;
  final int gainers;
  final int losers;
  final int unchanged;
  final List<Coin> topGainers;
  final List<Coin> topLosers;
  final List<Coin> topVolume;
  final List<DominanceSlice> dominance;

  const MarketStats({
    required this.totalMarketCap,
    required this.totalVolume24h,
    required this.btcDominance,
    required this.trackedCoins,
    required this.gainers,
    required this.losers,
    required this.unchanged,
    required this.topGainers,
    required this.topLosers,
    required this.topVolume,
    required this.dominance,
  });

  factory MarketStats.fromCoins(List<Coin> coins) {
    final priced = coins.where((c) => c.marketCap != null).toList()
      ..sort((a, b) => b.marketCap!.compareTo(a.marketCap!));
    final totalCap = priced.fold<double>(0, (sum, c) => sum + c.marketCap!);

    final byChange = [...coins]
      ..sort((a, b) => b.changePercent.compareTo(a.changePercent));
    final byVolume = [...coins]
      ..sort((a, b) => b.quoteVolume.compareTo(a.quoteVolume));

    final slices = <DominanceSlice>[];
    var shown = 0.0;
    for (final coin in priced.take(4)) {
      final share = totalCap == 0 ? 0.0 : coin.marketCap! / totalCap * 100;
      slices.add(DominanceSlice(coin.base, share));
      shown += share;
    }
    if (priced.length > 4) slices.add(DominanceSlice('Others', 100 - shown));

    final btc = priced.where((c) => c.base == 'BTC');

    return MarketStats(
      totalMarketCap: totalCap,
      totalVolume24h: coins.fold<double>(0, (sum, c) => sum + c.quoteVolume),
      btcDominance: btc.isEmpty || totalCap == 0
          ? 0
          : btc.first.marketCap! / totalCap * 100,
      trackedCoins: coins.length,
      gainers: coins.where((c) => c.changePercent > 0).length,
      losers: coins.where((c) => c.changePercent < 0).length,
      unchanged: coins.where((c) => c.changePercent == 0).length,
      topGainers: byChange.take(5).toList(),
      topLosers: byChange.reversed.take(5).toList(),
      topVolume: byVolume.take(5).toList(),
      dominance: slices,
    );
  }
}
