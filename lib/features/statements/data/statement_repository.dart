import '../../../core/network/api_client.dart';
import '../../../core/utils/json.dart';
import '../domain/statement.dart';
import '../domain/statement_month.dart';

class StatementRepository {
  StatementRepository(this._client);

  final ApiClient _client;

  Future<List<StatementMonth>> listMonths(String cardId) {
    return runApi(_client, () async {
      final response = await _client.get<Map<String, dynamic>>(
        '/cards/$cardId/statements',
      );
      final body = asJsonMap(response.data);
      final items = body['statements'] as List<dynamic>? ?? const [];
      return items
          .map((item) => StatementMonth.fromJson(asJsonMap(item)))
          .toList(growable: false);
    });
  }

  Future<Statement> getStatement(String cardId, String month) {
    return runApi(_client, () async {
      final response = await _client.get<Map<String, dynamic>>(
        '/cards/$cardId/statements/$month',
      );
      return Statement.fromJson(asJsonMap(response.data));
    });
  }
}
