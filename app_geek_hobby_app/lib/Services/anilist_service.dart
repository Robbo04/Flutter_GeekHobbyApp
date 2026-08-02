import 'package:graphql_flutter/graphql_flutter.dart';

import 'package:app_geek_hobby_app/models/item/anime.dart';
import 'package:app_geek_hobby_app/models/group/anime_franchise.dart';

import 'anilist/anilist_api.dart';
import 'anilist/anilist_cache.dart';
import 'anilist/anilist_rate_limiter.dart';

export 'anilist/anilist_exceptions.dart';

/// Main service for interacting with AniList API
///
/// This class coordinates API calls, caching, rate limiting, and franchise building.
/// Use `AniListService.instance` to access the singleton.
class AniListService {
  static late AniListService instance;

  /// Default number of top search results to group automatically
  static const int defaultGroupTop = 5;

  late final AniListCache _cache;
  late final AniListRateLimiter _rateLimiter;
  late final AniListAPI _api;

  AniListService() {
    final httpLink = HttpLink('https://graphql.anilist.co');
    final client = GraphQLClient(link: httpLink, cache: GraphQLCache());

    _cache = AniListCache();
    _rateLimiter = AniListRateLimiter(_cache.statsBox);
    _api = AniListAPI(client, _rateLimiter);
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

  /// Search anime as franchise-first results.
  ///
  /// Layer 1 (core): explicit AniList relations via grouped IDs.
  /// Layer 2 (fallback): merge unlinked titles when similarity >= 95%.
  Future<List<AnimeFranchise>> searchAnimeFranchises({
    String search = '',
    int page = 1,
    int perPage = 20,
    Duration cacheTTL = const Duration(days: 3),
    int groupTop = defaultGroupTop,
    double fallbackSimilarityThreshold = 0.95,
  }) async {
    final animeList = await searchAnime(
      search: search,
      page: page,
      perPage: perPage,
      cacheTTL: cacheTTL,
      enableGrouping: false,
      groupTop: groupTop,
    );

    return _buildFranchisesForAnimeList(
      animeList,
      page: page,
      groupTop: groupTop,
      fallbackSimilarityThreshold: fallbackSimilarityThreshold,
    );
  }

  Future<List<AnimeFranchise>> fetchTrendingFranchises({
    int page = 1,
    int perPage = 20,
    Duration cacheTTL = const Duration(days: 3),
    int groupTop = defaultGroupTop,
    double fallbackSimilarityThreshold = 0.95,
  }) async {
    final animeList = await fetchTrending(
      page: page,
      perPage: perPage,
      cacheTTL: cacheTTL,
      enableGrouping: false,
      groupTop: groupTop,
    );

    return _buildFranchisesForAnimeList(
      animeList,
      page: page,
      groupTop: groupTop,
      fallbackSimilarityThreshold: fallbackSimilarityThreshold,
    );
  }

  Future<List<AnimeFranchise>> fetchMostPopularFranchises({
    int page = 1,
    int perPage = 20,
    Duration cacheTTL = const Duration(days: 7),
    int groupTop = defaultGroupTop,
    double fallbackSimilarityThreshold = 0.95,
  }) async {
    final animeList = await fetchMostPopular(
      page: page,
      perPage: perPage,
      cacheTTL: cacheTTL,
      enableGrouping: false,
      groupTop: groupTop,
    );

    return _buildFranchisesForAnimeList(
      animeList,
      page: page,
      groupTop: groupTop,
      fallbackSimilarityThreshold: fallbackSimilarityThreshold,
    );
  }

  Future<List<AnimeFranchise>> fetchComingSoonFranchises({
    int page = 1,
    int perPage = 20,
    Duration cacheTTL = const Duration(hours: 12),
    int groupTop = defaultGroupTop,
    double fallbackSimilarityThreshold = 0.95,
  }) async {
    final animeList = await fetchComingSoon(
      page: page,
      perPage: perPage,
      cacheTTL: cacheTTL,
      enableGrouping: false,
      groupTop: groupTop,
    );

    return _buildFranchisesForAnimeList(
      animeList,
      page: page,
      groupTop: groupTop,
      fallbackSimilarityThreshold: fallbackSimilarityThreshold,
    );
  }

  Future<List<AnimeFranchise>> fetchByGenreFranchises({
    required String genre,
    int page = 1,
    int perPage = 20,
    Duration cacheTTL = const Duration(days: 7),
    int groupTop = defaultGroupTop,
    double fallbackSimilarityThreshold = 0.95,
  }) async {
    final animeList = await fetchByGenre(
      genre: genre,
      page: page,
      perPage: perPage,
      cacheTTL: cacheTTL,
      enableGrouping: false,
      groupTop: groupTop,
    );

    return _buildFranchisesForAnimeList(
      animeList,
      page: page,
      groupTop: groupTop,
      fallbackSimilarityThreshold: fallbackSimilarityThreshold,
    );
  }

  Future<List<AnimeFranchise>> _buildFranchisesForAnimeList(
    List<Anime> animeList, {
    required int page,
    required int groupTop,
    required double fallbackSimilarityThreshold,
  }) async {
    if (animeList.isEmpty) return [];

    final filtered = _applyQualityGate(animeList);
    if (filtered.isEmpty) return [];

    return _buildFranchisesFromAnimeList(
      filtered,
      fallbackSimilarityThreshold: fallbackSimilarityThreshold,
    );
  }

  // ==================== PRIVATE METHODS ====================

  List<AnimeFranchise> _buildFranchisesFromAnimeList(
    List<Anime> animeList, {
    required double fallbackSimilarityThreshold,
  }) {
    final clusters = <String, List<Anime>>{};
    final explicitByKey = <String, bool>{};
    final ungrouped = List<Anime>.from(animeList);

    final byId = <int, Anime>{for (final anime in ungrouped) anime.id: anime};
    final ids = byId.keys.toList();
    final parent = <int, int>{for (final id in ids) id: id};
    final explicitlyLinked = <int>{};

    int find(int id) {
      final p = parent[id]!;
      if (p == id) return id;
      final root = find(p);
      parent[id] = root;
      return root;
    }

    void union(int a, int b) {
      final ra = find(a);
      final rb = find(b);
      if (ra != rb) {
        parent[rb] = ra;
      }
    }

    // Graph Stitching: bind results by explicit relation IDs first.
    for (final anime in ungrouped) {
      for (final relatedId in anime.relationNodeIds) {
        if (!byId.containsKey(relatedId)) continue;
        union(anime.id, relatedId);
        explicitlyLinked.add(anime.id);
        explicitlyLinked.add(relatedId);
      }
    }

    final explicitClusters = <int, List<Anime>>{};
    for (final anime in ungrouped) {
      final root = find(anime.id);
      explicitClusters.putIfAbsent(root, () => <Anime>[]).add(anime);
    }

    final clusterKeys = explicitClusters.keys
        .map((root) => 'cluster_$root')
        .toList();
    final clusterByKey = <String, List<Anime>>{};
    final clusterExplicitByKey = <String, bool>{};
    for (final root in explicitClusters.keys) {
      final key = 'cluster_$root';
      final entries = explicitClusters[root]!;
      clusterByKey[key] = entries;
      clusterExplicitByKey[key] = entries.any(
        (anime) => explicitlyLinked.contains(anime.id),
      );
    }

    final clusterParent = <String, String>{
      for (final key in clusterKeys) key: key,
    };

    String findCluster(String key) {
      final p = clusterParent[key]!;
      if (p == key) return key;
      final root = findCluster(p);
      clusterParent[key] = root;
      return root;
    }

    void unionCluster(String a, String b) {
      final ra = findCluster(a);
      final rb = findCluster(b);
      if (ra != rb) {
        clusterParent[rb] = ra;
      }
    }

    // Title match fallback: only for clusters with no explicit relation links.
    final fallbackKeys = clusterKeys
      .where((key) => clusterExplicitByKey[key] == false)
        .toList();
    for (int i = 0; i < fallbackKeys.length; i++) {
      final keyA = fallbackKeys[i];
      final a = clusterByKey[keyA]!;
      final titleA = _normalizeTitle(_pickPrimaryAnime(a).name);

      for (int j = i + 1; j < fallbackKeys.length; j++) {
        final keyB = fallbackKeys[j];
        final b = clusterByKey[keyB]!;
        final titleB = _normalizeTitle(_pickPrimaryAnime(b).name);

        final similarity = _titleSimilarity(titleA, titleB);
        if (similarity >= fallbackSimilarityThreshold) {
          unionCluster(keyA, keyB);
        }
      }
    }

    final mergedEntries = <String, List<Anime>>{...clusters};
    final mergedExplicit = <String, bool>{...explicitByKey};
    for (final key in clusterKeys) {
      final root = findCluster(key);
      mergedEntries
          .putIfAbsent(root, () => <Anime>[])
          .addAll(clusterByKey[key]!);
      mergedExplicit[root] =
          (mergedExplicit[root] ?? false) || (clusterExplicitByKey[key] ?? false);
    }

    return _finalizeFranchisesFromClusters(
      animeList: animeList,
      mergedEntries: mergedEntries,
      mergedExplicit: mergedExplicit,
    );
  }

  List<AnimeFranchise> _finalizeFranchisesFromClusters({
    required List<Anime> animeList,
    required Map<String, List<Anime>> mergedEntries,
    required Map<String, bool> mergedExplicit,
  }) {
    final firstSeenIndex = <int, int>{};
    for (int i = 0; i < animeList.length; i++) {
      firstSeenIndex.putIfAbsent(animeList[i].id, () => i);
    }

    final franchises = <AnimeFranchise>[];
    for (final entry in mergedEntries.entries) {
      final uniqueById = <int, Anime>{};
      for (final anime in entry.value) {
        uniqueById[anime.id] = anime;
      }

      final entries = uniqueById.values.toList();
      _sortFranchiseEntries(entries);

      final primary = _pickPrimaryAnime(entries);
      final sanitizedTitle = _sanitizeMasterTitle(primary.name);
      final rank = entries
          .map((anime) => firstSeenIndex[anime.id])
          .whereType<int>()
          .fold(1 << 30, (best, v) => v < best ? v : best);

      final franchiseId = entries
          .map((anime) => anime.id)
          .fold(primary.id, (best, id) => id < best ? id : best);

      franchises.add(
        AnimeFranchise(
          franchiseId: franchiseId,
          primaryAnimeId: primary.id,
          title: sanitizedTitle,
          heroTitle: primary.name,
          description: primary.description,
          imageUrl: primary.imageUrl,
          coverColor: primary.coverColor,
          entries: entries,
          fromExplicitRelations: mergedExplicit[entry.key] ?? false,
        ),
      );

      // Keep rank by storing in temporary map key.
      firstSeenIndex[franchiseId] = rank;
    }

    franchises.sort((a, b) {
      final aRank = firstSeenIndex[a.franchiseId] ?? 1 << 30;
      final bRank = firstSeenIndex[b.franchiseId] ?? 1 << 30;
      return aRank.compareTo(bRank);
    });

    return franchises;
  }

  List<Anime> _applyQualityGate(List<Anime> animeList) {
    const allowedFormats = {
      'TV',
      'TV_SHORT',
      'MOVIE',
      'OVA',
      'ONA',
    };

    return animeList.where((anime) {
      final format = anime.format.toUpperCase();
      if (!allowedFormats.contains(format)) {
        return false;
      }
      if ((format == 'OVA') && anime.duration <= 3) {
        return false;
      }
      return true;
    }).toList();
  }

  /// Normalize anime title for comparison (remove season indicators, punctuation)
  String _normalizeTitle(String title) {
    return title
        .toLowerCase()
        // Remove separators and noise symbols first.
        .replaceAll(RegExp(r'[:\-–—!?()\[\]{}.,]'), ' ')
        .replaceAll("'", ' ')
        .replaceAll('"', ' ')
        // Remove numeric season indicators
        .replaceAll(RegExp(r'season \d+'), '')
        .replaceAll(RegExp(r's\d+'), '')
        .replaceAll(RegExp(r'\bpart \d+\b'), '')
        .replaceAll(RegExp(r'\b\d+nd season\b'), '')
        .replaceAll(RegExp(r'\b\d+rd season\b'), '')
        .replaceAll(RegExp(r'\b\d+th season\b'), '')
        .replaceAll(RegExp(r'\bcour \d+\b'), '')
        .replaceAll(RegExp(r'\bchapter \d+\b'), '')
        // Remove text-based season indicators
        .replaceAll(RegExp(r'\bthe final season\b'), '')
        .replaceAll(RegExp(r'\bfinal season\b'), '')
        .replaceAll(RegExp(r'\bfinal arc\b'), '')
        .replaceAll(RegExp(r'\bseason\b'), '')
        .replaceAll(RegExp(r'\bpart\b'), '')
        .replaceAll(RegExp(r'\bre\b'), '')
        // Remove movie/special titles (common patterns)
        .replaceAll(RegExp(r'\bthe movie\b'), '')
        .replaceAll(RegExp(r'\bmovie\b'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  String _sanitizeMasterTitle(String title) {
    var sanitized = title.trim();
    sanitized = sanitized
        .replaceAll(RegExp(r'\s*[-:|]\s*', caseSensitive: false), ' ')
        .replaceAll(
          RegExp(
            r'\b(season|part|cour|arc|chapter)\s*\d+\b',
            caseSensitive: false,
          ),
          '',
        )
        .replaceAll(
          RegExp(r'\b(season|part|cour|arc|chapter)\b', caseSensitive: false),
          '',
        )
        .replaceAll(RegExp(r'\b(re:|re)\b$', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (sanitized.isEmpty) return title;
    return sanitized;
  }

  double _titleSimilarity(String a, String b) {
    if (a == b) return 1.0;
    if (a.isEmpty || b.isEmpty) return 0.0;

    final aBigrams = _bigrams(a);
    final bBigrams = _bigrams(b);
    if (aBigrams.isEmpty || bBigrams.isEmpty) {
      return a == b ? 1.0 : 0.0;
    }

    final intersection = aBigrams.where(bBigrams.contains).length;
    return (2.0 * intersection) / (aBigrams.length + bBigrams.length);
  }

  Set<String> _bigrams(String input) {
    final compact = input.replaceAll(' ', '');
    if (compact.length < 2) return {compact};
    final grams = <String>{};
    for (int i = 0; i < compact.length - 1; i++) {
      grams.add(compact.substring(i, i + 2));
    }
    return grams;
  }

  Anime _pickPrimaryAnime(List<Anime> entries) {
    if (entries.length == 1) return entries.first;

    final tvEntries = entries
        .where((anime) => anime.format.toUpperCase() == 'TV')
        .toList();
    if (tvEntries.isNotEmpty) {
      tvEntries.sort((a, b) {
        final aYear = a.yearReleased == 0 ? 9999 : a.yearReleased;
        final bYear = b.yearReleased == 0 ? 9999 : b.yearReleased;
        final yearCmp = aYear.compareTo(bYear);
        if (yearCmp != 0) return yearCmp;
        return a.id.compareTo(b.id);
      });
      return tvEntries.first;
    }

    final sorted = List<Anime>.from(entries);
    sorted.sort((a, b) {
      final aYear = a.yearReleased == 0 ? 9999 : a.yearReleased;
      final bYear = b.yearReleased == 0 ? 9999 : b.yearReleased;
      final yearCmp = aYear.compareTo(bYear);
      if (yearCmp != 0) return yearCmp;
      if (a.isMovie != b.isMovie) {
        return a.isMovie ? 1 : -1;
      }
      return a.id.compareTo(b.id);
    });
    return sorted.first;
  }

  void _sortFranchiseEntries(List<Anime> entries) {
    entries.sort((a, b) {
      final aYear = a.yearReleased == 0 ? 9999 : a.yearReleased;
      final bYear = b.yearReleased == 0 ? 9999 : b.yearReleased;
      final yearCmp = aYear.compareTo(bYear);
      if (yearCmp != 0) return yearCmp;

      final aRank = _formatRank(a.format);
      final bRank = _formatRank(b.format);
      final rankCmp = aRank.compareTo(bRank);
      if (rankCmp != 0) return rankCmp;

      return a.id.compareTo(b.id);
    });
  }

  int _formatRank(String format) {
    switch (format.toUpperCase()) {
      case 'TV':
        return 0;
      case 'TV_SHORT':
        return 1;
      case 'MOVIE':
        return 2;
      case 'OVA':
        return 3;
      case 'ONA':
        return 4;
      case 'SPECIAL':
        return 5;
      default:
        return 10;
    }
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
