import 'package:app_geek_hobby_app/models/item/anime.dart';

/// Parses AniList GraphQL API responses into Anime objects
class AniListParser {
  /// Parse AniList GraphQL response data to Anime object
  static Anime parseAnime(Map<String, dynamic> data) {
    final format = data['format'] as String?;
    final isMovie = format == 'MOVIE';

    final id = data['id'] as int;

    final title = data['title'] as Map<String, dynamic>?;
    final name =
        title?['english'] ??
        title?['userPreferred'] ??
        title?['romaji'] ??
        'Unknown';
    final description = data['description'] as String?;

    final studiosData = data['studios']?['nodes'] as List<dynamic>?;
    final studio = studiosData?.isNotEmpty == true
        ? studiosData!.first['name']
        : 'Unknown';

    final episodes = data['episodes'] as int?;
    final nextAiringEpisode = data['nextAiringEpisode']?['episode'] as int?;

    // Use episodes if available, otherwise use nextAiringEpisode - 1 for ongoing anime
    final displayEpisodes =
        episodes ?? (nextAiringEpisode != null ? nextAiringEpisode - 1 : 0);

    final duration = data['duration'] as int? ?? 0;
    final yearReleased = data['seasonYear'] as int? ?? 0;

    final rawEdges = data['relations']?['edges'] as List<dynamic>?;
    final relationEdges = <Map<String, dynamic>>[];
    if (rawEdges != null) {
      for (final edge in rawEdges) {
        if (edge is! Map) continue;
        final relationType = edge['relationType'] as String?;
        final node = edge['node'] as Map<String, dynamic>?;
        final nodeId = node?['id'] as int?;
        final nodeFormat = node?['format'] as String?;
        if (relationType == null || nodeId == null) continue;
        relationEdges.add({
          'relationType': relationType,
          'nodeId': nodeId,
          'nodeFormat': nodeFormat,
        });
      }
    }

    final coverImage = data['coverImage'] as Map<String, dynamic>?;
    final imageUrl = coverImage?['large'] as String? ?? '';
    final mediumImageUrl = coverImage?['medium'] as String?;
    final coverColor = coverImage?['color'] as String?;

    // For TV series, calculate seasons (rough estimate: 12-13 episodes per season)
    final seasons = !isMovie && displayEpisodes > 0
        ? (displayEpisodes / 12).ceil()
        : 0;

    return Anime(
      id: id,
      name: name,
      studio: studio,
      yearReleased: yearReleased,
      imageUrl: imageUrl,
      isMovie: isMovie,
      seasons: seasons,
      episodes: displayEpisodes,
      runtime: duration,
      format: format ?? 'TV',
      duration: duration,
      mediumImageUrl: mediumImageUrl,
      coverColor: coverColor,
      description: description,
      relationEdges: relationEdges,
    );
  }
}
