import 'item.dart';
import 'package:hive/hive.dart';

part 'anime.g.dart';

@HiveType(typeId: 5)
class Anime extends Item{
  @HiveField(7)
  final int id;
  @HiveField(8)
  final bool isMovie;
  @HiveField(9)
  final int seasons;
  @HiveField(10)
  final int episodes;
  @HiveField(11)
  final int runtime; // Runtime in minutes
  @HiveField(12)
  final String format; // TV, MOVIE, SPECIAL, OVA, ONA

  Anime({
    required this.id,
    required super.name,
    required super.studio,
    required super.yearReleased,
    required super.imageUrl,
    required this.isMovie,
    required this.seasons,
    required this.episodes,
    required this.runtime,
    this.format = 'TV',
  });
}