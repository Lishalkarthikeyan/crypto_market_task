import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/market_provider.dart';
import '../providers/watchlist_provider.dart';
import 'market/market_screen.dart';
import 'profile/profile_screen.dart';
import 'stats/stats_screen.dart';
import 'watchlist/watchlist_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  late final MarketProvider _market;

  static const List<Widget> _pages = [
    MarketScreen(),
    StatsScreen(),
    WatchlistScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _market = context.read<MarketProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) => _market.start());
  }

  @override
  void dispose() {
    _market.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final saved = context.select<WatchlistProvider, int>((w) => w.count);

    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.candlestick_chart_outlined),
            selectedIcon: Icon(Icons.candlestick_chart_rounded),
            label: 'Market',
          ),
          const NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights_rounded),
            label: 'Stats',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: saved > 0,
              label: Text('$saved'),
              child: const Icon(Icons.star_border_rounded),
            ),
            selectedIcon: Badge(
              isLabelVisible: saved > 0,
              label: Text('$saved'),
              child: const Icon(Icons.star_rounded),
            ),
            label: 'Watchlist',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
