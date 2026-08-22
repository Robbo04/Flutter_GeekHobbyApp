import 'package:hive/hive.dart';

part 'game_age.g.dart';

@HiveType(typeId: 21)
enum GameAge {
  @HiveField(0)
  pegi3,   // Suitable for all ages
  @HiveField(1)
  pegi7,   // Suitable for ages 7+
  @HiveField(2)
  pegi12,  // Suitable for ages 12+
  @HiveField(3)
  pegi16,  // Suitable for ages 16+
  @HiveField(4)
  pegi18,  // Suitable for adults only
}

extension GameAgeParsing on GameAge {
  /// Parses RAWG/ESRB/PEGI-like rating values into our PEGI-style enum.
  static GameAge fromRawgValue(dynamic value) {
    if (value == null) return GameAge.pegi3;

    final raw = value is Map<String, dynamic>
        ? (value['slug'] ?? value['name'] ?? '')
        : value;
    final normalized = raw.toString().toLowerCase().trim();
    final compact = normalized.replaceAll(RegExp(r'[^a-z0-9+]'), '');

    if (normalized.isEmpty) return GameAge.pegi3;

    if (normalized.contains('18') ||
        normalized.contains('adult') ||
        normalized.contains('mature') ||
        compact == 'ao' ||
        compact == 'adultsonly') {
      return GameAge.pegi18;
    }
    if (normalized.contains('17') ||
        normalized.contains('16') ||
        compact == 'm' ||
        compact == 'mature17+') {
      return GameAge.pegi16;
    }
    if (normalized.contains('13') ||
        normalized.contains('12') ||
        normalized.contains('teen') ||
        compact == 't') {
      return GameAge.pegi12;
    }
    if (normalized.contains('10') ||
        normalized.contains('7') ||
        normalized.contains('everyone-10') ||
        normalized.contains('everyone 10') ||
        normalized.contains('everyone10') ||
        normalized.contains('e10')) {
      return GameAge.pegi7;
    }
    if (normalized.contains('everyone') ||
        compact == 'e' ||
        compact == 'ec' ||
        normalized.contains('3')) {
      return GameAge.pegi3;
    }

    return GameAge.pegi3;
  }
}