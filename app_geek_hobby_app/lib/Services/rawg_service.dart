import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:app_geek_hobby_app/Classes/game.dart';

import 'rawg/rawg_api.dart';
import 'rawg/rawg_cache.dart';
import 'rawg/rawg_rate_limiter.dart';

export 'rawg/rawg_exceptions.dart';

/// Main service for interacting with RAWG Video Games Database API
///
/// Handles game searches, trending games, and maintains local cache.
/// Use `RawgService.instance` to access the singleton.
class RawgService {
  static late RawgService instance;

  final String apiKey;
  final http.Client httpClient;

  late final RawgCache _cache;
  late final RawgRateLimiter _rateLimiter;
  late final RawgAPI _api;

  RawgService({required this.apiKey, http.Client? httpClient})
      : httpClient = httpClient ?? http.Client() {
    _cache = RawgCache();
    _rateLimiter = RawgRateLimiter(_cache.statsBox);
    _api = RawgAPI(
      apiKey: apiKey,
      httpClient: this.httpClient,
      rateLimiter: _rateLimiter,
      cache: _cache,
    );
  }

  // ==================== PUBLIC TRACKING GETTERS ====================

  int get sessionRequests => _rateLimiter.sessionRequests;
  int get monthlyRequestsMade => _rateLimiter.monthlyRequestsMade;
  int get monthlyRequestsRemaining => _rateLimiter.monthlyRequestsRemaining;
  int get monthlyLimit => RawgRateLimiter.monthlyLimit;
  DateTime? get lastRequestTime => _rateLimiter.lastRequestTime;
  double get usagePercentage => _rateLimiter.usagePercentage;
  int get totalCachedGames => _cache.totalCachedGames;

  // ==================== API METHODS ====================

  /// Fetch games with persistent cache
  ///
  /// Accepts optional genre (RAWG slug), page, pageSize, ordering
  Future<List<Game>> fetchGames({
    String search = '',
    String? genre,
    int page = 1,
    int pageSize = 20,
    String ordering = '-added',
    int daysToCache = 30,
    Duration cacheTTLHours = const Duration(days: 3),
    bool searchPrecise = false,
  }) async {
    final cacheKey =
        'rawg|search=$search|genre=${genre ?? ''}|page=$page|pageSize=$pageSize|ordering=$ordering|precise=$searchPrecise';

    // Check cache first
    final idList = _cache.getCachedSearchResults(cacheKey);
    if (idList != null && idList.isNotEmpty) {
      final games = _cache.getCachedGameList(idList);
      if (games.length == idList.length) {
        debugPrint('Loaded games from cache for key: $cacheKey');
        return games;
      }
    }

    // Fetch from API
    final gamesList = await _api.fetchGames(
      search: search,
      genre: genre,
      page: page,
      pageSize: pageSize,
      ordering: ordering,
      searchPrecise: searchPrecise,
    );
    if (gamesList.isEmpty) return [];

    // Cache results
    await _cache.cacheGameList(gamesList);
    await _cache.cacheSearchResults(cacheKey, gamesList.map((g) => g.id).toList());

    return gamesList;
  }

  /// Fetch game details with persistent cache
  Future<Game> fetchGameDetails(int id) async {
    final cached = _cache.getCachedGame(id);
    if (cached != null && cached.isDetailed) return cached;

    // Fetch from API
    final game = await _api.fetchGameDetails(id);
    await _cache.cacheGame(game);
    return game;
  }

  /// Fetch "trending" games by looking at items most-added in the last [days]
  ///
  /// This is an approximation: RAWG doesn't have a single /trending endpoint
  Future<List<Game>> fetchTrending({
    int days = 30,
    String? genre,
    int page = 1,
    int pageSize = 20,
    String ordering = '-added',
    Duration ttl = const Duration(hours: 24),
    bool softTtl = true,
    int minMetacritic = 60,
    int minRatingsCount = 50,
  }) async {
    final to = DateTime.now();
    final from = to.subtract(Duration(days: days));
    final dateStr =
        '${from.toIso8601String().split('T')[0]},${to.toIso8601String().split('T')[0]}';
    final cacheKey =
        'trending|days=$days|genre=${genre ?? ''}|page=$page|size=$pageSize|ordering=$ordering';

    // Check cache
    final idList = _cache.getCachedSearchResults(cacheKey);

    // If cached and fresh, return cached
    if (idList != null && idList.isNotEmpty && _cache.isFresh(cacheKey, ttl)) {
      final assembled = await _api.assembleFromIds(
        idList,
        missingFetchBatch: 5,
        allowPartialReturn: false,
      );
      if (assembled.isNotEmpty && assembled.length == idList.length) {
        return assembled;
      }
    }

    // If soft TTL and cached exists, return cached while refreshing in background
    if (softTtl && idList != null && idList.isNotEmpty) {
      final cachedGames = _cache.getCachedGameList(idList);
      // Refresh in background (fire-and-forget)
      _api.assembleFromIds(idList, missingFetchBatch: 5, allowPartialReturn: true);
      if (cachedGames.isNotEmpty) return cachedGames;
    }

    // Fetch from API
    final results = await _api.fetchTrendingGames(
      dateFilter: dateStr,
      pageSize: pageSize,
      genre: genre,
      ordering: ordering,
      minMetacritic: minMetacritic,
      minRatingsCount: minRatingsCount,
    );

    // Cache results
    await _cache.cacheGameList(results);
    await _cache.cacheSearchResults(cacheKey, results.map((g) => g.id).toList());

    return results;
  }

