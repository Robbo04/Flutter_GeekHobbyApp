import 'package:app_geek_hobby_app/Classes/anime.dart';

/// Parses AniList GraphQL API responses into Anime objects
class AniListParser {
  /// Parse AniList GraphQL response data to Anime object
  static Anime parseAnime(Map<String, dynamic> data) {
    final format = data['format'] as String?;
    final isMovie = format == 'MOVIE';

    final id = data['id'] as int;

    final title = data['title'] as Map<String, dynamic>?;
    final name = title?['english'] ?? title?['romaji'] ?? 'Unknown';

    final studiosData = data['studios']?['nodes'] as List<dynamic>?;
    final studio = studiosData?.isNotEmpty == true
        ? studiosData!.first['name']
        : 'Unknown';

    final episodes = data['episodes'] as int? ?? 0;
    final duration = data['duration'] as int? ?? 0;
    final yearReleased = data['seasonYear'] as int? ?? 0;

    final coverImage = data['coverImage'] as Map<String, dynamic>?;
    final imageUrl = coverImage?['large'] as String? ?? '';

    // For TV series, calculate seasons (rough estimate: 12-13 episodes per season)
    final seasons = !isMovie && episodes > 0 ? (episodes / 12).ceil() : 0;

    return Anime(
      id: id,
      name: name,
      studio: studio,
      yearReleased: yearReleased,
      imageUrl: imageUrl,
      isMovie: isMovie,
      seasons: seasons,
      episodes: episodes,
      runtime: duration,
    );
  }
}
