import 'package:app_geek_hobby_app/Classes/item.dart';

class Anime extends Item{
  final bool isMovie;
  final int seasons;
  final int episodes;
  final int runtime; // Runtime in minutes

  Anime({
    required super.name,
    required super.studio,
    required super.yearReleased,
    required this.isMovie,
    required this.seasons,
    required this.episodes,
    required this.runtime,
  });
}