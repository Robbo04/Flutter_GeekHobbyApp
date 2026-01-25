import 'anime.dart';
import 'package:hive/hive.dart';

part 'anime_group.g.dart';

@HiveType(typeId: 7)
class AnimeGroup extends HiveObject {
  @HiveField(0)
  final int groupId; // ID of the primary/parent anime in the group
  
  @HiveField(1)
  final String name; // Group name (e.g., "Demon Slayer")
  
  @HiveField(2)
  final List<int> animeIds; // IDs of all anime in this group
  
  @HiveField(3)
  final String? imageUrl; // Primary image for the group
  
  @HiveField(4)
  final int yearReleased; // Year of first release
  
  @HiveField(5)
  final String studio; // Primary studio
  
  @HiveField(6)
  final DateTime lastUpdated; // When this group was last fetched
  
  @HiveField(7)
  final Map<int, String> relationTypes; // animeId -> relationType (SEQUEL, PREQUEL, etc.)

  AnimeGroup({
    required this.groupId,
    required this.name,
    required this.animeIds,
    this.imageUrl,
    required this.yearReleased,
    required this.studio,
    required this.lastUpdated,
    Map<int, String>? relationTypes,
  }) : relationTypes = relationTypes ?? {};

  /// Get total episode count from all anime in group
  int getTotalEpisodes(Box<Anime> animeBox) {
    int total = 0;
    for (final id in animeIds) {
      final anime = animeBox.get(id);
      if (anime != null) {
        total += anime.episodes;
      }
    }
    return total;
  }

  /// Get all anime objects in this group
  List<Anime> getAnimeList(Box<Anime> animeBox) {
    return animeIds
        .map((id) => animeBox.get(id))
        .whereType<Anime>()
        .toList();
  }

  /// Check if this group needs updating (older than 7 days)
  bool needsUpdate() {
    return DateTime.now().difference(lastUpdated) > const Duration(days: 7);
  }
}
