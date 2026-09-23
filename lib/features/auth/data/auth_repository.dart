import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/bank_error.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_config.dart';
import '../../../core/security/secure_session_store.dart';
import '../../../core/utils/json.dart';

class AuthRepository {
  AuthRepository({required this.sessionStore, required this.apiClient});

  final SessionStore sessionStore;
  final ApiClient apiClient;

  Future<bool> restoreSession() async {
    final token = await sessionStore.readToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> login({required String email, required String password}) async {
    if (email.trim().isEmpty || password.isEmpty) {
      throw const ValidationBankError(
        message: 'Enter your email and password.',
      );
    }

    await runApi(apiClient, () async {
      final response = await apiClient.post<Map<String, dynamic>>(
        '/auth/login',
        data: {'email': email.trim(), 'password': password},
      );
      final body = asJsonMap(response.data);
      final token = body['token'] as String?;
      if (token == null || token.isEmpty) {
        throw const UnknownBankError();
      }
      await sessionStore.writeToken(token);
    });
  }

  Future<void> logout() => sessionStore.clear();
}

final apiConfigProvider = Provider<ApiConfig>((ref) {
  return ApiConfig.fromEnvironment();
});

final secureSessionStoreProvider = Provider<SessionStore>((ref) {
  return SecureSessionStore();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    config: ref.watch(apiConfigProvider),
    sessionStore: ref.watch(secureSessionStoreProvider),
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    sessionStore: ref.watch(secureSessionStoreProvider),
    apiClient: ref.watch(apiClientProvider),
  );
});
