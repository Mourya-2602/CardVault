import 'package:cardvault/app/app.dart';
import 'package:cardvault/core/security/secure_session_store.dart';
import 'package:cardvault/features/auth/data/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  const app = CardVaultApp();

  ProviderScope buildTestApp() {
    return ProviderScope(
      overrides: [
        secureSessionStoreProvider.overrideWithValue(InMemorySessionStore()),
      ],
      child: app,
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
