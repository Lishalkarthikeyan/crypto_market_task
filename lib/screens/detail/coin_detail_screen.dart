import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/formatters.dart';
import '../../core/theme.dart';
import '../../models/coin.dart';
import '../../models/kline.dart';
import '../../providers/detail_provider.dart';
import '../../providers/market_provider.dart';
import '../../providers/watchlist_provider.dart';
import '../../services/coin_service.dart';
import '../../widgets/app_card.dart';
import '../../widgets/change_chip.dart';
import '../../widgets/coin_avatar.dart';
import '../../widgets/price_chart.dart';
import '../../widgets/range_bar.dart';
import '../../widgets/stat_tile.dart';
import '../../widgets/state_views.dart';

class CoinDetailScreen extends StatelessWidget {
  final String symbol;

  const CoinDetailScreen({super.key, required this.symbol});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DetailProvider(
        context.read<CoinService>(),
        symbol,
        context.read<MarketProvider>().bySymbol(symbol),
      )..load(),
      child: const _DetailView(),
    );
  }
}

class _DetailView extends StatelessWidget {
  const _DetailView();

  @override
  Widget build(BuildContext context) {
    final detail = context.watch<DetailProvider>();
    final watchlist = context.watch<WatchlistProvider>();
    final coin = detail.coin;
    final saved = watchlist.contains(detail.symbol);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: coin == null
            ? Text(detail.symbol)
            : Row(
                children: [
                  CoinAvatar(base: coin.base, size: 28),
                  const SizedBox(width: 10),
                  Text(
                    coin.name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor(context),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      coin.base,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
        actions: [
          IconButton(
            tooltip: saved ? 'Remove from watchlist' : 'Add to watchlist',
            onPressed: () => watchlist.toggle(detail.symbol),
            icon: Icon(
              saved ? Icons.star_rounded : Icons.star_border_rounded,
              color: saved ? AppColors.gold : null,
            ),
          ),
        ],
      ),
      body: _buildBody(context, detail),
    );
  }

  Widget _buildBody(BuildContext context, DetailProvider detail) {
    final coin = detail.coin;

    if (coin == null) {
      if (detail.state == LoadState.error) {
        return MessageView.error(message: detail.error, onRetry: detail.load);
      }
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: detail.load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          _Header(coin: coin),
          const SizedBox(height: 20),
          _ChartSection(detail: detail),
          const SizedBox(height: 20),
          AppCard(
            padding: const EdgeInsets.all(16),
            child: RangeBar(
              title: '24h range',
              low: coin.low,
              high: coin.high,
              current: coin.price,
            ),
          ),
          const SizedBox(height: 24),
          const _SectionTitle('Market data'),
          _MarketData(coin: coin),
          const SizedBox(height: 24),
          const _SectionTitle('Statistics'),
          _SupplyData(coin: coin),
          const SizedBox(height: 16),
          Text(
            'Market cap and supply are estimated from reference data. Price, volume and charts are live from Binance.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final Coin coin;

  const _Header({required this.coin});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = AppColors.change(coin.changePercent);
    final sign = coin.change >= 0 ? '+' : '-';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${coin.name} price (${coin.base})',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            Fmt.price(coin.price),
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
              fontFeatures: Tabular.features,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            ChangeChip(percent: coin.changePercent, large: true),
            const SizedBox(width: 10),
            Text(
              '$sign${Fmt.price(coin.change.abs())} (24h)',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ChartSection extends StatelessWidget {
  final DetailProvider detail;

  const _ChartSection({required this.detail});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppTheme.cardColor(context),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              for (final range in ChartRange.all)
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => detail.selectRange(range),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: detail.range.label == range.label
                            ? theme.colorScheme.surface
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Text(
                        range.label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: detail.range.label == range.label
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(height: 292, child: _chartBody()),
      ],
    );
  }

  Widget _chartBody() {
    if (detail.chartLoading) {
      return const Skeleton(height: 292, radius: 16);
    }
    if (detail.chartError.isNotEmpty) {
      return MessageView.error(
        message: detail.chartError,
        onRetry: detail.reloadChart,
      );
    }
    if (detail.klines.length < 2) {
      return const MessageView(
        icon: Icons.show_chart_rounded,
        title: 'No chart data',
        message: 'There is not enough history for this period.',
      );
    }
    return PriceChart(klines: detail.klines);
  }
}

class _MarketData extends StatelessWidget {
  final Coin coin;

  const _MarketData({required this.coin});

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
          value: Fmt.usdCompact(coin.marketCap),
          icon: Icons.pie_chart_outline_rounded,
        ),
        StatTile(
          label: '24h volume',
          value: Fmt.usdCompact(coin.quoteVolume),
          icon: Icons.bar_chart_rounded,
        ),
        StatTile(
          label: '24h high',
          value: Fmt.price(coin.high),
          icon: Icons.north_east_rounded,
        ),
        StatTile(
          label: '24h low',
          value: Fmt.price(coin.low),
          icon: Icons.south_east_rounded,
        ),
      ],
    );
  }
}

class _SupplyData extends StatelessWidget {
  final Coin coin;

  const _SupplyData({required this.coin});

  @override
  Widget build(BuildContext context) {
    final circulating = coin.circulatingSupply;
    final max = coin.maxSupply;
    final share = (circulating != null && max != null && max > 0)
        ? (circulating / max).clamp(0.0, 1.0)
        : null;

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        children: [
          InfoRow(
            label: 'Circulating supply',
            value: circulating == null
                ? '--'
                : '${Fmt.compact(circulating)} ${coin.base}',
          ),
          const Divider(),
          InfoRow(
            label: 'Max supply',
            value: max == null ? 'No cap' : '${Fmt.compact(max)} ${coin.base}',
          ),
          const Divider(),
          InfoRow(label: 'Volume (${coin.base})', value: Fmt.compact(coin.volume)),
          const Divider(),
          InfoRow(label: 'Trades (24h)', value: Fmt.number(coin.trades.toDouble())),
          const Divider(),
          InfoRow(label: 'Open (24h)', value: Fmt.price(coin.open)),
          if (share != null) ...[
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(value: share, minHeight: 8),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${(share * 100).toStringAsFixed(1)}% of max supply in circulation',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}
