import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ThemeController {
  ThemeController._();

  static const String _themeModeKey = 'theme_mode';
  static ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.system);
  static Box<String>? _preferencesBox;

  static Future<void> initialize(Box<String> preferencesBox) async {
    _preferencesBox = preferencesBox;
    final stored = preferencesBox.get(_themeModeKey);
    themeMode.value = _parseThemeMode(stored);
  }

  static Future<void> setThemeMode(ThemeMode mode) async {
    themeMode.value = mode;
    await _preferencesBox?.put(_themeModeKey, mode.name);
  }

  static ThemeMode _parseThemeMode(String? raw) {
    switch (raw) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }
}
