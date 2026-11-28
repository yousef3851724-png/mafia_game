import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mafia_radical/main.dart';

void main() {
  testWidgets('App launches without crashing', (WidgetTester tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});

    // main() normally supplies ProviderScope around MafiaRadicalApp. The test
    // mounts the same production dependency boundary instead of bypassing it.
    await tester.pumpWidget(
      const ProviderScope(child: MafiaRadicalApp()),
    );

    // SplashScreen intentionally waits before routing. Advance past that
    // timer so the smoke test leaves no pending timers behind.
    await tester.pump(const Duration(milliseconds: 2000));
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(Scaffold), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
