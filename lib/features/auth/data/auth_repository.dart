import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/bank_error.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_config.dart';
import '../../../core/security/secure_session_store.dart';

class AuthRepository {
  AuthRepository({required this._sessionStore, required this._apiClient});

  final SessionStore _sessionStore;
  final ApiClient _apiClient;

  Future<bool> restoreSession() async {
    final token = await _sessionStore.readToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> login({required String email, required String password}) async {
    if (email.trim().isEmpty || password.isEmpty) {
      throw const ValidationBankError(
        message: 'Enter your email and password.',
      );
    }

    if (email.trim().toLowerCase() != 'demo@cardvault.local' ||
        password != 'cardvault') {
      throw const UnauthorizedBankError(
        message: 'The email or password is incorrect.',
      );
    }

    await _sessionStore.writeToken('local-preview-session');
  }

  Future<void> logout() => _sessionStore.clear();

  Future<void> checkApiAvailability() async {
    try {
      await _apiClient.get<void>('/health');
    } catch (error) {
      throw _apiClient.mapError(error);
    }
  }
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
