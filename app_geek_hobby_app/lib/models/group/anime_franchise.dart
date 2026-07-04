import 'package:app_geek_hobby_app/models/item/anime.dart';

/// UI-facing franchise aggregate for anime search results.
class AnimeFranchise {
  final int franchiseId;
  final int primaryAnimeId;
  final String title;
  final String heroTitle;
  final String? description;
  final String? imageUrl;
  final String? coverColor;
  final List<Anime> entries;
  final bool fromExplicitRelations;

  const AnimeFranchise({
    required this.franchiseId,
    required this.primaryAnimeId,
    required this.title,
    required this.heroTitle,
    required this.description,
    required this.imageUrl,
    required this.coverColor,
    required this.entries,
    required this.fromExplicitRelations,
  });

  int get totalEpisodes {
    int total = 0;
    for (final anime in entries) {
      total += anime.episodes;
    }
    return total;
  }
}
