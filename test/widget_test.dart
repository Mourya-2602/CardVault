import 'package:cardvault/app/app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('logged-out users start on login', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: CardVaultApp()));
    await tester.pumpAndSettle();

    expect(find.text('Enter preview'), findsOneWidget);
    expect(find.text('Cards placeholder'), findsNothing);
  });

  testWidgets('preview sign-in reaches the protected cards route', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: CardVaultApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Enter preview'));
    await tester.pumpAndSettle();

    expect(find.text('Cards placeholder'), findsOneWidget);
    expect(find.byTooltip('Log out'), findsOneWidget);
  });

  testWidgets('logging out returns to login', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: CardVaultApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Enter preview'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Log out'));
    await tester.pumpAndSettle();

    expect(find.text('Enter preview'), findsOneWidget);
  });
}
