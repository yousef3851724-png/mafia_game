import 'package:flutter_test/flutter_test.dart';
import 'package:mafia_radical/main.dart';

void main() {
  testWidgets('Mafia Radical starts successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const MafiaGame());
    await tester.pumpAndSettle();

    expect(find.text('انتخاب سناریو و ساخت لابی'), findsOneWidget);
    expect(find.text('سناریوها'), findsOneWidget);
    expect(find.text('ساخت لابی و شروع بازی'), findsOneWidget);
  });
}
