import 'item.dart';
import '/Users/samrobertson/Development/projects/Flutter_GeekHobbyApp/app_geek_hobby_app/lib/Enums/AgeRatings/show_age.dart';
import '/Users/samrobertson/Development/projects/Flutter_GeekHobbyApp/app_geek_hobby_app/lib/Enums/genres/video_genre.dart';

class Show extends Item {
  final List<VideoGenre> genres;
  final int seasons;
  final int episodes;
  final int runtime; // Average runtime in minutes
  final ShowAgeRating ageRating; // Age rating

  Show({
    required super.name,
    required super.studio,
    required super.yearReleased,
    required this.genres,
    required this.seasons,
    required this.episodes,
    required this.runtime,
    required this.ageRating,
  });
}