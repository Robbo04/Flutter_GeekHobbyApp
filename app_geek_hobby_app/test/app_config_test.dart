import 'package:app_geek_hobby_app/core/config/app_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppConfig', () {
    test('creates config when required variables are present', () {
      final config = AppConfig.fromMap({
        'RAWG_API_KEY': 'abc123',
      });

      expect(config.rawgApiKey, 'abc123');
      expect(config.isReady, isTrue);
    });

    test('throws when RAWG_API_KEY is missing', () {
      expect(
        () => AppConfig.fromMap({}),
        throwsA(isA<AppConfigException>()),
      );
    });
  });
}
