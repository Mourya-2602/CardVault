import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/login_screen.dart';
import '../features/auth/state/session_provider.dart';
import 'routes.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: AppRoutes.login,
    redirect: (context, state) {
      final session = ref.read(sessionProvider);
      final isLoginRoute = state.matchedLocation == AppRoutes.login;

      if (!session.isAuthenticated && !isLoginRoute) {
        return AppRoutes.login;
      }
      if (session.isAuthenticated && isLoginRoute) {
        return AppRoutes.cards;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.cards,
        builder: (context, state) => const PlaceholderScreen(title: 'Cards'),
      ),
      GoRoute(
        path: AppRoutes.card,
        builder: (context, state) =>
            PlaceholderScreen(title: 'Card ${state.pathParameters['id']}'),
      ),
      GoRoute(
        path: AppRoutes.limits,
        builder: (context, state) => const PlaceholderScreen(title: 'Limits'),
      ),
      GoRoute(
        path: AppRoutes.reveal,
        builder: (context, state) =>
            const PlaceholderScreen(title: 'Reveal card details'),
      ),
      GoRoute(
        path: AppRoutes.credit,
        builder: (context, state) =>
            const PlaceholderScreen(title: 'Credit summary'),
      ),
      GoRoute(
        path: AppRoutes.statements,
        builder: (context, state) =>
            const PlaceholderScreen(title: 'Statements'),
      ),
      GoRoute(
        path: AppRoutes.statement,
        builder: (context, state) => PlaceholderScreen(
          title: 'Statement ${state.pathParameters['month']}',
        ),
      ),
      GoRoute(
        path: AppRoutes.pay,
        builder: (context, state) =>
            const PlaceholderScreen(title: 'Pay card bill'),
      ),
      GoRoute(
        path: AppRoutes.block,
        builder: (context, state) =>
            const PlaceholderScreen(title: 'Block card'),
      ),
    ],
  );

  ref.listen(sessionProvider, (_, _) => router.refresh());
  ref.onDispose(router.dispose);
  return router;
});

class PlaceholderScreen extends ConsumerWidget {
  const PlaceholderScreen({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            onPressed: () async {
              await ref.read(sessionProvider.notifier).signOut();
              if (context.mounted) {
                context.go(AppRoutes.login);
              }
            },
            tooltip: 'Log out',
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Text(
          '$title placeholder',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}
