// Smoke test: the app boots on the splash screen without throwing. This is a
// UI-fidelity port (see the implementation plan), not a business-logic app,
// so exhaustive widget tests aren't the priority here — this just guards
// against a build-breaking regression.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wazi_mobile/main.dart';

void main() {
  testWidgets('app boots on the splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const WaziApp());
    await tester.pump();

    expect(find.text('wazi'), findsOneWidget);
    expect(find.text('JUST SAY IT.'), findsOneWidget);

    // Splash has repeating pulse-ring animations that run forever by
    // design. Unmount the tree so their AnimationControllers (and
    // AppState's pending 2.4s auto-advance timer) get disposed properly,
    // rather than leaving the test binding to flag them as leaked.
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
