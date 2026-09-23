import '../../../core/network/api_client.dart';
import '../../../core/utils/json.dart';
import '../domain/alert.dart';

class AlertRepository {
  AlertRepository(this._client);

  final ApiClient _client;

  Future<List<TransactionAlert>> listAlerts() {
    return runApi(_client, () async {
      final response = await _client.get<Map<String, dynamic>>('/alerts');
      final body = asJsonMap(response.data);
      final items = body['alerts'] as List<dynamic>? ?? const [];
      return items
          .map((item) => TransactionAlert.fromJson(asJsonMap(item)))
          .toList(growable: false);
    });
  }
}
