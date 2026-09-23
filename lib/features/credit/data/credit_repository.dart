import '../../../core/network/api_client.dart';
import '../../../core/utils/json.dart';
import '../domain/credit_summary.dart';

class CreditRepository {
  CreditRepository(this._client);

  final ApiClient _client;

  Future<CreditSummary> getSummary(String cardId) {
    return runApi(_client, () async {
      final response = await _client.get<Map<String, dynamic>>(
        '/cards/$cardId/credit-summary',
      );
      return CreditSummary.fromJson(asJsonMap(response.data));
    });
  }
}