  /// Fetch most played/popular games (all-time) by sorting by rating count
  Future<List<Game>> fetchMostPlayed({
    int page = 1,
    int pageSize = 20,
    String? genre,
    Duration cacheTTL = const Duration(days: 7),
  }) async {
    final cacheKey =
        'mostPlayed|genre=${genre ?? ''}|page=$page|pageSize=$pageSize';

    // Check cache first
    final idList = _cache.getCachedSearchResults(cacheKey);
    if (idList != null && idList.isNotEmpty && _cache.isFresh(cacheKey, cacheTTL)) {
      final games = _cache.getCachedGameList(idList);
      if (games.length == idList.length) {
        debugPrint('Loaded most played games from cache');
        return games;
      }
    }

    // Fetch from API
    final gamesList = await _api.fetchMostPlayedGames(
      page: page,
      pageSize: pageSize,
      genre: genre,
    );

    // Cache results
    await _cache.cacheGameList(gamesList);
    await _cache.cacheSearchResults(cacheKey, gamesList.map((g) => g.id).toList());

    return gamesList;
  }

  /// Fetch upcoming/coming soon games
  Future<List<Game>> fetchComingSoon({
    int page = 1,
    int pageSize = 20,
    Duration cacheTTL = const Duration(hours: 12),
  }) async {
    final cacheKey = 'comingSoon|page=$page|pageSize=$pageSize';

    // Check cache first
    final idList = _cache.getCachedSearchResults(cacheKey);
    if (idList != null && idList.isNotEmpty && _cache.isFresh(cacheKey, cacheTTL)) {
      final games = _cache.getCachedGameList(idList);
      if (games.length == idList.length) {
        debugPrint('Loaded coming soon games from cache');
        return games;
      }
    }

    // Build date filter
    final today = DateTime.now();
    final futureDate = today.add(const Duration(days: 365));
    final dateFilter =
        '${today.toIso8601String().split('T')[0]},${futureDate.toIso8601String().split('T')[0]}';

    // Fetch from API
    final gamesList = await _api.fetchComingSoonGames(
      dateFilter: dateFilter,
      page: page,
      pageSize: pageSize,
    );

    // Cache results
    await _cache.cacheGameList(gamesList);
    await _cache.cacheSearchResults(cacheKey, gamesList.map((g) => g.id).toList());

    return gamesList;
  }

  /// Fetch games by genre (convenience wrapper around fetchGames)
  Future<List<Game>> fetchByGenre({
    required String genre,
    int page = 1,
    int pageSize = 20,
    Duration cacheTTL = const Duration(days: 7),
    int minRatingsCount = 100,
  }) async {
    final cacheKey =
        'genre=$genre|page=$page|pageSize=$pageSize|minRatings=$minRatingsCount';

    // Check cache first
    final idList = _cache.getCachedSearchResults(cacheKey);
    if (idList != null && idList.isNotEmpty && _cache.isFresh(cacheKey, cacheTTL)) {
      final games = _cache.getCachedGameList(idList);
      if (games.length == idList.length) {
        debugPrint('Loaded games by genre from cache');
        return games;
      }
    }

    // Fetch from API
    final gamesList = await _api.fetchGamesByGenre(
      genre: genre,
      page: page,
      pageSize: pageSize,
      minRatingsCount: minRatingsCount,
    );

    // Cache results
    await _cache.cacheGameList(gamesList);
    await _cache.cacheSearchResults(cacheKey, gamesList.map((g) => g.id).toList());

    return gamesList;
  }

  /// Fetch games by tag
  Future<List<Game>> fetchByTag({
    required String tag,
    int page = 1,
    int pageSize = 20,
    Duration cacheTTL = const Duration(days: 7),
    int minRatingsCount = 100,
  }) async {
    final cacheKey =
        'tag=$tag|page=$page|pageSize=$pageSize|minRatings=$minRatingsCount';

    // Check cache first
    final idList = _cache.getCachedSearchResults(cacheKey);
    if (idList != null && idList.isNotEmpty && _cache.isFresh(cacheKey, cacheTTL)) {
      final games = _cache.getCachedGameList(idList);
      if (games.length == idList.length) {
        debugPrint('Loaded games by tag from cache');
        return games;
      }
    }

    // Fetch from API
    final gamesList = await _api.fetchGamesByTag(
      tag: tag,
      page: page,
      pageSize: pageSize,
      minRatingsCount: minRatingsCount,
    );

    // Cache results
    await _cache.cacheGameList(gamesList);
    await _cache.cacheSearchResults(cacheKey, gamesList.map((g) => g.id).toList());

    return gamesList;
  }

  // ==================== MAINTENANCE METHODS ====================

  /// Refresh all cached games with latest data from API
  Future<void> refreshAllCachedGames({
    int batchSize = 5,
    Duration delay = const Duration(milliseconds: 500),
  }) async {
    await _api.refreshAllCachedGames(batchSize: batchSize, delay: delay);
  }

  /// Clear all cached data
  Future<void> clearCache() async {
    await _cache.clearCache();
  }

  /// Clear search cache (useful after search algorithm changes)
  Future<void> clearSearchCache() async {
    await _cache.clearSearchCache();
  }

  // ==================== CLEANUP ====================

  /// Do not close an injected client here. Caller manages lifecycle.
  void dispose() {}
}
