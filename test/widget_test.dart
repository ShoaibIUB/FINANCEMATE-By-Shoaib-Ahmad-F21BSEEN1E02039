// ignore: prefer_double_quotes
import 'package:flutter/material.dart';
// ignore: prefer_double_quotes
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ignore: prefer_double_quotes
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp() as Widget);

    // Verify that our counter starts at 0.
    // ignore: prefer_double_quotes
    expect(find.text('0'), findsOneWidget);
    // ignore: prefer_double_quotes
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    // ignore: prefer_double_quotes
    expect(find.text('0'), findsNothing);
    // ignore: prefer_double_quotes
    expect(find.text('1'), findsOneWidget);
  });
}

class MyApp {
  const MyApp();
}
