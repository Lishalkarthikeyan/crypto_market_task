import 'package:intl/intl.dart';

class Fmt {
  static final NumberFormat _compact = NumberFormat.compact();
  static final NumberFormat _grouped = NumberFormat('#,##0.##');

  static String price(double value) {
    if (value >= 1000) return '\$${NumberFormat('#,##0.00').format(value)}';
    if (value >= 1) return '\$${value.toStringAsFixed(2)}';
    if (value >= 0.01) return '\$${value.toStringAsFixed(4)}';
    if (value >= 0.0001) return '\$${value.toStringAsFixed(6)}';
    return '\$${value.toStringAsFixed(8)}';
  }

  static String usdCompact(double? value) {
    if (value == null) return '--';
    return '\$${_compact.format(value)}';
  }

  static String compact(double? value) {
    if (value == null) return '--';
    return _compact.format(value);
  }

  static String number(double? value) {
    if (value == null) return '--';
    return _grouped.format(value);
  }

  static String percent(double value) {
    final sign = value > 0 ? '+' : '';
    return '$sign${value.toStringAsFixed(2)}%';
  }

  static String dateTime(DateTime value) =>
      DateFormat('d MMM, HH:mm').format(value);

  static String date(DateTime value) => DateFormat('d MMM yyyy').format(value);
}
