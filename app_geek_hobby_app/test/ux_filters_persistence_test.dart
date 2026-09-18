import 'dart:io';

import 'package:app_geek_hobby_app/enums/age_ratings/game_age.dart';
import 'package:app_geek_hobby_app/enums/genres/game_genre.dart';
import 'package:app_geek_hobby_app/enums/platforms/game_platform.dart';
import 'package:app_geek_hobby_app/models/group/anime_franchise.dart';
import 'package:app_geek_hobby_app/models/item/anime.dart';
import 'package:app_geek_hobby_app/models/item/game.dart';
import 'package:app_geek_hobby_app/models/item/item.dart';
import 'package:app_geek_hobby_app/screens/explore.dart';
import 'package:app_geek_hobby_app/screens/suggestions.dart';
import 'package:app_geek_hobby_app/services/anilist_service.dart';
import 'package:app_geek_hobby_app/services/rawg_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

class _FakeRawgService implements RawgService {

  @override
  Future<List<Game>> fetchGames({
    String search = '',
    String? genre,
    int page = 1,
    int pageSize = 20,
    String ordering = '-added',
    int daysToCache = 30,
    Duration cacheTTLHours = const Duration(days: 3),
    bool searchPrecise = false,
    String excludeStores = '',
    String excludePlatforms = '',
    int minRatingsCount = 0,
  }) async {
    return <Game>[];
  }

  @override
  Future<List<Game>> fetchTrending({
    int days = 30,
    String? genre,
    int page = 1,
    int pageSize = 20,
    String ordering = '-added',
    Duration ttl = const Duration(hours: 24),
    bool softTtl = true,
    int minMetacritic = 60,
    int minRatingsCount = 50,
  }) async {
    return <Game>[];
  }

  @override
  Future<List<Game>> fetchMostPlayed({
    int page = 1,
    int pageSize = 20,
    String? genre,
    Duration cacheTTL = const Duration(days: 7),
  }) async {
    return <Game>[];
  }

  @override
  Future<List<Game>> fetchComingSoon({
    int page = 1,
    int pageSize = 20,
    Duration cacheTTL = const Duration(hours: 12),
  }) async {
    return <Game>[];
  }

  @override
  Future<List<Game>> fetchByGenre({
    required String genre,
    int page = 1,
    int pageSize = 20,
    Duration cacheTTL = const Duration(days: 7),
    int minRatingsCount = 100,
  }) async {
    return <Game>[];
  }

  @override
  Future<List<Game>> fetchByTag({
    required String tag,
    int page = 1,
    int pageSize = 20,
    Duration cacheTTL = const Duration(days: 7),
    int minRatingsCount = 100,
  }) async {
    return <Game>[];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAniListService implements AniListService {
  @override
  Future<List<AnimeFranchise>> searchAnimeFranchises({
    String search = '',
    int page = 1,
    int perPage = 20,
    Duration cacheTTL = const Duration(days: 3),
    int groupTop = 5,
    double fallbackSimilarityThreshold = 0.95,
  }) async {
    return <AnimeFranchise>[];
  }

  @override
  Future<List<AnimeFranchise>> fetchTrendingFranchises({
    int page = 1,
    int perPage = 20,
    Duration cacheTTL = const Duration(days: 3),
    int groupTop = 5,
    double fallbackSimilarityThreshold = 0.95,
  }) async {
    return <AnimeFranchise>[];
  }

  @override
  Future<List<AnimeFranchise>> fetchMostPopularFranchises({
    int page = 1,
    int perPage = 20,
    Duration cacheTTL = const Duration(days: 7),
    int groupTop = 5,
    double fallbackSimilarityThreshold = 0.95,
  }) async {
    return <AnimeFranchise>[];
  }

  @override
  Future<List<AnimeFranchise>> fetchComingSoonFranchises({
    int page = 1,
    int perPage = 20,
    Duration cacheTTL = const Duration(hours: 12),
    int groupTop = 5,
    double fallbackSimilarityThreshold = 0.95,
  }) async {
    return <AnimeFranchise>[];
  }

  @override
  Future<List<AnimeFranchise>> fetchByGenreFranchises({
    required String genre,
    int page = 1,
    int perPage = 20,
    Duration cacheTTL = const Duration(days: 7),
    int groupTop = 5,
    double fallbackSimilarityThreshold = 0.95,
  }) async {
    return <AnimeFranchise>[];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void _registerAdapter<T>(int typeId, TypeAdapter<T> adapter) {
  if (!Hive.isAdapterRegistered(typeId)) {
    Hive.registerAdapter<T>(adapter);
  }
}

Future<void> _openTestBoxes() async {
  await Hive.openBox<Game>('rawg_games');
  await Hive.openBox<List>('rawg_search_results');
  await Hive.openBox<int>('rawg_cache_meta');
  await Hive.openBox<int>('rawg_stats');

  await Hive.openBox<Anime>('anilist_anime');
  await Hive.openBox<List>('anilist_search_results');
  await Hive.openBox<int>('anilist_cache_meta');
  await Hive.openBox<int>('anilist_stats');

  await Hive.openBox<int>('games_wishlist_collection_id');
  await Hive.openBox<int>('games_owned_collection_id');
  await Hive.openBox<int>('games_backlog_collection_id');
  await Hive.openBox<int>('games_completed_collection_id');

  await Hive.openBox<int>('anime_wishlist_collection_id');
  await Hive.openBox<int>('anime_watched_collection_id');

  await Hive.openBox<String>('app_preferences');
}

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('gha_ux_test_');
    Hive.init(tempDir.path);

    _registerAdapter<Item>(1, ItemAdapter());
    _registerAdapter<Game>(2, GameAdapter());
    _registerAdapter<Anime>(5, AnimeAdapter());
    _registerAdapter<GameAge>(21, GameAgeAdapter());
    _registerAdapter<GameGenre>(22, GameGenreAdapter());
    _registerAdapter<GamePlatform>(23, GamePlatformAdapter());

    await _openTestBoxes();

    RawgService.instance = _FakeRawgService();
    AniListService.instance = _FakeAniListService();
  });

  setUp(() async {
    await Hive.box<String>('app_preferences').clear();
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  testWidgets('Suggestions restores and updates content type preference', (tester) async {
    final prefs = Hive.box<String>('app_preferences');
    await prefs.put('suggestions_content_type', ContentType.anime.name);

    await tester.pumpWidget(
      const MaterialApp(home: SuggestionsPage(autoFetchOnInit: false)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final gamesSegment = find.widgetWithText(ButtonSegment<ContentType>, 'Games');
    expect(gamesSegment, findsOneWidget);

    await tester.tap(gamesSegment);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(prefs.get('suggestions_content_type'), ContentType.games.name);
  });

  testWidgets('Explore saves selected tab index when tab changes', (tester) async {
    final prefs = Hive.box<String>('app_preferences');
    await prefs.put('explore_tab_index', '0');

    await tester.pumpWidget(
      const MaterialApp(home: ExplorePage(autoPrimeCarousels: false)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final animeTab = find.descendant(
      of: find.byType(TabBar),
      matching: find.text('Anime'),
    );
    await tester.tap(animeTab);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();

    expect(prefs.get('explore_tab_index'), '1');
  });
}
