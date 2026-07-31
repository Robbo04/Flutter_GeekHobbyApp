import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_geek_hobby_app/widgets/common/app_title_text.dart';

void main() {
  testWidgets('AppTitleText renders long selectable titles at large text scale', (
    WidgetTester tester,
  ) async {
    const longTitle =
        'The Extremely Long Franchise Title That Should Still Be Fully Visible In Detail Views';

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.6)),
          child: const Scaffold(
            body: Center(
              child: AppTitleText(
                longTitle,
                selectable: true,
                maxLines: null,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.textContaining('Extremely Long Franchise Title'), findsOneWidget);
  });

  testWidgets('AppTitleText supports truncated card mode with tooltip', (
    WidgetTester tester,
  ) async {
    const longTitle =
        'A Very Long Name That Needs Truncation In Tight Card Layouts';

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.4)),
          child: Scaffold(
            body: SizedBox(
              width: 120,
              child: AppTitleText(
                longTitle,
                maxLines: 2,
                style: ThemeData().textTheme.bodySmall,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(Tooltip), findsOneWidget);
    expect(find.textContaining('Very Long Name'), findsOneWidget);
  });
}
