import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/constants.dart';

class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

  @override
  String toString() => message;
}

class BinanceApi {
  final http.Client _client;
  int _hostIndex = 0;

  BinanceApi({http.Client? client}) : _client = client ?? http.Client();

  Future<dynamic> get(String path, {Map<String, String>? query}) async {
    final hosts = AppConstants.binanceHosts;

    for (var attempt = 0; attempt < hosts.length; attempt++) {
      final index = (_hostIndex + attempt) % hosts.length;
      final uri = Uri.parse('${hosts[index]}$path').replace(queryParameters: query);

      try {
        final response =
            await _client.get(uri).timeout(AppConstants.requestTimeout);

        if (response.statusCode == 400) {
          throw const ApiException('Coin not found');
        }
        if (response.statusCode == 429 || response.statusCode == 418) {
          throw const ApiException('Too many requests. Please wait a moment.');
        }
        if (response.statusCode != 200) continue;

        _hostIndex = index;
        return jsonDecode(response.body);
      } on ApiException {
        rethrow;
      } on TimeoutException {
        continue;
      } catch (_) {
        continue;
      }
    }

    throw const ApiException(
      'Unable to reach Binance. Check your connection or try a VPN.',
    );
  }
}
