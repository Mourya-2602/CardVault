import 'package:cardvault/app/app.dart';
import 'package:cardvault/core/network/api_client.dart';
import 'package:cardvault/features/auth/data/auth_repository.dart';
import 'package:cardvault/core/security/secure_session_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/scripted_adapter.dart';
import 'helpers/scripted_client.dart';

void main() {
  ProviderScope buildTestApp() {
    final store = InMemorySessionStore();
    return ProviderScope(
      overrides: [
        secureSessionStoreProvider.overrideWithValue(store),
        apiClientProvider.overrideWithValue(
          scriptedClient((options) async {
            if (options.path == '/auth/login') {
              return const ResponseSpec(
                statusCode: 200,
                body: {'token': 'test-token', 'email': 'demo@cardvault.local'},
              );
            }
            return const ResponseSpec(statusCode: 404, body: {});
          }),
        ),
      ],
      child: const CardVaultApp(),
    );
  }

  testWidgets('logged-out users start on login', (tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    expect(find.widgetWithText(FilledButton, 'Sign in'), findsOneWidget);
    expect(find.text('Cards placeholder'), findsNothing);
  });

  testWidgets('valid sign-in reaches the protected cards route', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextField).at(0),
      'demo@cardvault.local',
    );
    await tester.enterText(find.byType(TextField).at(1), 'cardvault');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();
    expect(find.text('Cards placeholder'), findsOneWidget);
    expect(find.byTooltip('Log out'), findsOneWidget);
  });

  testWidgets('logging out returns to login', (tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextField).at(0),
      'demo@cardvault.local',
    );
    await tester.enterText(find.byType(TextField).at(1), 'cardvault');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Log out'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(FilledButton, 'Sign in'), findsOneWidget);
  });
}
