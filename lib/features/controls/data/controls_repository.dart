import '../../../core/network/api_client.dart';
import '../../../core/utils/json.dart';
import '../../cards/domain/controls.dart';

class ControlsRepository {
  ControlsRepository(this._client);

  final ApiClient _client;

  Future<CardControls> getControls(String cardId) {
    return runApi(_client, () async {
      final response = await _client.get<Map<String, dynamic>>(
        '/cards/$cardId/controls',
      );
      return CardControls.fromJson(asJsonMap(response.data));
    });
  }

  Future<CardControls> saveControls(String cardId, CardControls controls) {
    return runApi(_client, () async {
      final response = await _client.put<Map<String, dynamic>>(
        '/cards/$cardId/controls',
        data: controls.toJson(),
      );
      return CardControls.fromJson(asJsonMap(response.data));
    });
  }
}
