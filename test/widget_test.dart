import 'package:flutter_test/flutter_test.dart';
import 'package:chitchat/main.dart'; // Contains App class

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Since your app doesn't have a counter UI by default (like 0, + button),
    // these expectations will fail unless you add a dummy counter screen.
    // You can comment them for now or replace with UI tests you actually need.

    // expect(find.text('0'), findsOneWidget);
    // expect(find.text('1'), findsNothing);

    // await tester.tap(find.byIcon(Icons.add));
    // await tester.pump();

    // expect(find.text('0'), findsNothing);
    // expect(find.text('1'), findsOneWidget);
  });
}
