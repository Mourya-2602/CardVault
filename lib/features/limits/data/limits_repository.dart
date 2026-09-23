import '../../../core/network/api_client.dart';
import '../../../core/utils/json.dart';
import '../../cards/domain/limits.dart';

class LimitsRepository {
  LimitsRepository(this._client);

  final ApiClient _client;

  Future<CardLimits> getLimits(String cardId) {
    return runApi(_client, () async {
      final response = await _client.get<Map<String, dynamic>>(
        '/cards/$cardId/limits',
      );
      return CardLimits.fromJson(asJsonMap(response.data));
    });
  }

  Future<CardLimits> saveLimits(String cardId, CardLimits limits) {
    return runApi(_client, () async {
      final response = await _client.put<Map<String, dynamic>>(
        '/cards/$cardId/limits',
        data: limits.toJson(),
      );
      return CardLimits.fromJson(asJsonMap(response.data));
    });
  }
}
