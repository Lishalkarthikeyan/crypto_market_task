import 'package:crypto_market/core/formatters.dart';
import 'package:crypto_market/core/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Fmt.price', () {
    test('formats large prices with grouping', () {
      expect(Fmt.price(67432.5), '\$67,432.50');
    });

    test('keeps more decimals for small prices', () {
      expect(Fmt.price(0.0123), '\$0.0123');
      expect(Fmt.price(0.00001234), '\$0.00001234');
    });
  });

  group('Fmt.percent', () {
    test('adds a plus sign for gains', () {
      expect(Fmt.percent(2.345), '+2.35%');
    });

    test('keeps the minus sign for losses', () {
      expect(Fmt.percent(-1.2), '-1.20%');
    });
  });

  group('Validators', () {
    test('email', () {
      expect(Validators.email('a@b.com'), isNull);
      expect(Validators.email('nope'), isNotNull);
    });

    test('password length', () {
      expect(Validators.password('12345'), isNotNull);
      expect(Validators.password('123456'), isNull);
    });
  });
}
