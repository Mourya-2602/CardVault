import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/state/session_provider.dart';
import 'routes.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final session = ref.watch(sessionProvider);

  return GoRouter(
    initialLocation: AppRoutes.login,
    redirect: (context, state) {
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
        builder: (context, state) => const LoginPlaceholderScreen(),
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
});

class LoginPlaceholderScreen extends ConsumerWidget {
  const LoginPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('CardVault')),
      body: Center(
        child: FilledButton(
          onPressed: () =>
              ref.read(sessionProvider.notifier).signInForPreview(),
          child: const Text('Enter preview'),
        ),
      ),
    );
  }
}

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
            onPressed: () => ref.read(sessionProvider.notifier).signOut(),
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
