import 'package:app_geek_hobby_app/widgets/common/navigation_bar.dart';
import 'package:app_geek_hobby_app/core/themes/app_theme.dart';
import 'package:app_geek_hobby_app/core/themes/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:app_geek_hobby_app/local_database/local_hive_service.dart';

import 'package:app_geek_hobby_app/models/item/game.dart';
import 'package:app_geek_hobby_app/models/item/anime.dart';
import 'package:app_geek_hobby_app/models/item/item.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:app_geek_hobby_app/services/rawg_service.dart';
import 'package:app_geek_hobby_app/services/anilist_service.dart';
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

  await LocalHiveService.initialize();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive FIRST so boxes are available
  await initializeHive();

  final rawgService = await initializeRawgService();
  final aniListService = await initializeAniListService();

  // Register the singleton instances
  RawgService.instance = rawgService;
  AniListService.instance = aniListService;

  await ThemeController.initialize(Hive.box<String>('app_preferences'));

  runApp(MyApp(rawgService: rawgService));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.rawgService});

  final RawgService rawgService;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeMode,
      builder: (context, mode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          theme: AppTheme.lightTheme(),
          darkTheme: AppTheme.darkTheme(),
          themeMode: mode,
          home: MainTabScaffold(),
        );
      },
    );
  }
}

