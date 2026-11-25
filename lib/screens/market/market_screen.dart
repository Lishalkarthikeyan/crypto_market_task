import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../core/formatters.dart';
import '../../core/theme.dart';
import '../../models/coin.dart';
import '../../models/market_stats.dart';
import '../../providers/market_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/change_chip.dart';
import '../../widgets/coin_avatar.dart';
import '../../widgets/coin_tile.dart';
import '../../widgets/state_views.dart';
import '../detail/coin_detail_screen.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _openCoin(Coin coin) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CoinDetailScreen(symbol: coin.symbol)),
    );
  }

  void _openSortSheet(MarketProvider market) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final option in CoinSort.values)
                ListTile(
                  title: Text(option.label),
                  selected: market.sort == option,
                  trailing: market.sort == option
                      ? Icon(
                          market.ascending
                              ? Icons.arrow_upward_rounded
                              : Icons.arrow_downward_rounded,
                          size: 20,
                        )
                      : null,
                  onTap: () {
                    market.setSort(option);
                    Navigator.pop(sheetContext);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final market = context.watch<MarketProvider>();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppColors.brand,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.show_chart_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Text(AppConstants.appName),
          ],
        ),
        actions: [
          if (market.state == LoadState.ready)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: _LiveBadge(),
            ),
        ],
      ),
      body: _buildBody(context, market),
    );
  }

  Widget _buildBody(BuildContext context, MarketProvider market) {
    switch (market.state) {
      case LoadState.loading:
        return const _MarketSkeleton();
      case LoadState.error:
        return MessageView.error(message: market.error, onRetry: market.load);
      case LoadState.ready:
        final coins = market.visibleCoins;

        return RefreshIndicator(
          onRefresh: market.refresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _header(context, market)),
              if (coins.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: MessageView(
                    icon: Icons.search_off_rounded,
                    title: 'No coins found',
                    message: 'Try a different search or change the filter.',
                  ),
                )
              else
                SliverList.separated(
                  itemCount: coins.length,
                  separatorBuilder: (_, __) =>
                      const Divider(indent: 16, endIndent: 16),
                  itemBuilder: (context, index) => CoinTile(
                    coin: coins[index],
                    rank: index + 1,
                    onTap: () => _openCoin(coins[index]),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        );
    }
  }

  Widget _header(BuildContext context, MarketProvider market) {
    final theme = Theme.of(context);
    final stats = MarketStats.fromCoins(market.allCoins);
    final gainers = [...market.allCoins]
      ..sort((a, b) => b.changePercent.compareTo(a.changePercent));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 92,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            children: [
              _OverviewCard(
                label: 'Market cap',
                value: Fmt.usdCompact(stats.totalMarketCap),
              ),
              _OverviewCard(
                label: '24h volume',
                value: Fmt.usdCompact(stats.totalVolume24h),
              ),
              _OverviewCard(
                label: 'BTC dominance',
                value: '${stats.btcDominance.toStringAsFixed(1)}%',
              ),
              _OverviewCard(
                label: 'Up / down',
                value: '${stats.gainers} / ${stats.losers}',
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
          child: Text(
            'Trending',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: gainers.take(6).length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final coin = gainers[index];
              return _TrendingCard(coin: coin, onTap: () => _openCoin(coin));
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 22, 16, 10),
          child: TextField(
            controller: _search,
            onChanged: market.setQuery,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search coins',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: market.query.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () {
                        _search.clear();
                        market.setQuery('');
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
            ),
          ),
        ),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              for (final filter in CoinFilter.values)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _FilterPill(
                    label: filter.label,
                    selected: market.filter == filter,
                    onTap: () => market.setFilter(filter),
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 4, 0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${market.visibleCoins.length} coins',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () => _openSortSheet(market),
                icon: const Icon(Icons.swap_vert_rounded, size: 18),
                label: Text(market.sort.label),
              ),
              IconButton(
                tooltip: 'Reverse order',
                onPressed: market.toggleDirection,
                icon: Icon(
                  market.ascending
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
        const Divider(),
      ],
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.up.withOpacity(0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 8, color: AppColors.up),
          SizedBox(width: 6),
          Text(
            'LIVE',
            style: TextStyle(
              color: AppColors.up,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final String label;
  final String value;

  const _OverviewCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: SizedBox(
        width: 150,
        child: AppCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontFeatures: Tabular.features,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrendingCard extends StatelessWidget {
  final Coin coin;
  final VoidCallback onTap;

  const _TrendingCard({required this.coin, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 148,
      child: AppCard(
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CoinAvatar(base: coin.base, size: 24),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        coin.base,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  Fmt.price(coin.price),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontFeatures: Tabular.features,
                  ),
                ),
                ChangeText(percent: coin.changePercent, size: 13),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: selected ? AppColors.brand : AppTheme.cardColor(context),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _MarketSkeleton extends StatelessWidget {
  const _MarketSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: const [
        Padding(
          padding: EdgeInsets.fromLTRB(16, 4, 16, 0),
          child: Row(
            children: [
              Expanded(child: Skeleton(height: 78, radius: 16)),
              SizedBox(width: 10),
              Expanded(child: Skeleton(height: 78, radius: 16)),
            ],
          ),
        ),
        SizedBox(height: 24),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Skeleton(height: 48, radius: 12),
        ),
        SizedBox(height: 8),
        SizedBox(height: 380, child: CoinListSkeleton(count: 8)),
      ],
    );
  }
}
