import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:app_geek_hobby_app/Classes/game.dart';
import 'package:app_geek_hobby_app/Enums/Platforms/game_platform.dart';
import 'rawg_cache.dart';
import 'rawg_rate_limiter.dart';

/// Handles all RAWG API HTTP requests
class RawgAPI {
  static const String _host = 'api.rawg.io';
  static const String _basePath = '/api';

  final String apiKey;
  final http.Client httpClient;
  final RawgRateLimiter rateLimiter;
  final RawgCache cache;

  RawgAPI({
    required this.apiKey,
    required this.httpClient,
    required this.rateLimiter,
    required this.cache,
  });

  // ==================== HELPER METHODS ====================

  /// Filter out mobile-only games from a list
  List<Game> _filterMobileOnlyGames(List<Game> games) {
    return games.where((g) {
      // Keep games that have at least one non-mobile platform
      return g.platforms.any((p) => p != GamePlatform.mobile);
    }).toList();
  }

  // ==================== CORE API METHODS ====================

  /// Fetch games with specific parameters
  Future<List<Game>> fetchGames({
    String search = '',
    String? genre,
    int page = 1,
    int pageSize = 20,
    String ordering = '-added',
    bool searchPrecise = false,
    String excludeStores = '', // Comma-separated store IDs to exclude (e.g., '9' for itch.io)
    String excludePlatforms = '', // Comma-separated platform IDs to exclude (e.g., '4,21' for iOS/Android)
    int minRatingsCount = 0, // Minimum rating count for client-side filtering
  }) async {
    final Map<String, String> params = {
      'key': apiKey,
      'page': page.toString(),
      'page_size': pageSize.toString(),
    };
    if (search.isNotEmpty) {
      params['search'] = search;
      // For searches, prioritize relevance over date added
      if (ordering == '-added') {
        params['ordering'] = '-relevance';
      } else {
        params['ordering'] = ordering;
      }
      // Enable precise search for better exact matches
      if (searchPrecise) {
        params['search_precise'] = 'true';
      }
      // Exclude specific stores (e.g., itch.io)
      if (excludeStores.isNotEmpty) {
        params['exclude_stores'] = excludeStores;
      }
      // Exclude specific platforms (e.g., mobile)
      if (excludePlatforms.isNotEmpty) {
        params['exclude_platforms'] = excludePlatforms;
      }
    } else {
      // No search term, use provided ordering
      if (ordering.isNotEmpty) params['ordering'] = ordering;
    }
    if (genre != null && genre.isNotEmpty) {
      params['genres'] = genre;
    }

    rateLimiter.checkRateLimit();
    final uri = Uri.https(_host, '$_basePath/games', params);
    final response = await httpClient.get(uri);
    rateLimiter.trackRequest();

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List<dynamic>;
      var games = results.map((e) => Game.fromRawg(e)).toList();
      
      // Filter out mobile-only games
      if (excludePlatforms.isNotEmpty) {
        games = _filterMobileOnlyGames(games);
      }
      
      // Apply client-side filtering if minRatingsCount is set
      // Only check rating count if game doesn't have a Metacritic score
      if (minRatingsCount > 0) {
        games = games.where((g) {
          // Keep if has Metacritic score OR has enough ratings
          return g.metacriticRating > 0 || g.ratingCount >= minRatingsCount;
        }).toList();
      }
      
      return games;
    } else {
      debugPrint('Failed to load games (status: ${response.statusCode})');
      throw Exception('Failed to load games (status: ${response.statusCode})');
    }
  }

  /// Fetch detailed game information by ID
  Future<Game> fetchGameDetails(int id) async {
    rateLimiter.checkRateLimit();
    final uri = Uri.https(_host, '$_basePath/games/$id', {'key': apiKey});
    final response = await httpClient.get(uri);
    rateLimiter.trackRequest();

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Game.fromRawg(data);
    } else {
      debugPrint('Failed to load game details (status: ${response.statusCode})');
      throw Exception(
        'Failed to load game details (status: ${response.statusCode})',
      );
    }
  }

  /// Fetch trending games (most-added in date range)
  Future<List<Game>> fetchTrendingGames({
    required String dateFilter,
    int pageSize = 20,
    String? genre,
    String ordering = '-added',
    int minMetacritic = 60,
    int minRatingsCount = 50,
  }) async {
    final Map<String, String> params = {
      'key': apiKey,
      'page': '1',
      'page_size': pageSize.toString(),
      'dates': dateFilter,
      'ordering': ordering,
    };
    if (genre != null && genre.isNotEmpty) params['genres'] = genre;

    rateLimiter.checkRateLimit();
    final uri = Uri.https(_host, '$_basePath/games', params);
    final response = await httpClient.get(uri);
    rateLimiter.trackRequest();

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to fetch trending (status: ${response.statusCode})',
      );
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    var results = (data['results'] as List<dynamic>)
        .map((e) => Game.fromRawg(e))
        .where((g) {
          // Filter out low-quality / low-evidence items
          if (g.metacriticRating != -1 && g.metacriticRating < minMetacritic) {
            return false;
          }
          if (g.ratingCount < minRatingsCount) return false;
          return true;
        }).toList();

    // Filter out mobile-only games
    results = _filterMobileOnlyGames(results);

    return results;
  }

  /// Fetch most played/popular games (ordered by rating count)
  Future<List<Game>> fetchMostPlayedGames({
    int page = 1,
    int pageSize = 20,
    String? genre,
  }) async {
    final Map<String, String> params = {
      'key': apiKey,
      'page': page.toString(),
      'page_size': pageSize.toString(),
      'ordering': '-rating,-ratings_count',
    };
    if (genre != null && genre.isNotEmpty) params['genres'] = genre;

    rateLimiter.checkRateLimit();
    final uri = Uri.https(_host, '$_basePath/games', params);
    final response = await httpClient.get(uri);
    rateLimiter.trackRequest();

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List<dynamic>;
      var games = results.map((e) => Game.fromRawg(e)).toList();
      
      // Filter out mobile-only games
      games = _filterMobileOnlyGames(games);
      
      return games;
    } else {
      throw Exception(
        'Failed to load most played games (status: ${response.statusCode})',
      );
    }
  }

  /// Fetch upcoming/coming soon games
  Future<List<Game>> fetchComingSoonGames({
    required String dateFilter,
    int page = 1,
    int pageSize = 20,
  }) async {
    final Map<String, String> params = {
      'key': apiKey,
      'page': page.toString(),
      'page_size': pageSize.toString(),
      'dates': dateFilter,
      'ordering': 'released',
    };

    rateLimiter.checkRateLimit();
    final uri = Uri.https(_host, '$_basePath/games', params);
    final response = await httpClient.get(uri);
    rateLimiter.trackRequest();

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List<dynamic>;
      debugPrint('Fetched ${results.length} coming soon games');
      var games = results.map((e) => Game.fromRawg(e)).toList();
      
      // Filter out mobile-only games
      games = _filterMobileOnlyGames(games);
      
      return games;
    } else {
      debugPrint(
          'Failed to load coming soon games (status: ${response.statusCode})');
      throw Exception(
        'Failed to load coming soon games (status: ${response.statusCode})',
      );
    }
  }

  /// Fetch games by genre with filtering
  Future<List<Game>> fetchGamesByGenre({
    required String genre,
    int page = 1,
    int pageSize = 20,
    int minRatingsCount = 100,
  }) async {
    final Map<String, String> params = {
      'key': apiKey,
      'page': page.toString(),
      'page_size': pageSize.toString(),
      'genres': genre,
      'ordering': '-rating,-ratings_count',
    };

    rateLimiter.checkRateLimit();
    final uri = Uri.https(_host, '$_basePath/games', params);
    final response = await httpClient.get(uri);
    rateLimiter.trackRequest();

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List<dynamic>;

      // Filter for well-known games
      var gamesList = results
          .map((e) => Game.fromRawg(e))
          .where((g) => g.ratingCount >= minRatingsCount)
          .toList();

      // Filter out mobile-only games
      gamesList = _filterMobileOnlyGames(gamesList);

      return gamesList;
    } else {
      throw Exception(
        'Failed to load games by genre (status: ${response.statusCode})',
      );
    }
  }

  /// Fetch games by tag with filtering
  Future<List<Game>> fetchGamesByTag({
    required String tag,
    int page = 1,
    int pageSize = 20,
    int minRatingsCount = 100,
  }) async {
    final Map<String, String> params = {
      'key': apiKey,
      'page': page.toString(),
      'page_size': pageSize.toString(),
      'tags': tag,
      'ordering': '-rating,-ratings_count',
    };

    rateLimiter.checkRateLimit();
    final uri = Uri.https(_host, '$_basePath/games', params);
    debugPrint('Fetching games by tag: $uri');
    final response = await httpClient.get(uri);
    rateLimiter.trackRequest();

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List<dynamic>;
      debugPrint('Found ${results.length} games for tag "$tag"');

      // Filter for well-known games
      var gamesList = results
          .map((e) => Game.fromRawg(e))
          .where((g) => g.ratingCount >= minRatingsCount)
          .toList();

      // Filter out mobile-only games
      gamesList = _filterMobileOnlyGames(gamesList);

      debugPrint(
          'After filtering: ${gamesList.length} games with $minRatingsCount+ ratings');

      return gamesList;
    } else {
      throw Exception(
        'Failed to load games by tag (status: ${response.statusCode})',
      );
    }
  }

  // ==================== BATCH OPERATIONS ====================

  /// Safely fetch a single game details, returning null on error
  Future<Game?> safeFetchGameDetails(int id) async {
    try {
      return await fetchGameDetails(id);
    } catch (_) {
      return null;
    }
  }

  /// Assemble games from ID list, fetching missing ones
  Future<List<Game>> assembleFromIds(
    List<int> ids, {
    int missingFetchBatch = 5,
    bool allowPartialReturn = false,
  }) async {
    final List<Game> assembled = [];
    final List<int> missing = [];

    // 1) Take cached ones first
    for (final id in ids) {
      final cached = cache.getCachedGame(id);
      if (cached != null) {
        assembled.add(cached);
      } else {
        missing.add(id);
      }
    }

    // 2) Fetch missing ones in small batches
    if (missing.isNotEmpty) {
      for (var i = 0; i < missing.length; i += missingFetchBatch) {
        final batch = missing.sublist(
          i,
          (i + missingFetchBatch).clamp(0, missing.length),
        );
        final futures = batch.map((id) => safeFetchGameDetails(id));
        final fetched = await Future.wait(futures);
        for (final g in fetched.whereType<Game>()) {
          assembled.add(g);
          await cache.cacheGame(g);
        }
      }
    }

    // 3) Restore original ordering
    final Map<int, Game> byId = {for (final g in assembled) g.id: g};
    final ordered = <Game>[];
    for (final id in ids) {
      final g = byId[id];
      if (g != null) ordered.add(g);
    }

    // 4) Check if all were fetched
    if (!allowPartialReturn && ordered.length != ids.length) return [];

    return ordered;
  }

  /// Refresh all cached games with latest data
  Future<void> refreshAllCachedGames({
    int batchSize = 5,
    Duration delay = const Duration(milliseconds: 500),
  }) async {
    final ids = cache.gamesBox.keys.cast<int>().toList();
    for (var i = 0; i < ids.length; i += batchSize) {
      final batch = ids.sublist(i, (i + batchSize).clamp(0, ids.length));
      final futures = batch.map((id) async {
        try {
          final uri = Uri.https(_host, '$_basePath/games/$id', {'key': apiKey});
          final response = await httpClient.get(uri);
          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            final game = Game.fromRawg(data);
            await cache.cacheGame(game);
          }
        } catch (_) {
          // Ignore per-id failures
        }
      }).toList();

      await Future.wait(futures);
      await Future.delayed(delay);
    }
  }
}
