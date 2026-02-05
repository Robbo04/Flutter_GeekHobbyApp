import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:app_geek_hobby_app/Classes/game.dart';

class RawgRateLimitException implements Exception {
  final String message;
  final int remainingRequests;
  final int monthlyLimit;
  
  RawgRateLimitException({
    required this.message,
    required this.remainingRequests,
    required this.monthlyLimit,
  });
  
  @override
  String toString() => message;
}

class RawgService {
  static const String _host = 'api.rawg.io';
  static const String _basePath = '/api';

  static late RawgService instance;

  final String apiKey;
  final http.Client httpClient;

  // Request tracking
  static const int _monthlyLimit = 20000; // RAWG free tier limit
  int _sessionRequests = 0;
  DateTime? _lastRequestTime;

  RawgService({required this.apiKey, http.Client? httpClient})
    : httpClient = httpClient ?? http.Client();

  Box<Game> get _gamesBox => Hive.box<Game>('rawg_games');
  Box<List> get _searchBox => Hive.box<List>('rawg_search_results');
  Box<int> get _metaBox => Hive.box<int>('rawg_cache_meta');
  Box<int> get _statsBox => Hive.box<int>('rawg_stats');

  // Public getters for tracking
  int get sessionRequests => _sessionRequests;
  int get monthlyRequestsMade {
    final currentMonth = '${DateTime.now().year}-${DateTime.now().month}';
    return _statsBox.get('requests_$currentMonth') ?? 0;
  }

  int get monthlyRequestsRemaining =>
      (_monthlyLimit - monthlyRequestsMade).clamp(0, _monthlyLimit);
  int get monthlyLimit => _monthlyLimit;
  DateTime? get lastRequestTime => _lastRequestTime;
  double get usagePercentage =>
      (monthlyRequestsMade / _monthlyLimit * 100).clamp(0, 100);

  bool _isFresh(String cacheKey, Duration ttl) {
    final ts = _metaBox.get(cacheKey);
    if (ts == null) return false;
    final fetched = DateTime.fromMillisecondsSinceEpoch(ts);
    return DateTime.now().difference(fetched) <= ttl;
  }

  void _checkRateLimit() {
    if (monthlyRequestsRemaining <= 0) {
      throw RawgRateLimitException(
        message: 'RAWG API monthly limit reached ($monthlyLimit requests). Limit resets at the start of next month.',
        remainingRequests: monthlyRequestsRemaining,
        monthlyLimit: _monthlyLimit,
      );
    }
  }

