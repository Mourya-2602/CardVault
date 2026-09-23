import '../../../core/network/api_client.dart';
import '../../../core/utils/json.dart';
import '../domain/payment.dart';

class BillPaymentRepository {
  BillPaymentRepository(this._client);

  final ApiClient _client;

  Future<BillPaymentResult> pay({
    required String cardId,
    required int amountPaise,
    required String idempotencyKey,
  }) {
    return runApi(_client, () async {
      final response = await _client.post<Map<String, dynamic>>(
        '/cards/$cardId/payments',
        data: {'amountPaise': amountPaise, 'source': 'savings'},
        idempotencyKey: idempotencyKey,
      );
      return BillPaymentResult.fromJson(asJsonMap(response.data));
    });
  }
}
