import 'package:graphql_flutter/graphql_flutter.dart';

import 'package:app_geek_hobby_app/Classes/anime.dart';
import 'package:app_geek_hobby_app/Classes/anime_group.dart';

import 'anilist/anilist_api.dart';
import 'anilist/anilist_cache.dart';
import 'anilist/anilist_grouping_service.dart';
import 'anilist/anilist_rate_limiter.dart';

export 'anilist/anilist_exceptions.dart';

/// Main service for interacting with AniList API
/// 
/// This class coordinates API calls, caching, rate limiting, and anime grouping.
/// Use `AniListService.instance` to access the singleton.
class AniListService {
  static late AniListService instance;

  /// Default number of top search results to group automatically
  static const int defaultGroupTop = 5;

  late final AniListCache _cache;
  late final AniListRateLimiter _rateLimiter;
  late final AniListAPI _api;
  late final AniListGroupingService _grouping;

  AniListService() {
    final httpLink = HttpLink('https://graphql.anilist.co');
    final client = GraphQLClient(link: httpLink, cache: GraphQLCache());
    
    _cache = AniListCache();
    _rateLimiter = AniListRateLimiter(_cache.statsBox);
    _api = AniListAPI(client, _rateLimiter);
    _grouping = AniListGroupingService(_cache, _api);
  }

  // ==================== PUBLIC TRACKING GETTERS ====================

  int get sessionRequests => _rateLimiter.sessionRequests;
  int get requestsLastMinute => _rateLimiter.requestsLastMinute;
  int get minuteLimit => AniListRateLimiter.minuteLimit;
  DateTime? get lastRequestTime => _rateLimiter.lastRequestTime;
  int get todayRequestsMade => _rateLimiter.todayRequestsMade;

  int get totalGroups => _cache.totalGroups;
  int get totalGroupedAnime => _cache.totalGroupedAnime;
  int get totalCachedAnime => _cache.totalCachedAnime;

  // ==================== API METHODS ====================

  /// Search anime with caching and hybrid grouping
  Future<List<Anime>> searchAnime({
    String search = '',
    int page = 1,
    int perPage = 20,
    Duration cacheTTL = const Duration(days: 3),
    bool enableGrouping = true,
    int groupTop = defaultGroupTop,
  }) async {
    final cacheKey = 'anilist|search=$search|page=$page|perPage=$perPage';

    // Check cache first
    final cachedIds = _cache.getCachedSearchResults(cacheKey);
    if (cachedIds != null && cachedIds.isNotEmpty) {
      if (_cache.isFresh(cacheKey, cacheTTL)) {
        final cached = _cache.getCachedAnimeList(cachedIds);
        if (cached.length == cachedIds.length) {
          // If grouping enabled, try to group top results in background
          if (enableGrouping && page == 1) {
            _grouping.groupTopResults(cached.take(groupTop).toList());
          }
          return cached;
        }
      }
    }

    // Fetch from API
    final animeList = await _api.searchAnime(
      search: search,
      page: page,
      perPage: perPage,
    );
    if (animeList.isEmpty) return [];

    // Cache the results
    final ids = await _cache.cacheAnimeList(animeList);
    await _cache.cacheSearchResults(cacheKey, ids);

    // If grouping enabled and first page, group top results in background
    if (enableGrouping && page == 1) {
      _grouping.groupTopResults(animeList.take(groupTop).toList());
    }

    return animeList;
  }

  /// Get trending anime with caching and optional grouping
  Future<List<Anime>> fetchTrending({
    int page = 1,
    int perPage = 20,
    Duration cacheTTL = const Duration(days: 3),
    bool enableGrouping = true,
    int groupTop = defaultGroupTop,
  }) async {
    final cacheKey = 'anilist|trending|page=$page|perPage=$perPage';

    // Check cache first
    final cachedIds = _cache.getCachedSearchResults(cacheKey);
    if (cachedIds != null && cachedIds.isNotEmpty) {
      if (_cache.isFresh(cacheKey, cacheTTL)) {
        final cached = _cache.getCachedAnimeList(cachedIds);
        if (cached.length == cachedIds.length) {
          if (enableGrouping && page == 1) {
            _grouping.groupTopResults(cached.take(groupTop).toList());
          }
          return cached;
        }
      }
    }

    // Fetch from API
    final animeList = await _api.fetchTrending(page: page, perPage: perPage);
    if (animeList.isEmpty) return [];

    // Cache the results
    final ids = await _cache.cacheAnimeList(animeList);
    await _cache.cacheSearchResults(cacheKey, ids);

    if (enableGrouping && page == 1) {
      _grouping.groupTopResults(animeList.take(groupTop).toList());
    }

    return animeList;
  }

