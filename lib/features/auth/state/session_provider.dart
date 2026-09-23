import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_repository.dart';

class SessionState {
  const SessionState({required this.isAuthenticated});

  const SessionState.loggedOut() : isAuthenticated = false;

  const SessionState.loggedIn() : isAuthenticated = true;

  final bool isAuthenticated;
}

class SessionController extends Notifier<SessionState> {
  @override
  SessionState build() {
    Future<void>.microtask(restoreSession);
    return const SessionState.loggedOut();
  }

  AuthRepository get _repository => ref.read(authRepositoryProvider);

  Future<void> restoreSession() async {
    if (await _repository.restoreSession()) {
      state = const SessionState.loggedIn();
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    await _repository.login(email: email, password: password);
    state = const SessionState.loggedIn();
  }

  Future<void> signOut() async {
    await _repository.logout();
    state = const SessionState.loggedOut();
  }
}

final sessionProvider = NotifierProvider<SessionController, SessionState>(
  SessionController.new,
);
