class AppConfigException implements Exception {
  const AppConfigException(this.message);

  final String message;

  @override
  String toString() => 'AppConfigException: $message';
}

class AppConfig {
  const AppConfig({required this.rawgApiKey});

  final String rawgApiKey;

  bool get isReady => rawgApiKey.trim().isNotEmpty;

  static AppConfig fromMap(Map<String, String> values) {
    final rawgApiKey = values['RAWG_API_KEY'] ?? '';

    if (rawgApiKey.trim().isEmpty) {
      throw const AppConfigException(
        'RAWG_API_KEY is missing or empty. Add it to your .env file.',
      );
    }

    return AppConfig(rawgApiKey: rawgApiKey.trim());
  }
}
