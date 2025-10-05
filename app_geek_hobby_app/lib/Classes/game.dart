import 'package:app_geek_hobby_app/Enums/Platforms/game_platform.dart';
import 'package:app_geek_hobby_app/Enums/AgeRatings/game_age.dart';
import 'package:app_geek_hobby_app/Enums/Genres/game_genre.dart';
import 'item.dart';

class Game extends Item {
  final List<GameGenre> genres;
  final List<GamePlatform> platforms;
  final GameAge ageRating;
  final int metacriticRating; // Metacritic rating out of 100

  Game({
    required super.name,
    required super.studio,
    required super.yearReleased,
    required super.imageUrl,
    required this.genres,
    required this.platforms,
    required this.ageRating,
    required this.metacriticRating,
  });

  factory Game.fromRawg(Map<String, dynamic> data) {
    return Game(
      name: data['name'] ?? 'Unknown',
      studio: data['publishers'] != null && data['publishers'].isNotEmpty
          ? data['publishers'][0]['name']
          : 'Unknown',
      yearReleased: data['released'] != null && data['released'].length >= 4
          ? int.tryParse(data['released'].substring(0, 4)) ?? 0
          : 0,
      genres: (data['genres'] as List<dynamic>?)
              ?.map((g) => GameGenre.values.firstWhere(
                  (e) => e.name.toLowerCase() == (g['slug'] ?? ''),
                  orElse: () => GameGenre.other))
              .toList() ??
          [],
      platforms: (data['platforms'] as List<dynamic>?)
              ?.map((p) => GamePlatform.values.firstWhere(
                  (e) => e.name.toLowerCase() == (p['platform']['slug'] ?? ''),
                  orElse: () => GamePlatform.other))
              .toList() ??
          [],
      ageRating: GameAge.pegi3, // RAWG doesn't always provide age, set default or parse if available
      metacriticRating: data['metacritic'] ?? 0,
      imageUrl: data['background_image'] ?? '',
    );
  }
}