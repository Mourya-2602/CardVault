import 'package:cardvault/core/utils/date_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('converts ISO-8601 UTC timestamps to local time', () {
    final local = parseUtcToLocal('2026-09-23T00:00:00Z');
    expect(local.isUtc, isFalse);
    expect(local.toUtc(), DateTime.utc(2026, 9, 23));
  });

  test('formats local calendar dates as dd/MM/yyyy', () {
    expect(formatLocalDate(DateTime(2026, 9, 3)), '03/09/2026');
  });
}
