import 'package:flutter_test/flutter_test.dart';
import 'package:mafia_radical/main.dart';

void main() {
  testWidgets('Mafia Radical starts successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const MafiaGame());
    await tester.pump();

    expect(find.text('Mafia Radical'), findsOneWidget);
    expect(find.text('Welcome to Mafia Game!'), findsOneWidget);
    expect(find.text('🎮 Friendly Game (Free)'), findsOneWidget);
    expect(find.text('🏆 Ranked Game (100 Coins)'), findsOneWidget);
  });
}
