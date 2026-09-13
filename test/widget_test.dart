import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mafia_radical/main.dart';

void main() {
  testWidgets('App launches without crashing', (WidgetTester tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const MafiaRadicalApp());
    // The cinematic home intentionally contains repeating animations, so
    // pumpAndSettle() would wait forever. A bounded frame is enough for this
    // smoke test to verify that the app mounts and builds without exceptions.
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
