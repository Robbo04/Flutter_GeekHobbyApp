// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_geek_hobby_app/main.dart';
import 'package:app_geek_hobby_app/Services/rawg_service.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build a mock RawgService for tests.
    final mockClient = MockClient((request) async {
      // Minimal safe response for any /games call.
      return http.Response('{"results": []}', 200);
    });
    final rawgService = RawgService(apiKey: 'test', httpClient: mockClient);

    // IMPORTANT: set the singleton so widgets that use RawgService.instance work.
    RawgService.instance = rawgService;

    // Pump the app (remove `const` because we pass runtime args).
    await tester.pumpWidget(MyApp(rawgService: rawgService));

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
