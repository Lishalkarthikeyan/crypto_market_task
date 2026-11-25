import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/constants.dart';
import '../models/coin.dart';
import '../services/coin_service.dart';

enum LoadState { loading, ready, error }

enum CoinFilter { all, gainers, losers, highVolume }

enum CoinSort { marketCap, price, change, volume, name }

extension CoinFilterLabel on CoinFilter {
  String get label {
    switch (this) {
      case CoinFilter.all:
        return 'All';
      case CoinFilter.gainers:
        return 'Gainers';
      case CoinFilter.losers:
        return 'Losers';
      case CoinFilter.highVolume:
        return 'High volume';
    }
  }
}

extension CoinSortLabel on CoinSort {
  String get label {
    switch (this) {
      case CoinSort.marketCap:
        return 'Market cap';
      case CoinSort.price:
        return 'Price';
      case CoinSort.change:
        return '24h change';
      case CoinSort.volume:
        return 'Volume';
      case CoinSort.name:
        return 'Name';
    }
  }
}

class MarketProvider extends ChangeNotifier {
  final CoinService _service;

  MarketProvider(this._service);

  List<Coin> _coins = [];
  LoadState _state = LoadState.loading;
  String _error = '';
  String _query = '';
  CoinFilter _filter = CoinFilter.all;
  CoinSort _sort = CoinSort.marketCap;
  bool _ascending = false;
  DateTime? _updatedAt;
  Timer? _timer;

  LoadState get state => _state;
  String get error => _error;
  String get query => _query;
  CoinFilter get filter => _filter;
  CoinSort get sort => _sort;
  bool get ascending => _ascending;
  DateTime? get updatedAt => _updatedAt;
  List<Coin> get allCoins => _coins;

  List<Coin> get visibleCoins {
    final text = _query.trim().toLowerCase();
    var list = _coins.where((coin) {
      if (text.isEmpty) return true;
      return coin.name.toLowerCase().contains(text) ||
          coin.base.toLowerCase().contains(text);
    }).toList();

    switch (_filter) {
      case CoinFilter.all:
        break;
      case CoinFilter.gainers:
        list = list.where((c) => c.changePercent > 0).toList();
        break;
      case CoinFilter.losers:
        list = list.where((c) => c.changePercent < 0).toList();
        break;
      case CoinFilter.highVolume:
        final volumes = _coins.map((c) => c.quoteVolume).toList()..sort();
        final cutoff = volumes[(volumes.length * 0.75).floor()];
        list = list.where((c) => c.quoteVolume >= cutoff).toList();
        break;
    }

    list.sort((a, b) {
      final result = _compare(a, b);
      return _ascending ? result : -result;
    });
    return list;
  }

  int _compare(Coin a, Coin b) {
    switch (_sort) {
      case CoinSort.marketCap:
        return (a.marketCap ?? -1).compareTo(b.marketCap ?? -1);
      case CoinSort.price:
        return a.price.compareTo(b.price);
      case CoinSort.change:
        return a.changePercent.compareTo(b.changePercent);
      case CoinSort.volume:
        return a.quoteVolume.compareTo(b.quoteVolume);
      case CoinSort.name:
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    }
  }

  Coin? bySymbol(String symbol) {
    for (final coin in _coins) {
      if (coin.symbol == symbol) return coin;
    }
    return null;
  }

  void start() {
    if (_timer != null) return;
    load();
    _timer = Timer.periodic(AppConstants.refreshInterval, (_) => refresh());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> load() async {
    _state = LoadState.loading;
    notifyListeners();
    await refresh();
  }

  Future<void> refresh() async {
    try {
      _coins = await _service.fetchCoins();
      _updatedAt = DateTime.now();
      _state = LoadState.ready;
    } catch (e) {
      if (_coins.isEmpty) {
        _error = e.toString();
        _state = LoadState.error;
      }
    }
    notifyListeners();
  }

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  void setFilter(CoinFilter value) {
    _filter = value;
    notifyListeners();
  }

  void setSort(CoinSort value) {
    if (_sort == value) {
      _ascending = !_ascending;
    } else {
      _sort = value;
      _ascending = value == CoinSort.name;
    }
    notifyListeners();
  }

  void toggleDirection() {
    _ascending = !_ascending;
    notifyListeners();
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }
}
