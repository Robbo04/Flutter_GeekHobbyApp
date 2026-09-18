import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';

import 'package:app_geek_hobby_app/core/config/app_config.dart';
import 'package:app_geek_hobby_app/core/errors/app_error.dart';
import 'package:app_geek_hobby_app/enums/age_ratings/game_age.dart';
import 'package:app_geek_hobby_app/enums/genres/game_genre.dart';
import 'package:app_geek_hobby_app/enums/platforms/game_platform.dart';
import 'package:app_geek_hobby_app/models/item/anime.dart';
import 'package:app_geek_hobby_app/models/item/game.dart';
import 'package:app_geek_hobby_app/models/item/item.dart';
import 'package:app_geek_hobby_app/models/user/user.dart';
import 'package:app_geek_hobby_app/services/anilist_service.dart';
import 'package:app_geek_hobby_app/services/rawg_service.dart';

class AppBootstrap {
  static Future<AppBootstrapResult> initialize() async {
    try {
      await dotenv.load();
      final config = AppConfig.fromMap(dotenv.env);

      await Hive.initFlutter();
      _registerAdapters();
      await _openBoxes();

      final rawgService = RawgService(apiKey: config.rawgApiKey, httpClient: http.Client());
      final aniListService = AniListService();

      RawgService.instance = rawgService;
      AniListService.instance = aniListService;

      return AppBootstrapResult(
        rawgService: rawgService,
        aniListService: aniListService,
      );
    } on AppConfigException catch (error) {
      throw AppError(
        message: error.message,
        type: AppErrorType.configuration,
        cause: error,
      );
    } on Exception catch (error) {
      throw AppError(
        message: 'Application initialization failed.',
        type: AppErrorType.unknown,
        cause: error,
      );
    }
  }

  static void _registerAdapters() {
    Hive.registerAdapter(UserAdapter());
    Hive.registerAdapter(GameAdapter());
    Hive.registerAdapter(AnimeAdapter());
    Hive.registerAdapter(GamePlatformAdapter());
    Hive.registerAdapter(GameAgeAdapter());
    Hive.registerAdapter(GameGenreAdapter());
    Hive.registerAdapter(ItemAdapter());
  }

  static Future<void> _openBoxes() async {
    await Hive.openBox<User>('users');

    try {
      await Hive.openBox<Game>('rawg_games');
    } catch (e, st) {
      debugLog('Error opening rawg_games box: $e\n$st');
      await Hive.deleteBoxFromDisk('rawg_games');
      await Hive.openBox<Game>('rawg_games');
    }

    try {
      await Hive.openBox<int>('rawg_cache_meta');
    } catch (e, st) {
      debugLog('Error opening rawg_cache_meta box: $e\n$st');
      await Hive.deleteBoxFromDisk('rawg_cache_meta');
      await Hive.openBox<int>('rawg_cache_meta');
    }

    await Hive.openBox<Item>('items');
    await Hive.openBox<List>('rawg_search_results');
    await Hive.openBox<GameDetails>('rawg_game_details');
    await Hive.openBox<int>('rawg_stats');
    await Hive.openBox<int>('anilist_stats');

    try {
      await Hive.openBox<Anime>('anilist_anime');
    } catch (e, st) {
      debugLog('Error opening anilist_anime box: $e\n$st');
      await Hive.deleteBoxFromDisk('anilist_anime');
      await Hive.openBox<Anime>('anilist_anime');
    }

    try {
      await Hive.openBox<int>('anilist_cache_meta');
    } catch (e, st) {
      debugLog('Error opening anilist_cache_meta box: $e\n$st');
      await Hive.deleteBoxFromDisk('anilist_cache_meta');
      await Hive.openBox<int>('anilist_cache_meta');
    }

    await Hive.openBox<List>('anilist_search_results');
    await Hive.openBox<int>('games_wishlist_collection_id');
    await Hive.openBox<int>('games_owned_collection_id');
    await Hive.openBox<int>('games_backlog_collection_id');
    await Hive.openBox<int>('games_completed_collection_id');
    await Hive.openBox<int>('anime_wishlist_collection_id');
    await Hive.openBox<int>('anime_watched_collection_id');
    await Hive.openBox<String>('app_preferences');
  }

  static void debugLog(String message) {
    // Centralized logging hook for future telemetry/reporting.
    // Avoid noisy console output in production builds.
    // print(message);
  }
}

class AppBootstrapResult {
  const AppBootstrapResult({
    required this.rawgService,
    required this.aniListService,
  });

  final RawgService rawgService;
  final AniListService aniListService;
}
