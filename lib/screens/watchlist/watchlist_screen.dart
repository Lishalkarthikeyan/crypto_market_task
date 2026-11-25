import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../models/coin.dart';
import '../../providers/market_provider.dart';
import '../../providers/watchlist_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/change_chip.dart';
import '../../widgets/coin_tile.dart';
import '../../widgets/state_views.dart';
import '../detail/coin_detail_screen.dart';

class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final market = context.watch<MarketProvider>();
    final watchlist = context.watch<WatchlistProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Watchlist')),
      body: _buildBody(context, market, watchlist),
    );
  }

  Widget _buildBody(
    BuildContext context,
    MarketProvider market,
    WatchlistProvider watchlist,
  ) {
    if (watchlist.symbols.isEmpty) {
      return const MessageView(
        icon: Icons.star_border_rounded,
        title: 'Your watchlist is empty',
        message: 'Tap the star on any coin to follow it here.',
      );
    }

    if (market.state == LoadState.loading) {
      return const CoinListSkeleton(count: 5);
    }

    if (market.state == LoadState.error) {
      return MessageView.error(message: market.error, onRetry: market.load);
    }

    final coins = market.allCoins
        .where((coin) => watchlist.contains(coin.symbol))
        .toList()
      ..sort((a, b) => (b.marketCap ?? 0).compareTo(a.marketCap ?? 0));

    if (coins.isEmpty) {
      return const MessageView(
        icon: Icons.star_border_rounded,
        title: 'Coins not available',
        message: 'The saved coins are not in the current market list.',
      );
    }

    final average =
        coins.fold<double>(0, (sum, c) => sum + c.changePercent) / coins.length;

    return RefreshIndicator(
      onRefresh: market.refresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: coins.length + 1,
        separatorBuilder: (_, index) => index == 0
            ? const SizedBox(height: 8)
            : const Divider(indent: 16, endIndent: 16),
        itemBuilder: (context, index) {
          if (index == 0) return _Summary(count: coins.length, average: average);

          final coin = coins[index - 1];
          return _row(context, coin, watchlist);
        },
      ),
    );
  }

  Widget _row(BuildContext context, Coin coin, WatchlistProvider watchlist) {
    return Dismissible(
      key: ValueKey(coin.symbol),
      direction: DismissDirection.endToStart,
      background: Container(
        color: AppColors.down,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      onDismissed: (_) => watchlist.toggle(coin.symbol),
      child: CoinTile(
        coin: coin,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CoinDetailScreen(symbol: coin.symbol),
          ),
        ),
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  final int count;
  final double average;

  const _Summary({required this.count, required this.average});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Following', style: theme.textTheme.bodySmall?.copyWith(color: muted)),
                  const SizedBox(height: 4),
                  Text(
                    '$count coins',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Avg. 24h change', style: theme.textTheme.bodySmall?.copyWith(color: muted)),
                const SizedBox(height: 4),
                ChangeChip(percent: average, large: true),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
