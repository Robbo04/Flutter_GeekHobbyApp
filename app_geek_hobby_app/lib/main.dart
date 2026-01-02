import 'package:app_geek_hobby_app/Classes/Widgets/navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:app_geek_hobby_app/Classes/user.dart';

import 'package:app_geek_hobby_app/Classes/game.dart';
import 'package:app_geek_hobby_app/Classes/anime.dart';
import 'package:app_geek_hobby_app/Enums/Platforms/game_platform.dart';
import 'package:app_geek_hobby_app/Enums/AgeRatings/game_age.dart';
import 'package:app_geek_hobby_app/Enums/Genres/game_genre.dart';
import 'package:app_geek_hobby_app/Classes/item.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:app_geek_hobby_app/Services/rawg_service.dart';
import 'package:app_geek_hobby_app/Services/anilist_service.dart';
import 'package:http/http.dart' as http;

Future<RawgService> initializeRawgService() async {
  // Load environment variables from the .env file (only once at startup)
  await dotenv.load();
  final rawgApiKey = dotenv.env['RAWG_API_KEY'] ?? '';
  final rawgService = RawgService(apiKey: rawgApiKey, httpClient: http.Client());
  return rawgService;
}

Future<AniListService> initializeAniListService() async {
  final aniListService = AniListService();
  return aniListService;
}

Future<void> initializeHive() async {
  await Hive.initFlutter();

  // Register adapters
  Hive.registerAdapter(UserAdapter());

  Hive.registerAdapter(GameAdapter());
  Hive.registerAdapter(AnimeAdapter());
  Hive.registerAdapter(GamePlatformAdapter());
  Hive.registerAdapter(GameAgeAdapter());
  Hive.registerAdapter(GameGenreAdapter());
  Hive.registerAdapter(ItemAdapter());

  // Open necessary boxes
  await Hive.openBox<User>('users');

  try {
    await Hive.openBox<Game>('rawg_games');
  } catch (e, st) {
    print('Error opening rawg_games box: $e\n$st');
    await Hive.deleteBoxFromDisk('rawg_games');
    await Hive.openBox<Game>('rawg_games');
  }

  try {
    await Hive.openBox<int>('rawg_cache_meta');
  } catch (e, st) {
    print('Error opening rawg_cache_meta box: $e\n$st');
    await Hive.deleteBoxFromDisk('rawg_cache_meta');
    await Hive.openBox<int>('rawg_cache_meta');
  }

  await Hive.openBox<Item>('items');
  await Hive.openBox<List>('rawg_search_results');
  // If you actually have a GameDetails type, keep this; otherwise remove
  await Hive.openBox<GameDetails>('rawg_game_details');

  // Anime cache boxes
  try {
    await Hive.openBox<Anime>('anilist_anime');
  } catch (e, st) {
    print('Error opening anilist_anime box: $e\n$st');
    await Hive.deleteBoxFromDisk('anilist_anime');
    await Hive.openBox<Anime>('anilist_anime');
  }

  try {
    await Hive.openBox<int>('anilist_cache_meta');
  } catch (e, st) {
    print('Error opening anilist_cache_meta box: $e\n$st');
    await Hive.deleteBoxFromDisk('anilist_cache_meta');
    await Hive.openBox<int>('anilist_cache_meta');
  }

  await Hive.openBox<List>('anilist_search_results');

  // Collection boxes GAMES
  await Hive.openBox<int>('games_wishlist_collection_id');
  await Hive.openBox<int>('games_owned_collection_id');
  await Hive.openBox<int>('games_backlog_collection_id');
  await Hive.openBox<int>('games_completed_collection_id');

  // Collection boxes ANIME
  await Hive.openBox<int>('anime_wishlist_collection_id');
  await Hive.openBox<int>('anime_watched_collection_id');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final rawgService = await initializeRawgService();
  final aniListService = await initializeAniListService();

  // Register the singleton instances
  RawgService.instance = rawgService;
  AniListService.instance = aniListService;

  await initializeHive();

  runApp(MyApp(rawgService: rawgService));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.rawgService});

  final RawgService rawgService;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: MainTabScaffold(),
    );
  }
}

