import 'package:cardvault/core/errors/bank_error.dart';
import 'package:cardvault/features/cards/data/card_repository.dart';
import 'package:cardvault/features/cards/domain/card.dart';
import 'package:cardvault/features/payments/data/bill_payment_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/scripted_adapter.dart';
import '../helpers/scripted_client.dart';

void main() {
  test('lists cards from a successful payload', () async {
    final repository = CardRepository(
      scriptedClient((options) async {
        expect(options.path, '/cards');
        return const ResponseSpec(
          statusCode: 200,
          body: {
            'cards': [
              {
                'id': 'card-1',
                'type': 'credit',
                'network': 'visa',
                'maskedNumber': '**** 1234',
                'expiry': '12/28',
                'status': 'ACTIVE',
              },
            ],
          },
        );
      }),
    );

    final cards = await repository.listCards();
    expect(cards.single.id, 'card-1');
    expect(cards.single.status, CardStatus.active);
  });

  test('maps 401 into UnauthorizedBankError', () async {
    final repository = CardRepository(
      scriptedClient((options) async {
        return ResponseSpec(
          statusCode: 401,
          body: apiError(
            code: 'UNAUTHORIZED',
            message: 'Your session has expired.',
          ),
        );
      }),
    );

    expect(repository.listCards(), throwsA(isA<UnauthorizedBankError>()));
  });

  test('maps 403, 404, 409 and 422 into BankError types', () async {
    Future<void> expectStatus(int status, Matcher matcher) async {
      final repository = CardRepository(
        scriptedClient((options) async {
          return ResponseSpec(
            statusCode: status,
            body: apiError(code: '$status', message: 'plain language'),
          );
        }),
      );
      expect(repository.listCards(), throwsA(matcher));
    }

    await expectStatus(403, isA<ForbiddenBankError>());
    await expectStatus(404, isA<NotFoundBankError>());
    await expectStatus(409, isA<ConflictBankError>());
    await expectStatus(422, isA<ValidationBankError>());
  });

  test('maps timeout and connection errors', () async {
    final timeoutRepo = CardRepository(
      scriptedClient(
        (options) async =>
            const ResponseSpec(statusCode: 0, body: {}, timeout: true),
      ),
    );
    final networkRepo = CardRepository(
      scriptedClient(
        (options) async =>
            const ResponseSpec(statusCode: 0, body: {}, connectionError: true),
      ),
    );

    expect(timeoutRepo.listCards(), throwsA(isA<TimeoutBankError>()));
    expect(networkRepo.listCards(), throwsA(isA<NetworkBankError>()));
  });

  test('reuses Idempotency-Key and does not expose DioException', () async {
    var calls = 0;
    final repository = BillPaymentRepository(
      scriptedClient((options) async {
        calls += 1;
        expect(options.headers['Idempotency-Key'], 'pay-1');
        return const ResponseSpec(
          statusCode: 200,
          body: {
            'paymentId': 'pay_1',
            'amountPaise': 1000,
            'outstandingPaise': 2000,
            'status': 'success',
            'debitCount': 1,
          },
        );
      }),
    );

    final first = await repository.pay(
      cardId: 'card-credit-1',
      amountPaise: 1000,
      idempotencyKey: 'pay-1',
    );
    final second = await repository.pay(
      cardId: 'card-credit-1',
      amountPaise: 1000,
      idempotencyKey: 'pay-1',
    );

    expect(first.paymentId, second.paymentId);
    expect(calls, 2);
    expect(
      first,
      isNot(
        isA<Exception>().having((e) => e.toString(), 'dio', contains('Dio')),
      ),
    );
  });
}
