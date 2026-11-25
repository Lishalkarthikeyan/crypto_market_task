class Kline {
  final DateTime time;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;

  const Kline({
    required this.time,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  factory Kline.fromRow(List<dynamic> row) {
    return Kline(
      time: DateTime.fromMillisecondsSinceEpoch((row[0] as num).toInt()),
      open: double.parse(row[1].toString()),
      high: double.parse(row[2].toString()),
      low: double.parse(row[3].toString()),
      close: double.parse(row[4].toString()),
      volume: double.parse(row[5].toString()),
    );
  }
}

class ChartRange {
  final String label;
  final String interval;
  final int limit;

  const ChartRange(this.label, this.interval, this.limit);

  static const List<ChartRange> all = [
    ChartRange('24H', '15m', 96),
    ChartRange('7D', '1h', 168),
    ChartRange('1M', '4h', 180),
    ChartRange('3M', '1d', 90),
    ChartRange('1Y', '1d', 365),
  ];
}
