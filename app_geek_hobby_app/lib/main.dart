import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:app_geek_hobby_app/core/errors/app_error.dart';
import 'package:app_geek_hobby_app/core/services/app_init.dart';
import 'package:app_geek_hobby_app/core/themes/app_theme.dart';
import 'package:app_geek_hobby_app/core/themes/theme_controller.dart';
import 'package:app_geek_hobby_app/services/rawg_service.dart';
import 'package:app_geek_hobby_app/widgets/common/navigation_bar.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    final boot = await AppBootstrap.initialize();
    await ThemeController.initialize(Hive.box<String>('app_preferences'));

    runApp(MyApp(rawgService: boot.rawgService));
  } on AppError catch (error) {
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                error.message,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
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
          title: 'Geek Hobby App',
          theme: AppTheme.lightTheme(),
          darkTheme: AppTheme.darkTheme(),
          themeMode: mode,
          home: MainTabScaffold(),
        );
      },
    );
  }
}

