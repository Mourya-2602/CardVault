import 'package:flutter_riverpod/flutter_riverpod.dart';

class SessionState {
  const SessionState({required this.isAuthenticated});

  const SessionState.loggedOut() : isAuthenticated = false;

  const SessionState.loggedIn() : isAuthenticated = true;

  final bool isAuthenticated;
}

class SessionController extends Notifier<SessionState> {
  @override
  SessionState build() => const SessionState.loggedOut();

  void signInForPreview() {
    state = const SessionState.loggedIn();
  }

  void signOut() {
    state = const SessionState.loggedOut();
  }
}

final sessionProvider = NotifierProvider<SessionController, SessionState>(
  SessionController.new,
);
