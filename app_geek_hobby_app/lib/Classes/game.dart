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
    required this.genres,
    required this.platforms,
    required this.ageRating,
    required this.metacriticRating,
  });
}