  // Fetch games with persistent cache
  // Accepts optional genre (RAWG slug), page, pageSize, ordering
  Future<List<Game>> fetchGames({
    String search = '',
    String? genre, // RAWG slug like 'action' or comma-separated 'action,indie'
    int page = 1,
    int pageSize = 20,
    String ordering = '-added',

    int daysToCache = 30,
    Duration cacheTTLHours = const Duration(days: 3),
  }) async {
    // Compose a cache key that includes all relevant query params
    final cacheKey =
        'rawg|search=${search}|genre=${genre ?? ''}|page=$page|pageSize=$pageSize|ordering=$ordering';

    final raw = _searchBox.get(cacheKey);
    final idList = (raw is List) ? raw.cast<int>() : null;

    if (idList != null && idList.isNotEmpty) {
      final games = idList
          .map((id) => _gamesBox.get(id))
          .whereType<Game>()
          .toList();
      if (games.length == idList.length) {
        // All results available in cache
        print('Loaded games from cache for key: $cacheKey');
        return games;
      }
    }

    // Build query parameters
    final Map<String, String> params = {
      'key': apiKey,
      'page': page.toString(),
      'page_size': pageSize.toString(),
    };
    if (search.isNotEmpty) params['search'] = search;
    if (genre != null && genre.isNotEmpty)
      params['genres'] = genre; // RAWG uses 'genres' param
    if (ordering.isNotEmpty) params['ordering'] = ordering;

_checkRateLimit();
      final uri = Uri.https(_host, '$_basePath/games', params);
    final response = await httpClient.get(uri);
    _trackRequest();

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List<dynamic>;
      final gamesList = results.map((e) => Game.fromRawg(e)).toList();

      // Store each game by its ID
      for (final game in gamesList) {
        await _gamesBox.put(game.id, game);
      }
      // Store the list of IDs for this search cache key
      await _searchBox.put(cacheKey, gamesList.map((g) => g.id).toList());
      return gamesList;
    } else {
      throw Exception('Failed to load games (status: ${response.statusCode})');
    }
  }

  // Fetch game details with persistent cache
  Future<Game> fetchGameDetails(int id) async {
    final cached = _gamesBox.get(id);
    if (cached != null && cached.isDetailed) return cached;

    _checkRateLimit();
    final uri = Uri.https(_host, '$_basePath/games/$id', {'key': apiKey});
    final response = await httpClient.get(uri);
    _trackRequest();

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final game = Game.fromRawg(data);
      await _gamesBox.put(game.id, game);
      return game;
    } else {
      throw Exception(
        'Failed to load game details (status: ${response.statusCode})',
      );
    }
  }

  Future<void> clearCache() async {
    await _gamesBox.clear();
    await _searchBox.clear();
  }

  void _trackRequest() {
    _sessionRequests++;
    _lastRequestTime = DateTime.now();

    // Track monthly count
    final currentMonth = '${DateTime.now().year}-${DateTime.now().month}';
    final currentCount = _statsBox.get('requests_$currentMonth') ?? 0;
    _statsBox.put('requests_$currentMonth', currentCount + 1);
  }

  /// Do not close an injected client here. If you created the client locally,
  /// caller can manage lifecycle. Provide a dispose only if you create/own client.
  void dispose() {}

  /// Fetch "trending" games by looking at items most-added in the last [days].
  /// This is an approximation: RAWG doesn't have a single /trending endpoint.
  Future<List<Game>> fetchTrending({
    int days = 30,
    String? genre,
    int page = 1,
    int pageSize = 20,
    String ordering = '-added',
    Duration ttl = const Duration(hours: 24), // default TTL
    bool softTtl =
        true, // if true, serve cached immediately and refresh in background
    int minMetacritic = 60,
    int minRatingsCount = 50,
  }) async {
    final to = DateTime.now();
    final from = to.subtract(Duration(days: days));
    final dateStr =
        '${from.toIso8601String().split('T')[0]},${to.toIso8601String().split('T')[0]}';
    final cacheKey =
        'trending|days=$days|genre=${genre ?? ''}|page=$page|size=$pageSize|ordering=$ordering';

    // Try cached ids
    final raw = _searchBox.get(cacheKey);
    final idList = (raw is List) ? raw.cast<int>() : null;

    // If cached and fresh, return cached
    if (idList != null && idList.isNotEmpty && _isFresh(cacheKey, ttl)) {
      // Try to assemble and fetch only missing items. Set allowPartialReturn=true if you
      // prefer to return what you have immediately (soft behavior).
      final assembled = await _assembleFromIds(
        idList,
        missingFetchBatch: 5,
        allowPartialReturn: false,
      );
      if (assembled.isNotEmpty && assembled.length == idList.length) {
        // All satisfied from cache or missing fetches — return them
        return assembled;
      }
      // else: assembly incomplete -> fall through to full network fetch (or you could instead
      // return partial assembled list if you set allowPartialReturn=true)
    }

    // If soft TTL and cached exists, return cached while refreshing in background
    if (softTtl && idList != null && idList.isNotEmpty) {
      final cachedGames = idList
          .map((id) => _gamesBox.get(id))
          .whereType<Game>()
          .toList();
      // Refresh but don't await (fire-and-forget)
      _assembleFromIds(idList, missingFetchBatch: 5, allowPartialReturn: true);
      if (cachedGames.isNotEmpty) return cachedGames;
    }

    // Synchronous fetch (cache missing or hard TTL)
    final fresh = await _fetchTrendingFromNetwork(
      cacheKey: cacheKey,
      dateStr: dateStr,
      pageSize: pageSize,
      genre: genre,
      ordering: ordering,
      minMetacritic: minMetacritic,
      minRatingsCount: minRatingsCount,
    );
    return fresh;
  }

  // Helper: background refresh
  void _refreshTrendingAndStore(
    String cacheKey,
    String dateStr,
    int pageSize,
    String? genre,
    String ordering,
    int minMetacritic,
    int minRatingsCount,
  ) {
    // Fire-and-forget
    _fetchTrendingFromNetwork(
      cacheKey: cacheKey,
      dateStr: dateStr,
      pageSize: pageSize,
      genre: genre,
      ordering: ordering,
      minMetacritic: minMetacritic,
      minRatingsCount: minRatingsCount,
    );
  }

  Future<List<Game>> _fetchTrendingFromNetwork({
    required String cacheKey,
    required String dateStr,
    required int pageSize,
    String? genre,
    required String ordering,
    required int minMetacritic,
    required int minRatingsCount,
  }) async {
    final Map<String, String> params = {
      'key': apiKey,
      'page': '1',
      'page_size': pageSize.toString(),
      'dates': dateStr,
      'ordering': ordering,
    };
    if (genre != null && genre.isNotEmpty) params['genres'] = genre;

    _checkRateLimit();
    final uri = Uri.https(_host, '$_basePath/games', params);
    final response = await httpClient.get(uri);
    _trackRequest();
    if (response.statusCode != 200)
      throw Exception(
        'Failed to fetch trending (status: ${response.statusCode})',
      );

    final data = json.decode(response.body) as Map<String, dynamic>;
    final results = (data['results'] as List<dynamic>)
        .map((e) => Game.fromRawg(e))
        .where((g) {
          // Filter out low-quality / low-evidence items
          if (g.metacriticRating != -1 && g.metacriticRating < minMetacritic)
            return false;
          if (g.ratingCount < minRatingsCount) return false;
          return true;
        })
        .toList();

    for (final g in results) {
      await _gamesBox.put(g.id, g);
    }

    await _searchBox.put(cacheKey, results.map((g) => g.id).toList());
    await _metaBox.put(cacheKey, DateTime.now().millisecondsSinceEpoch);

    return results;
  }

  /// Assemble games from an ID list, fetching only missing IDs.
  /// - [missingFetchBatch] controls how many detail requests run per batch.
  /// - If [allowPartialReturn] is true and some fetches fail, it still returns the partial list.
  Future<List<Game>> _assembleFromIds(
    List<int> ids, {
    int missingFetchBatch = 5,
    bool allowPartialReturn = false,
  }) async {
    final List<Game> assembled = [];
    final List<int> missing = [];

    // 1) take cached ones first (prefer detailed)
    for (final id in ids) {
      final cached = _gamesBox.get(id);
      if (cached != null) {
        // Prefer detailed cached entries so we don't overwrite rich cache
        assembled.add(cached);
      } else {
        missing.add(id);
      }
    }

    // helper: fetch a single id but return null on error instead of throwing
    Future<Game?> _safeFetch(int id) async {
      try {
        return await fetchGameDetails(id);
      } catch (_) {
        return null;
      }
    }

    // 2) fetch missing ones in small batches to avoid hammering the API
    if (missing.isNotEmpty) {
      for (var i = 0; i < missing.length; i += missingFetchBatch) {
        final batch = missing.sublist(
          i,
          (i + missingFetchBatch).clamp(0, missing.length),
        );
        // produce Future<Game?> for each id
        final futures = batch.map((id) => _safeFetch(id));
        final fetched = await Future.wait(futures);
        for (final g in fetched.whereType<Game>()) {
          assembled.add(g);
        }
      }
    }

    // 3) restore original ordering and drop duplicates
    final Map<int, Game> byId = {for (final g in assembled) g.id: g};
    final ordered = <Game>[];
    for (final id in ids) {
      final g = byId[id];
      if (g != null) ordered.add(g);
    }

    // 4) if we couldn't fetch all and partial returns are not allowed,
    // return an empty list to indicate cache is incomplete (caller may fetch network)
    if (!allowPartialReturn && ordered.length != ids.length) return [];

    return ordered;
  }

  Future<void> refreshAllCachedGames({
    int batchSize = 5,
    Duration delay = const Duration(milliseconds: 500),
  }) async {
    final ids = _gamesBox.keys.cast<int>().toList();
    for (var i = 0; i < ids.length; i += batchSize) {
      final batch = ids.sublist(i, (i + batchSize).clamp(0, ids.length));
      final futures = batch.map((id) async {
        try {
          final uri = Uri.https(_host, '$_basePath/games/$id', {'key': apiKey});
          final response = await httpClient.get(uri);
          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            final game = Game.fromRawg(data);
            // preserve any local-only fields you care about? currently this overwrites
            // the stored object with the latest parsed Game.
            await _gamesBox.put(game.id, game);
          }
        } catch (_) {
          // ignore per-id failures, continue with others
        }
      }).toList();

      await Future.wait(futures);
      await Future.delayed(delay);
    }
  }
}
