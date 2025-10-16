import 'package:app_geek_hobby_app/Classes/Widgets/navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:app_geek_hobby_app/Classes/user.dart';

import 'package:app_geek_hobby_app/Classes/game.dart';
import 'package:app_geek_hobby_app/Enums/Platforms/game_platform.dart';
import 'package:app_geek_hobby_app/Enums/AgeRatings/game_age.dart';
import 'package:app_geek_hobby_app/Enums/Genres/game_genre.dart';

import 'package:app_geek_hobby_app/Classes/item.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> initializeApis() async {
  // Load environment variables from the .env file
  await dotenv.load();
  // init other APIs if needed
}

Future<void> initializeHive() async {
  await Hive.initFlutter();

  // Register adapters
  Hive.registerAdapter(UserAdapter());

  Hive.registerAdapter(GameAdapter());
  Hive.registerAdapter(GamePlatformAdapter());
  Hive.registerAdapter(GameAgeAdapter());
  Hive.registerAdapter(GameGenreAdapter());
  Hive.registerAdapter(ItemAdapter());

  // Open necessary boxes
  await Hive.openBox<User>('users');
  await Hive.openBox<Game>('rawg_games');
  await Hive.openBox<Item>('items');
  await Hive.openBox<List>('rawg_search_results');
  await Hive.openBox<GameDetails>('rawg_game_details');

  //Collection boxes
  await Hive.openBox<int>('games_wishlist_collection_id');
  await Hive.openBox<int>('games_owned_collection_id');
  await Hive.openBox<int>('games_backlog_collection_id');
  await Hive.openBox<int>('games_completed_collection_id');

}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeApis();

  await initializeHive();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: MainTabScaffold(),

      //DEFAULT PAGE to start.
      //home: AuthenticationGate(),
    );
  }
}

