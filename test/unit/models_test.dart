import 'package:cardvault/features/cards/domain/card.dart';
import 'package:cardvault/features/cards/domain/controls.dart';
import 'package:cardvault/features/cards/domain/limits.dart';
import 'package:cardvault/features/credit/domain/credit_summary.dart';
import 'package:cardvault/features/statements/domain/statement.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses uppercase API card status values', () {
    final card = CardModel.fromJson({
      'id': 'card-1',
      'type': 'CREDIT',
      'network': 'VISA',
      'maskedNumber': '**** 1234',
      'expiry': '12/28',
      'status': 'ACTIVE',
    });

    expect(card.type, CardType.credit);
    expect(card.network, CardNetwork.visa);
    expect(card.status, CardStatus.active);
    expect(card.toJson()['status'], 'active');
  });

  test('converts UTC API dates to local time', () {
    final summary = CreditSummary.fromJson({
      'limitPaise': 100000,
      'availablePaise': 90000,
      'outstandingPaise': 10000,
      'minDuePaise': 500,
      'dueDate': '2026-09-23T00:00:00Z',
    });

    expect(summary.dueDate.isUtc, isFalse);
    expect(summary.isDueWithinDays(3, DateTime(2026, 9, 21)), isTrue);
  });

  test('parses controls, limits, and statement transactions', () {
    final controls = CardControls.fromJson({
      'online': true,
      'contactless': false,
      'atm': true,
      'international': false,
      'internationalUntil': null,
    });
    final limits = CardLimits.fromJson({
      'atmDailyPaise': 10000,
      'posDailyPaise': 20000,
      'onlineDailyPaise': 30000,
      'maxPaise': 50000,
    });
    final statement = Statement.fromJson({
      'month': '2026-09',
      'openingPaise': 1000,
      'closingPaise': 2000,
      'transactions': [
        {
          'id': 'txn-1',
          'date': '2026-09-01T00:00:00Z',
          'merchant': 'Cafe',
          'amountPaise': 1000,
          'category': 'Food',
        },
      ],
    });

    expect(controls.online, isTrue);
    expect(limits.maxPaise, 50000);
    expect(statement.transactions.single.amountPaise, 1000);
    expect(statement.transactions.single.date.isUtc, isFalse);
  });

  test('rejects non-integer money fields', () {
    expect(
      () => CardLimits.fromJson({
        'atmDailyPaise': 10.5,
        'posDailyPaise': 20000,
        'onlineDailyPaise': 30000,
        'maxPaise': 50000,
      }),
      throwsA(isA<FormatException>()),
    );
  });
}
