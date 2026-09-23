import 'package:cardvault/core/network/api_client.dart';
import 'package:cardvault/core/network/api_config.dart';
import 'package:cardvault/core/security/secure_session_store.dart';
import 'package:dio/dio.dart';

import 'scripted_adapter.dart';

ApiClient scriptedClient(
  Future<ResponseSpec> Function(RequestOptions options) handler,
) {
  final dio = Dio(BaseOptions(baseUrl: 'http://cardvault.test'));
  dio.httpClientAdapter = ScriptedAdapter(handler);
  return ApiClient(
    config: const ApiConfig(
      environment: AppEnvironment.dev,
      baseUrl: 'http://cardvault.test',
    ),
    sessionStore: InMemorySessionStore(),
    dio: dio,
  );
}

Map<String, Object?> apiError({required String code, required String message}) {
  return {
    'error': {'code': code, 'message': message, 'traceId': 'trc-test'},
  };
}
