import '../../../core/network/api_client.dart';
import '../../../core/utils/json.dart';
import '../../block/domain/block_result.dart';
import '../domain/card.dart';
import '../domain/revealed_card.dart';

class CardRepository {
  CardRepository(this._client);

  final ApiClient _client;

  Future<List<CardModel>> listCards() {
    return runApi(_client, () async {
      final response = await _client.get<Map<String, dynamic>>('/cards');
      final body = asJsonMap(response.data);
      final cards = body['cards'] as List<dynamic>? ?? const [];
      return cards
          .map((item) => CardModel.fromJson(asJsonMap(item)))
          .toList(growable: false);
    });
  }

  Future<CardModel> getCard(String id) {
    return runApi(_client, () async {
      final response = await _client.get<Map<String, dynamic>>('/cards/$id');
      return CardModel.fromJson(asJsonMap(response.data));
    });
  }

  Future<CardModel> updateStatus(String id, CardStatus status) {
    return runApi(_client, () async {
      final response = await _client.patch<Map<String, dynamic>>(
        '/cards/$id/status',
        data: {'status': status.name},
      );
      return CardModel.fromJson(asJsonMap(response.data));
    });
  }

  Future<RevealedCard> reveal(String id) {
    return runApi(_client, () async {
      final response = await _client.post<Map<String, dynamic>>(
        '/cards/$id/reveal',
      );
      return RevealedCard.fromJson(asJsonMap(response.data));
    });
  }

  Future<({CardModel card, ReplacementInfo replacement})> blockCard({
    required String id,
    required String reason,
    required bool requestReplacement,
  }) {
    return runApi(_client, () async {
      final response = await _client.post<Map<String, dynamic>>(
        '/cards/$id/block',
        data: {'reason': reason, 'requestReplacement': requestReplacement},
      );
      final body = asJsonMap(response.data);
      return (
        card: CardModel.fromJson(body),
        replacement: ReplacementInfo.fromJson(asJsonMap(body['replacement'])),
      );
    });
  }
}
