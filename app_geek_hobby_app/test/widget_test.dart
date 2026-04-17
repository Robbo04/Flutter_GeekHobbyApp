// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:app_geek_hobby_app/main.dart';
import 'package:app_geek_hobby_app/Services/rawg_service.dart';
import 'package:app_geek_hobby_app/Services/anilist_service.dart';
import 'package:app_geek_hobby_app/Classes/anime.dart';
import 'package:app_geek_hobby_app/Classes/anime_group.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Initialize Hive for testing
    Hive.init('./test_hive');
    Hive.registerAdapter(AnimeAdapter());
    Hive.registerAdapter(AnimeGroupAdapter());
    await Hive.openBox<Anime>('anilist_anime');
    await Hive.openBox<List>('anilist_search_results');
    await Hive.openBox<int>('anilist_cache_meta');
    await Hive.openBox<AnimeGroup>('anilist_groups');
    await Hive.openBox<int>('anilist_anime_to_group');
    await Hive.openBox<int>('anilist_stats');

    // Build a mock RawgService for tests.
    final mockClient = MockClient((request) async {
      // Minimal safe response for any /games call.
      return http.Response('{"results": []}', 200);
    });
    final rawgService = RawgService(apiKey: 'test', httpClient: mockClient);
    final aniListService = AniListService();

    // IMPORTANT: set the singleton so widgets that use the services work.
    RawgService.instance = rawgService;
    AniListService.instance = aniListService;

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
