import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/formatters.dart';
import '../../core/theme.dart';
import '../../models/coin.dart';
import '../../models/market_stats.dart';
import '../../providers/market_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/change_chip.dart';
import '../../widgets/coin_avatar.dart';
import '../../widgets/stat_tile.dart';
import '../../widgets/state_views.dart';
import '../detail/coin_detail_screen.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final market = context.watch<MarketProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Market stats')),
      body: _buildBody(context, market),
    );
  }

  Widget _buildBody(BuildContext context, MarketProvider market) {
    switch (market.state) {
      case LoadState.loading:
        return const _StatsSkeleton();
      case LoadState.error:
        return MessageView.error(message: market.error, onRetry: market.load);
      case LoadState.ready:
        if (market.allCoins.isEmpty) {
          return const MessageView(
            icon: Icons.insights_rounded,
            title: 'No market data',
            message: 'Pull down to refresh and try again.',
          );
        }

        final stats = MarketStats.fromCoins(market.allCoins);

        return RefreshIndicator(
          onRefresh: market.refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
            children: [
              _Overview(stats: stats),
              const SizedBox(height: 16),
              _Dominance(stats: stats),
              const SizedBox(height: 12),
              _Breadth(stats: stats),
              const SizedBox(height: 28),
              _CoinSection(title: 'Top gainers', coins: stats.topGainers),
              const SizedBox(height: 24),
              _CoinSection(title: 'Top losers', coins: stats.topLosers),
              const SizedBox(height: 24),
              _CoinSection(
                title: 'Most traded',
                coins: stats.topVolume,
                showVolume: true,
              ),
              const SizedBox(height: 16),
              Text(
                'Market cap is estimated from reference supply data for major coins. Prices and volume come from Binance.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        );
    }
  }
}

class _Overview extends StatelessWidget {
  final MarketStats stats;

  const _Overview({required this.stats});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.1,
      children: [
        StatTile(
          label: 'Market cap',
          value: Fmt.usdCompact(stats.totalMarketCap),
          icon: Icons.pie_chart_outline_rounded,
        ),
        StatTile(
          label: '24h volume',
          value: Fmt.usdCompact(stats.totalVolume24h),
          icon: Icons.bar_chart_rounded,
        ),
        StatTile(
          label: 'BTC dominance',
          value: '${stats.btcDominance.toStringAsFixed(1)}%',
          icon: Icons.currency_bitcoin_rounded,
        ),
        StatTile(
          label: 'Coins tracked',
          value: '${stats.trackedCoins}',
          icon: Icons.layers_outlined,
        ),
      ],
    );
  }
}

class _Dominance extends StatelessWidget {
  final MarketStats stats;

  const _Dominance({required this.stats});

  static const List<Color> _colors = [
    Color(0xFFF7931A),
    Color(0xFF627EEA),
    Color(0xFFF3BA2F),
    Color(0xFF16C784),
    Color(0xFF8A94A6),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final slices = stats.dominance;

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Market dominance',
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 12,
              child: Row(
                children: [
                  for (var i = 0; i < slices.length; i++)
                    Expanded(
                      flex: (slices[i].percent * 100).round().clamp(1, 10000),
                      child: ColoredBox(color: _colors[i % _colors.length]),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              for (var i = 0; i < slices.length; i++)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: _colors[i % _colors.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${slices[i].base} ${slices[i].percent.toStringAsFixed(1)}%',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontFeatures: Tabular.features,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Breadth extends StatelessWidget {
  final MarketStats stats;

  const _Breadth({required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = stats.gainers + stats.losers + stats.unchanged;
    final upShare = total == 0 ? 0.5 : stats.gainers / total;

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Market breadth (24h)',
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 12,
              child: Row(
                children: [
                  Expanded(
                    flex: (upShare * 1000).round().clamp(1, 999),
                    child: const ColoredBox(color: AppColors.up),
                  ),
                  Expanded(
                    flex: ((1 - upShare) * 1000).round().clamp(1, 999),
                    child: const ColoredBox(color: AppColors.down),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${stats.gainers} rising',
                style: const TextStyle(
                  color: AppColors.up,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${stats.losers} falling',
                style: const TextStyle(
                  color: AppColors.down,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CoinSection extends StatelessWidget {
  final String title;
  final List<Coin> coins;
  final bool showVolume;

  const _CoinSection({
    required this.title,
    required this.coins,
    this.showVolume = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        AppCard(
          child: Column(
            children: [
              for (var i = 0; i < coins.length; i++) ...[
                if (i > 0) const Divider(indent: 16, endIndent: 16),
                InkWell(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CoinDetailScreen(symbol: coins[i].symbol),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      children: [
                        CoinAvatar(base: coins[i].base, size: 34),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                coins[i].base,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                showVolume
                                    ? 'Vol ${Fmt.usdCompact(coins[i].quoteVolume)}'
                                    : Fmt.price(coins[i].price),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontFeatures: Tabular.features,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ChangeChip(percent: coins[i].changePercent),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _StatsSkeleton extends StatelessWidget {
  const _StatsSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: const [
        Row(
          children: [
            Expanded(child: Skeleton(height: 72, radius: 16)),
            SizedBox(width: 12),
            Expanded(child: Skeleton(height: 72, radius: 16)),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: Skeleton(height: 72, radius: 16)),
            SizedBox(width: 12),
            Expanded(child: Skeleton(height: 72, radius: 16)),
          ],
        ),
        SizedBox(height: 16),
        Skeleton(height: 100, radius: 16),
        SizedBox(height: 12),
        Skeleton(height: 100, radius: 16),
        SizedBox(height: 24),
        Skeleton(height: 220, radius: 16),
      ],
    );
  }
}