  /// Get most popular anime (all-time) with caching
  Future<List<Anime>> fetchMostPopular({
    int page = 1,
    int perPage = 20,
    Duration cacheTTL = const Duration(days: 7),
  }) async {
    final cacheKey = 'anilist|popular|page=$page|perPage=$perPage';

    // Check cache first
    final cachedIds = _cache.getCachedSearchResults(cacheKey);
    if (cachedIds != null && cachedIds.isNotEmpty) {
      if (_cache.isFresh(cacheKey, cacheTTL)) {
        final cached = _cache.getCachedAnimeList(cachedIds);
        if (cached.length == cachedIds.length) {
          return cached;
        }
      }
    }

    // Fetch from API
    final animeList = await _api.fetchMostPopular(page: page, perPage: perPage);
    if (animeList.isEmpty) return [];

    // Cache the results
    final ids = await _cache.cacheAnimeList(animeList);
    await _cache.cacheSearchResults(cacheKey, ids);

    return animeList;
  }

  /// Get upcoming/coming soon anime with caching
  Future<List<Anime>> fetchComingSoon({
    int page = 1,
    int perPage = 20,
    Duration cacheTTL = const Duration(hours: 12),
  }) async {
    final cacheKey = 'anilist|comingSoon|page=$page|perPage=$perPage';

    // Check cache first
    final cachedIds = _cache.getCachedSearchResults(cacheKey);
    if (cachedIds != null && cachedIds.isNotEmpty) {
      if (_cache.isFresh(cacheKey, cacheTTL)) {
        final cached = _cache.getCachedAnimeList(cachedIds);
        if (cached.length == cachedIds.length) {
          return cached;
        }
      }
    }

    // Fetch from API
    final animeList = await _api.fetchComingSoon(page: page, perPage: perPage);
    if (animeList.isEmpty) return [];

    // Cache the results
    final ids = await _cache.cacheAnimeList(animeList);
    await _cache.cacheSearchResults(cacheKey, ids);

    return animeList;
  }

  /// Get anime by genre with caching
  Future<List<Anime>> fetchByGenre({
    required String genre,
    int page = 1,
    int perPage = 20,
    Duration cacheTTL = const Duration(days: 7),
  }) async {
    final cacheKey = 'anilist|genre=$genre|page=$page|perPage=$perPage';

    // Check cache first
    final cachedIds = _cache.getCachedSearchResults(cacheKey);
    if (cachedIds != null && cachedIds.isNotEmpty) {
      if (_cache.isFresh(cacheKey, cacheTTL)) {
        final cached = _cache.getCachedAnimeList(cachedIds);
        if (cached.length == cachedIds.length) {
          return cached;
        }
      }
    }

    // Fetch from API
    final animeList = await _api.fetchByGenre(
      genre: genre,
      page: page,
      perPage: perPage,
    );
    if (animeList.isEmpty) return [];

    // Cache the results
    final ids = await _cache.cacheAnimeList(animeList);
    await _cache.cacheSearchResults(cacheKey, ids);

    return animeList;
  }

  // ==================== GROUPING METHODS ====================

  /// Fetch anime relations and build a group
  Future<AnimeGroup?> fetchAnimeRelations(int animeId, {Set<int>? visited}) {
    return _grouping.fetchAnimeRelations(animeId, visited: visited);
  }

  /// Get the group for a specific anime, if it exists
  AnimeGroup? getAnimeGroup(int animeId) {
    return _grouping.getAnimeGroup(animeId);
  }

  /// Check if an anime belongs to a group
  bool isInGroup(int animeId) {
    return _grouping.isInGroup(animeId);
  }

  /// Get or create a group for an anime
  Future<AnimeGroup?> getOrFetchAnimeGroup(int animeId) {
    return _grouping.getOrFetchAnimeGroup(animeId);
  }

  /// Get all anime in a group, with detailed info
  List<Anime> getGroupAnimeList(int groupId) {
    return _grouping.getGroupAnimeList(groupId);
  }

  /// Get summary info about an anime's group (for display in lists)
  Map<String, dynamic>? getGroupSummary(int animeId) {
    return _grouping.getGroupSummary(animeId);
  }

  /// Clear all anime groups (useful for testing/debugging)
  Future<void> clearAllGroups() {
    return _grouping.clearAllGroups();
  }

  /// Clear search cache (useful after search algorithm changes)
  Future<void> clearSearchCache() async {
    await _cache.clearSearchCache();
  }

  /// Clear all cached anime data
  Future<void> clearAnimeCache() async {
    await _cache.clearAnimeCache();
  }

  // ==================== CLEANUP ====================

  void dispose() {
    // GraphQL client doesn't need explicit disposal
  }
}
