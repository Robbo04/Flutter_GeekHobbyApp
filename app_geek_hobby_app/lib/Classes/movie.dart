import 'item.dart';
import '/Users/samrobertson/Development/projects/Flutter_GeekHobbyApp/app_geek_hobby_app/lib/Enums/AgeRatings/movie_age.dart';
import '/Users/samrobertson/Development/projects/Flutter_GeekHobbyApp/app_geek_hobby_app/lib/Enums/genres/video_genre.dart';

class Movie extends Item {
  final List<VideoGenre> genres;
  final String director;
  final String duration; // Duration in minutes
  final MovieAgeRating ageRating; // Age rating
  final double imdbRating; // IMDb or RT rating out of 10

  Movie({
    required super.name,
    required super.studio,
    required super.yearReleased,
    required this.genres,
    required this.director,
    required this.duration,
    required this.ageRating,
    required this.imdbRating,
  });
}