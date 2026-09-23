import 'package:cardvault/core/utils/money.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formats Indian paise grouping', () {
    expect(formatPaise(50000), '₹500.00');
    expect(formatPaise(123456789), '₹12,34,567.89');
    expect(formatPaise(-1250), '-₹12.50');
    expect(formatPaise(100, includeSymbol: false), '1.00');
    expect(formatIndianInteger(1234567), '12,34,567');
  });

  test('parses comma and decimal input into paise', () {
    expect(parsePaise('1,234.50'), 123450);
    expect(parsePaise('1,23,456.78'), 12345678);
    expect(parsePaise('500'), 50000);
    expect(parsePaise('500.5'), 50050);
    expect(parsePaise('-12.50', allowNegative: true), -1250);
  });

  test('rejects invalid money input', () {
    expect(() => parsePaise(null), throwsA(isA<MoneyFormatException>()));
    expect(() => parsePaise(''), throwsA(isA<MoneyFormatException>()));
    expect(() => parsePaise('   '), throwsA(isA<MoneyFormatException>()));
    expect(() => parsePaise('12.345'), throwsA(isA<MoneyFormatException>()));
    expect(() => parsePaise('-1'), throwsA(isA<MoneyFormatException>()));
    expect(() => parsePaise('abc'), throwsA(isA<MoneyFormatException>()));
    expect(() => parsePaise('12,34.5.0'), throwsA(isA<MoneyFormatException>()));
    expect(
      () => parsePaise('123456789012'),
      throwsA(isA<MoneyFormatException>()),
    );
  });
}
