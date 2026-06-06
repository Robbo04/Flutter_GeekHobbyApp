import 'package:graphql_flutter/graphql_flutter.dart';

import 'package:app_geek_hobby_app/models/item/anime.dart';
import 'package:app_geek_hobby_app/models/group/anime_group.dart';

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
          // If grouping enabled, use smart grouping
          if (enableGrouping && page == 1) {
            final potentialDuplicates = _findPotentialDuplicates(cached);
            if (potentialDuplicates.isNotEmpty) {
              await _grouping.groupTopResults(potentialDuplicates);
            }
            return _deduplicateByGroup(cached);
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

    // If grouping enabled and first page, use smart grouping
    if (enableGrouping && page == 1) {
      final potentialDuplicates = _findPotentialDuplicates(animeList);
      if (potentialDuplicates.isNotEmpty) {
        await _grouping.groupTopResults(potentialDuplicates);
      }
      return _deduplicateByGroup(animeList);
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
            final potentialDuplicates = _findPotentialDuplicates(cached);
            if (potentialDuplicates.isNotEmpty) {
              await _grouping.groupTopResults(potentialDuplicates);
            }
            return _deduplicateByGroup(cached);
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
      final potentialDuplicates = _findPotentialDuplicates(animeList);
      if (potentialDuplicates.isNotEmpty) {
        await _grouping.groupTopResults(potentialDuplicates);
      }
      return _deduplicateByGroup(animeList);
    }

    return animeList;
  }

  /// Get most popular anime (all-time) with caching
  Future<List<Anime>> fetchMostPopular({
    int page = 1,
    int perPage = 20,
    Duration cacheTTL = const Duration(days: 7),
    bool enableGrouping = true,
    int groupTop = defaultGroupTop,
  }) async {
    final cacheKey = 'anilist|popular|page=$page|perPage=$perPage';

    // Check cache first
    final cachedIds = _cache.getCachedSearchResults(cacheKey);
    if (cachedIds != null && cachedIds.isNotEmpty) {
      if (_cache.isFresh(cacheKey, cacheTTL)) {
        final cached = _cache.getCachedAnimeList(cachedIds);
        if (cached.length == cachedIds.length) {
          if (enableGrouping && page == 1) {
            final potentialDuplicates = _findPotentialDuplicates(cached);
            if (potentialDuplicates.isNotEmpty) {
              await _grouping.groupTopResults(potentialDuplicates);
            }
            return _deduplicateByGroup(cached);
          }
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

    if (enableGrouping && page == 1) {
      final potentialDuplicates = _findPotentialDuplicates(animeList);
      if (potentialDuplicates.isNotEmpty) {
        await _grouping.groupTopResults(potentialDuplicates);
      }
      return _deduplicateByGroup(animeList);
    }

    return animeList;
  }

  /// Get upcoming/coming soon anime with caching
  Future<List<Anime>> fetchComingSoon({
    int page = 1,
    int perPage = 20,
    Duration cacheTTL = const Duration(hours: 12),
    bool enableGrouping = true,
    int groupTop = defaultGroupTop,
  }) async {
    final cacheKey = 'anilist|comingSoon|page=$page|perPage=$perPage';

    // Check cache first
    final cachedIds = _cache.getCachedSearchResults(cacheKey);
    if (cachedIds != null && cachedIds.isNotEmpty) {
      if (_cache.isFresh(cacheKey, cacheTTL)) {
        final cached = _cache.getCachedAnimeList(cachedIds);
        if (cached.length == cachedIds.length) {
          if (enableGrouping && page == 1) {
            final potentialDuplicates = _findPotentialDuplicates(cached);
            if (potentialDuplicates.isNotEmpty) {
              await _grouping.groupTopResults(potentialDuplicates);
            }
            return _deduplicateByGroup(cached);
          }
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

    if (enableGrouping && page == 1) {
      final potentialDuplicates = _findPotentialDuplicates(animeList);
      if (potentialDuplicates.isNotEmpty) {
        await _grouping.groupTopResults(potentialDuplicates);
      }
      return _deduplicateByGroup(animeList);
    }

    return animeList;
  }

  /// Get anime by genre with caching
  Future<List<Anime>> fetchByGenre({
    required String genre,
    int page = 1,
    int perPage = 20,
    Duration cacheTTL = const Duration(days: 7),
    bool enableGrouping = true,
    int groupTop = defaultGroupTop,
  }) async {
    final cacheKey = 'anilist|genre=$genre|page=$page|perPage=$perPage';

    // Check cache first
    final cachedIds = _cache.getCachedSearchResults(cacheKey);
    if (cachedIds != null && cachedIds.isNotEmpty) {
      if (_cache.isFresh(cacheKey, cacheTTL)) {
        final cached = _cache.getCachedAnimeList(cachedIds);
        if (cached.length == cachedIds.length) {
          if (enableGrouping && page == 1) {
            final potentialDuplicates = _findPotentialDuplicates(cached);
            if (potentialDuplicates.isNotEmpty) {
              await _grouping.groupTopResults(potentialDuplicates);
            }
            return _deduplicateByGroup(cached);
          }
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

    if (enableGrouping && page == 1) {
      final potentialDuplicates = _findPotentialDuplicates(animeList);
      if (potentialDuplicates.isNotEmpty) {
        await _grouping.groupTopResults(potentialDuplicates);
      }
      return _deduplicateByGroup(animeList);
    }

    return animeList;
  }

  // ==================== PRIVATE METHODS ====================

  /// Normalize anime title for comparison (remove season indicators, punctuation)
  String _normalizeTitle(String title) {
    return title
        .toLowerCase()
        // Remove numeric season indicators
        .replaceAll(RegExp(r'season \d+'), '')
        .replaceAll(RegExp(r's\d+'), '')
        .replaceAll(RegExp(r'\bpart \d+\b'), '')
        .replaceAll(RegExp(r'\b\d+nd season\b'), '')
        .replaceAll(RegExp(r'\b\d+rd season\b'), '')
        .replaceAll(RegExp(r'\b\d+th season\b'), '')
        // Remove text-based season indicators
        .replaceAll(RegExp(r'\bthe final season\b'), '')
        .replaceAll(RegExp(r'\bfinal season\b'), '')
        .replaceAll(RegExp(r'\bfinal arc\b'), '')
        // Remove movie/special titles (common patterns)
        .replaceAll(RegExp(r'\bthe movie\b'), '')
        .replaceAll(RegExp(r'\bmovie\b'), '')
        // Remove punctuation
        .replaceAll(RegExp(r'[:\-–—!?()]'), ' ')
        .replaceAll("'", ' ')
        .replaceAll('"', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Find anime that likely need grouping based on title similarity
  List<Anime> _findPotentialDuplicates(List<Anime> animeList) {
    final potentialDuplicates = <Anime>[];
    final normalizedTitles = <String>[];

    // Normalize all titles first
    for (final anime in animeList) {
      normalizedTitles.add(_normalizeTitle(anime.name));
    }

    // Find anime that share a common base title
    for (int i = 0; i < animeList.length; i++) {
      final titleA = normalizedTitles[i];
      final wordsA = titleA.split(' ').where((w) => w.isNotEmpty).toList();
      if (wordsA.length < 2) continue; // Need at least 2 words
      
      for (int j = i + 1; j < animeList.length; j++) {
        final titleB = normalizedTitles[j];
        final wordsB = titleB.split(' ').where((w) => w.isNotEmpty).toList();
        if (wordsB.length < 2) continue;
        
        // Check if they share the first 2-3 significant words
        final minWords = wordsA.length < wordsB.length ? wordsA.length : wordsB.length;
        final checkWords = minWords >= 3 ? 3 : 2;
        
        bool matches = true;
        for (int k = 0; k < checkWords; k++) {
          if (wordsA[k] != wordsB[k]) {
            matches = false;
            break;
          }
        }
        
        if (matches) {
          if (!potentialDuplicates.contains(animeList[i])) {
            potentialDuplicates.add(animeList[i]);
          }
          if (!potentialDuplicates.contains(animeList[j])) {
            potentialDuplicates.add(animeList[j]);
          }
        }
      }
    }

    return potentialDuplicates;
  }

  /// Deduplicate anime list by keeping only one representative per group
  List<Anime> _deduplicateByGroup(List<Anime> animeList) {
    final deduplicated = <Anime>[];
    final seenGroups = <int>{};

    for (final anime in animeList) {
      // Check if anime belongs to a group
      final group = _grouping.getAnimeGroup(anime.id);
      final groupId = group?.groupId ?? anime.id;

      // Keep only first anime from each group
      if (!seenGroups.contains(groupId)) {
        deduplicated.add(anime);
        seenGroups.add(groupId);
      }
    }

    return deduplicated;
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
