import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'package:app_geek_hobby_app/Classes/anime.dart';

import 'anilist_queries.dart';
import 'anilist_parser.dart';
import 'anilist_rate_limiter.dart';

/// Handles GraphQL API calls to AniList
class AniListAPI {
  final GraphQLClient _client;
  final AniListRateLimiter _rateLimiter;

  AniListAPI(this._client, this._rateLimiter);

  /// Execute a GraphQL query with rate limiting
  Future<QueryResult> _executeQuery(String query, Map<String, dynamic> variables) async {
    _rateLimiter.checkRateLimit();
    _rateLimiter.trackRequest();
    
    return await _client.query(
      QueryOptions(
        document: gql(query),
        variables: variables,
      ),
    );
  }

  /// Search anime via API
  Future<List<Anime>> searchAnime({
    required String search,
    required int page,
    required int perPage,
  }) async {
    try {
      final result = await _executeQuery(
        AniListQueries.search,
        {
          'search': search,
          'page': page,
          'perPage': perPage,
          'type': 'ANIME',
        },
      );

      if (result.hasException) {
        debugPrint('AniList query error: ${result.exception}');
        return [];
      }

      final mediaList = result.data?['Page']?['media'] as List<dynamic>?;
      if (mediaList == null) return [];

      return mediaList.map((data) => AniListParser.parseAnime(data)).toList();
    } catch (e) {
      debugPrint('Error searching anime: $e');
      return [];
    }
  }

  /// Fetch trending anime via API
  Future<List<Anime>> fetchTrending({
    required int page,
    required int perPage,
  }) async {
    try {
      final result = await _executeQuery(
        AniListQueries.trending,
        {'page': page, 'perPage': perPage},
      );

      if (result.hasException) {
        debugPrint('AniList trending query error: ${result.exception}');
        return [];
      }

      final mediaList = result.data?['Page']?['media'] as List<dynamic>?;
      if (mediaList == null) return [];

      return mediaList.map((data) => AniListParser.parseAnime(data)).toList();
    } catch (e) {
      debugPrint('Error fetching trending anime: $e');
      return [];
    }
  }

  /// Fetch most popular anime via API
  Future<List<Anime>> fetchMostPopular({
    required int page,
    required int perPage,
  }) async {
    try {
      final result = await _executeQuery(
        AniListQueries.popular,
        {'page': page, 'perPage': perPage},
      );

      if (result.hasException) {
        debugPrint('AniList popular query error: ${result.exception}');
        return [];
      }

      final mediaList = result.data?['Page']?['media'] as List<dynamic>?;
      if (mediaList == null) return [];

      return mediaList.map((data) => AniListParser.parseAnime(data)).toList();
    } catch (e) {
      debugPrint('Error fetching popular anime: $e');
      return [];
    }
  }

  /// Fetch coming soon anime via API
  Future<List<Anime>> fetchComingSoon({
    required int page,
    required int perPage,
  }) async {
    try {
      final result = await _executeQuery(
        AniListQueries.comingSoon,
        {'page': page, 'perPage': perPage},
      );

      if (result.hasException) {
        debugPrint('AniList coming soon query error: ${result.exception}');
        return [];
      }

      final mediaList = result.data?['Page']?['media'] as List<dynamic>?;
      if (mediaList == null) return [];

      return mediaList.map((data) => AniListParser.parseAnime(data)).toList();
    } catch (e) {
      debugPrint('Error fetching coming soon anime: $e');
      return [];
    }
  }

  /// Fetch anime by genre via API
  Future<List<Anime>> fetchByGenre({
    required String genre,
    required int page,
    required int perPage,
  }) async {
    try {
      final result = await _executeQuery(
        AniListQueries.byGenre,
        {
          'genre': genre,
          'page': page,
          'perPage': perPage,
        },
      );

      if (result.hasException) {
        debugPrint('AniList genre query error: ${result.exception}');
        return [];
      }

      final mediaList = result.data?['Page']?['media'] as List<dynamic>?;
      if (mediaList == null) return [];

      return mediaList.map((data) => AniListParser.parseAnime(data)).toList();
    } catch (e) {
      debugPrint('Error fetching anime by genre: $e');
      return [];
    }
  }

  /// Fetch anime relations via API
  Future<QueryResult?> fetchAnimeRelations(int animeId) async {
    try {
      final result = await _executeQuery(
        AniListQueries.relations,
        {'id': animeId},
      );

      if (result.hasException) {
        final exception = result.exception;
        // Check if it's a 404 (anime not found) - this is common and not an error
        if (exception?.linkException is ServerException) {
          final serverException = exception!.linkException as ServerException;
          final response = serverException.parsedResponse;
          if (response?.errors?.any((e) => e.message == 'Not Found.') == true) {
            return null; // Anime doesn't exist
          }
        }
        debugPrint('AniList relations query error for anime $animeId: ${exception?.linkException?.toString() ?? "Unknown error"}');
        return null;
      }

      return result;
    } catch (e) {
      debugPrint('Error fetching anime relations: $e');
      return null;
    }
  }
}
