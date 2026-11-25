import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/formatters.dart';
import '../core/theme.dart';
import '../models/coin.dart';
import '../providers/watchlist_provider.dart';
import 'change_chip.dart';
import 'coin_avatar.dart';

class CoinTile extends StatelessWidget {
  final Coin coin;
  final int? rank;
  final bool showMarketCap;
  final VoidCallback onTap;

  const CoinTile({
    super.key,
    required this.coin,
    this.rank,
    this.showMarketCap = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final watchlist = context.watch<WatchlistProvider>();
    final saved = watchlist.contains(coin.symbol);

    final subtitle = showMarketCap && coin.marketCap != null
        ? 'MCap ${Fmt.usdCompact(coin.marketCap)}'
        : 'Vol ${Fmt.usdCompact(coin.quoteVolume)}';

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 6, 10),
        child: Row(
          children: [
            if (rank != null)
              SizedBox(
                width: 28,
                child: Text(
                  '$rank',
                  style: theme.textTheme.bodySmall?.copyWith(color: muted),
                ),
              ),
            CoinAvatar(base: coin.base, size: 38),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          coin.base,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          coin.name == coin.base ? '' : coin.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(color: muted),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: muted,
                      fontFeatures: Tabular.features,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  Fmt.price(coin.price),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontFeatures: Tabular.features,
                  ),
                ),
                const SizedBox(height: 1),
                ChangeText(percent: coin.changePercent, size: 13),
              ],
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              tooltip: saved ? 'Remove from watchlist' : 'Add to watchlist',
              onPressed: () => watchlist.toggle(coin.symbol),
              icon: Icon(
                saved ? Icons.star_rounded : Icons.star_border_rounded,
                color: saved ? AppColors.gold : muted.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
