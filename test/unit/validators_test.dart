import 'package:cardvault/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('required validator rejects blank values', () {
    expect(validateRequired(null, label: 'Email'), 'Email is required.');
    expect(validateRequired('  ', label: 'Email'), 'Email is required.');
    expect(validateRequired('ok', label: 'Email'), isNull);
  });

  test('international until rejects dates already in the past', () {
    final now = DateTime(2026, 9, 23);
    expect(validateInternationalUntil(DateTime(2026, 9, 22), now), isNotNull);
    expect(validateInternationalUntil(DateTime(2026, 9, 23), now), isNull);
    expect(validateInternationalUntil(null, now), isNull);
  });

  test('clampPaise stays within bank maximum', () {
    expect(clampPaise(120, 100), 100);
    expect(clampPaise(-5, 100), 0);
    expect(clampPaise(40, 100), 40);
  });
}
