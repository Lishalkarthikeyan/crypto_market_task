import 'package:flutter/foundation.dart';

import '../models/coin.dart';
import '../models/kline.dart';
import '../services/coin_service.dart';
import 'market_provider.dart';

class DetailProvider extends ChangeNotifier {
  final CoinService _service;
  final String symbol;

  DetailProvider(this._service, this.symbol, Coin? initial) : _coin = initial;

  Coin? _coin;
  List<Kline> _klines = [];
  ChartRange _range = ChartRange.all[1];
  LoadState _state = LoadState.loading;
  String _error = '';
  bool _chartLoading = true;
  String _chartError = '';
  int _requestId = 0;

  Coin? get coin => _coin;
  List<Kline> get klines => _klines;
  ChartRange get range => _range;
  LoadState get state => _state;
  String get error => _error;
  bool get chartLoading => _chartLoading;
  String get chartError => _chartError;

  Future<void> load() async {
    _state = _coin == null ? LoadState.loading : LoadState.ready;
    notifyListeners();

    await Future.wait([_loadCoin(), _loadChart()]);
  }

  Future<void> _loadCoin() async {
    try {
      _coin = await _service.fetchCoin(symbol);
      _state = LoadState.ready;
    } catch (e) {
      if (_coin == null) {
        _error = e.toString();
        _state = LoadState.error;
      }
    }
    notifyListeners();
  }

  Future<void> _loadChart() async {
    final id = ++_requestId;
    _chartLoading = true;
    _chartError = '';
    notifyListeners();

    try {
      final data = await _service.fetchKlines(symbol, _range);
      if (id != _requestId) return;
      _klines = data;
    } catch (e) {
      if (id != _requestId) return;
      _klines = [];
      _chartError = e.toString();
    }
    _chartLoading = false;
    notifyListeners();
  }

  Future<void> selectRange(ChartRange range) async {
    if (range.label == _range.label) return;
    _range = range;
    await _loadChart();
  }

  Future<void> reloadChart() => _loadChart();
}
