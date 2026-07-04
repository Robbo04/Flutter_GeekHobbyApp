import 'item.dart';
import 'package:hive/hive.dart';

part 'anime.g.dart';

@HiveType(typeId: 5)
class Anime extends Item {
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

  @HiveField(13)
  final String? mediumImageUrl;

  @HiveField(14)
  final String? coverColor;

  @HiveField(15)
  final String? description;

  @HiveField(16)
  final int duration;

  /// Raw relation edge payload: {relationType, nodeId, nodeFormat}
  @HiveField(17)
  final List<Map<String, dynamic>> relationEdges;

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
    this.mediumImageUrl,
    this.coverColor,
    this.description,
    int? duration,
    List<Map<String, dynamic>>? relationEdges,
  }) : duration = duration ?? runtime,
       relationEdges = relationEdges ?? const [];

  List<int> get relationNodeIds {
    return relationEdges
        .map((edge) => edge['nodeId'])
        .whereType<int>()
        .toList();
  }
}
