import 'package:app_geek_hobby_app/screens/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Settings page shows quick actions and profile local-mode message', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SettingsPage(),
      ),
    );

    expect(find.text('Profile'), findsOneWidget);
    expect(find.textContaining('local mode'), findsOneWidget);
    expect(find.text('Quick Actions'), findsOneWidget);
    expect(find.text('Explore Games and Anime'), findsOneWidget);
    expect(find.text('Open Suggestions'), findsOneWidget);
    expect(find.text('View Collections'), findsOneWidget);
  });
}
