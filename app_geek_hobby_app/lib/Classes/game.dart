import 'package:app_geek_hobby_app/Enums/Platforms/game_platform.dart';
import 'package:app_geek_hobby_app/Enums/AgeRatings/game_age.dart';
import 'package:app_geek_hobby_app/Enums/Genres/game_genre.dart';
import 'item.dart';
import 'package:hive/hive.dart';

part 'game.g.dart';

@HiveType(typeId: 2)
class Game extends Item {
  @HiveField(7)
  final int id;
  @HiveField(8)
  final List<GameGenre> genres;
  @HiveField(9)
  final List<GamePlatform> platforms;
  @HiveField(10)
  final GameAge ageRating;
  @HiveField(11)
  final int metacriticRating; // Metacritic rating out of 100\
  @HiveField(12)
  bool completed = false; // Whether the game has been completed
  @HiveField(13)
  String websiteUrl = ''; // Official website URL
  @HiveField(14)
  bool isDetailed = false; // Whether full details have been fetched

  Game({
    required this.id,
    required super.name,
    required super.studio,
    required super.yearReleased,
    required super.imageUrl,
    required this.genres,
    required this.platforms,
    required this.ageRating,
    required this.metacriticRating,
    required this.websiteUrl,
  });

  factory Game.fromRawg(Map<String, dynamic> data) {
    return Game(
      id: data['id'],
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
        ?.map((p) => GamePlatformExtension.fromRawg(p['platform']['slug']))
        .toSet() // Remove duplicates
        .toList() ??
          [],
      ageRating: GameAge.pegi3, // RAWG doesn't always provide age, set default or parse if available
      metacriticRating: data['metacritic'] ?? 0,
      imageUrl: data['background_image'] ?? '',
      websiteUrl: data['website'] ?? '',
    );
  }
}

class GameDetails extends Game {
  final List<String> developers;
  final List<String> publishers;
  final String websiteUrl;
  final int metacritic;

  GameDetails({
    required int id,
    required String name,
    required String studio,
    required int yearReleased,
    required String imageUrl,
    required List<GameGenre> genres,
    required List<GamePlatform> platforms,
    required GameAge ageRating,
    required int metacriticRating,
    required this.developers,
    required this.publishers,
    required this.websiteUrl,
    required this.metacritic,
  }) : super(
          id: id,
          name: name,
          studio: studio,
          yearReleased: yearReleased,
          imageUrl: imageUrl,
          genres: genres,
          platforms: platforms,
          ageRating: ageRating,
          metacriticRating: metacriticRating,
          websiteUrl: websiteUrl,
        );

}