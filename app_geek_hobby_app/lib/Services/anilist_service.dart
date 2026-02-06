import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hive/hive.dart';
import 'package:app_geek_hobby_app/Classes/anime.dart';
import 'package:app_geek_hobby_app/Classes/anime_group.dart';

class AniListRateLimitException implements Exception {
  final String message;
  final int requestsLastMinute;
  final int minuteLimit;
  
  AniListRateLimitException({
    required this.message,
    required this.requestsLastMinute,
    required this.minuteLimit,
  });
  
  @override
  String toString() => message;
}

class AniListService {
  static late AniListService instance;

  late final GraphQLClient _client;

  // Request tracking
  static const int _minuteLimit = 90; // AniList rate limit per minute
  int _sessionRequests = 0;
  DateTime? _lastRequestTime;
  final List<DateTime> _recentRequests = [];

  AniListService() {
    final httpLink = HttpLink('https://graphql.anilist.co');
    _client = GraphQLClient(link: httpLink, cache: GraphQLCache());
  }

  Box<Anime> get _animeBox => Hive.box<Anime>('anilist_anime');
  Box<List> get _searchBox => Hive.box<List>('anilist_search_results');
  Box<int> get _metaBox => Hive.box<int>('anilist_cache_meta');
  Box<AnimeGroup> get _groupBox => Hive.box<AnimeGroup>('anilist_groups');
  Box<int> get _animeToGroupBox =>
      Hive.box<int>('anilist_anime_to_group'); // Maps anime.id -> group.groupId
  Box<int> get _statsBox => Hive.box<int>('anilist_stats');

  // Public getters for tracking
  int get sessionRequests => _sessionRequests;
  int get requestsLastMinute {
    final oneMinuteAgo = DateTime.now().subtract(const Duration(minutes: 1));
    _recentRequests.removeWhere((time) => time.isBefore(oneMinuteAgo));
    return _recentRequests.length;
  }

  int get minuteLimit => _minuteLimit;
  DateTime? get lastRequestTime => _lastRequestTime;
  int get todayRequestsMade {
    final today =
        '${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}';
    return _statsBox.get('requests_$today') ?? 0;
  }

  bool _isFresh(String cacheKey, Duration ttl) {
    final ts = _metaBox.get(cacheKey);
    if (ts == null) return false;
    final fetched = DateTime.fromMillisecondsSinceEpoch(ts);
    return DateTime.now().difference(fetched) <= ttl;
  }

  void _checkRateLimit() {
    final currentRequests = requestsLastMinute;
    if (currentRequests >= _minuteLimit) {
      throw AniListRateLimitException(
        message: 'AniList API rate limit reached ($currentRequests/$_minuteLimit requests per minute). Please wait a moment before trying again.',
        requestsLastMinute: currentRequests,
        minuteLimit: _minuteLimit,
      );
    }
  }

  // GraphQL query for searching anime
  static const String _searchQuery = '''
    query(\$search: String, \$page: Int, \$perPage: Int, \$type: MediaType) {
      Page(page: \$page, perPage: \$perPage) {
        pageInfo {
          total
          currentPage
          lastPage
          hasNextPage
        }
        media(search: \$search, type: \$type, sort: POPULARITY_DESC) {
          id
          title {
            romaji
            english
          }
          format
          episodes
          duration
          seasonYear
          coverImage {
            large
          }
          averageScore
          studios(isMain: true) {
            nodes {
              name
            }
          }
        }
      }
    }
  ''';

  // GraphQL query for anime relations
  static const String _relationsQuery = '''
    query(\$id: Int) {
      Media(id: \$id, type: ANIME) {
        id
        title {
          romaji
          english
        }
        relations {
          edges {
            relationType
            node {
              id
              title {
                romaji
                english
              }
              format
              episodes
              duration
              seasonYear
              coverImage {
                large
              }
              studios(isMain: true) {
                nodes {
                  name
                }
              }
            }
          }
        }
      }
    }
  ''';

  // GraphQL query for anime details
  static const String _detailsQuery = '''
    query(\$id: Int) {
      Media(id: \$id, type: ANIME) {
        id
        title {
          romaji
          english
        }
        format
        episodes
        duration
        seasonYear
        coverImage {
          large
        }
        averageScore
        studios(isMain: true) {
          nodes {
            name
          }
        }
        description
        genres
        status
      }
    }
  ''';

  // Search anime with caching and hybrid grouping
  Future<List<Anime>> searchAnime({
    String search = '',
    int page = 1,
    int perPage = 20,
    Duration cacheTTL = const Duration(days: 3),
    bool enableGrouping = true, // Enable hybrid grouping
    int groupTop = 5, // Group top N results
  }) async {
    final cacheKey = 'anilist|search=$search|page=$page|perPage=$perPage';

    // Check cache first
    final raw = _searchBox.get(cacheKey);
    final idList = (raw is List) ? raw.cast<int>() : null;

    if (idList != null && idList.isNotEmpty) {
      if (_isFresh(cacheKey, cacheTTL)) {
        final cached = idList
            .map((id) => _animeBox.get(id))
            .whereType<Anime>()
            .toList();
        if (cached.length == idList.length) {
          // If grouping enabled, try to group top results in background
          if (enableGrouping && page == 1) {
            _groupTopResults(cached.take(groupTop).toList());
          }
          return cached;
        }
      }
    }

    // Fetch from API
    try {
      _checkRateLimit();
      _trackRequest();
      final result = await _client.query(
        QueryOptions(
          document: gql(_searchQuery),
          variables: {
            'search': search,
            'page': page,
            'perPage': perPage,
            'type': 'ANIME',
          },
        ),
      );

      if (result.hasException) {
        print('AniList query error: ${result.exception}');
        return [];
      }

      final mediaList = result.data?['Page']?['media'] as List<dynamic>?;
      if (mediaList == null) return [];

      final animeList = mediaList.map((data) => _parseAnime(data)).toList();

      // Cache the results, preserving existing collection flags
      final ids = <int>[];
      for (final anime in animeList) {
        final existing = _animeBox.get(anime.id);
        if (existing != null) {
          // Preserve user's collection state
          anime.wishlist = existing.wishlist;
          anime.owned = existing.owned;
          anime.userRating = existing.userRating;
        }
        await _animeBox.put(anime.id, anime);
        ids.add(anime.id);
      }
      await _searchBox.put(cacheKey, ids);
      await _metaBox.put(cacheKey, DateTime.now().millisecondsSinceEpoch);

      // If grouping enabled and first page, group top results in background
      if (enableGrouping && page == 1) {
        _groupTopResults(animeList.take(groupTop).toList());
      }

      return animeList;
    } catch (e) {
      print('Error searching anime: $e');
      return [];
    }
  }

  // Get trending anime
  static const String _trendingQuery = '''
    query(\$page: Int, \$perPage: Int) {
      Page(page: \$page, perPage: \$perPage) {
        media(type: ANIME, sort: TRENDING_DESC) {
          id
          title {
            romaji
            english
          }
          format
          episodes
          duration
          seasonYear
          coverImage {
            large
          }
          averageScore
          studios(isMain: true) {
            nodes {
              name
            }
          }
        }
      }
    }
  ''';

  Future<List<Anime>> fetchTrending({
    int page = 1,
    int perPage = 20,
    Duration cacheTTL = const Duration(days: 3),
    bool enableGrouping = true, // Enable hybrid grouping
    int groupTop = 5, // Group top N results
  }) async {
    final cacheKey = 'anilist|trending|page=$page|perPage=$perPage';

    // Check cache first
    final raw = _searchBox.get(cacheKey);
    final idList = (raw is List) ? raw.cast<int>() : null;

    if (idList != null && idList.isNotEmpty) {
      if (_isFresh(cacheKey, cacheTTL)) {
        final cached = idList
            .map((id) => _animeBox.get(id))
            .whereType<Anime>()
            .toList();
        if (cached.length == idList.length) {
          // If grouping enabled, try to group top results in background
          if (enableGrouping && page == 1) {
            _groupTopResults(cached.take(groupTop).toList());
          }
          return cached;
        }
      }
    }

    // Fetch from API
    try {
      _checkRateLimit();
      _trackRequest();
      final result = await _client.query(
        QueryOptions(
          document: gql(_trendingQuery),
          variables: {'page': page, 'perPage': perPage},
        ),
      );

      if (result.hasException) {
        print('AniList trending query error: ${result.exception}');
        return [];
      }

      final mediaList = result.data?['Page']?['media'] as List<dynamic>?;
      if (mediaList == null) return [];

      final animeList = mediaList.map((data) => _parseAnime(data)).toList();

      // Cache the results, preserving existing collection flags
      final ids = <int>[];
      for (final anime in animeList) {
        final existing = _animeBox.get(anime.id);
        if (existing != null) {
          // Preserve user's collection state
          anime.wishlist = existing.wishlist;
          anime.owned = existing.owned;
          anime.userRating = existing.userRating;
        }
        await _animeBox.put(anime.id, anime);
        ids.add(anime.id);
      }
      await _searchBox.put(cacheKey, ids);
      await _metaBox.put(cacheKey, DateTime.now().millisecondsSinceEpoch);

      // If grouping enabled and first page, group top results in background
      if (enableGrouping && page == 1) {
        _groupTopResults(animeList.take(groupTop).toList());
      }

      return animeList;
    } catch (e) {
      print('Error fetching trending anime: $e');
      return [];
    }
  }

  // ==================== ANIME GROUP METHODS ====================

  /// Group top search results in background (don't wait for completion)
  void _groupTopResults(List<Anime> topResults) {
    // Run asynchronously without awaiting
    Future.microtask(() async {
      for (final anime in topResults) {
        // Skip if already grouped recently
        final existing = getAnimeGroup(anime.id);
        if (existing != null && !existing.needsUpdate()) continue;

        // Fetch relations and create group
        try {
          await fetchAnimeRelations(anime.id);
        } catch (e) {
          // Silently fail for background grouping
          print('Background grouping failed for ${anime.name}: $e');
        }
      }
    });
  }

  /// Fetch anime relations and build a group
  Future<AnimeGroup?> fetchAnimeRelations(
    int animeId, {
    Set<int>? visited,
  }) async {
    visited ??= <int>{};

    // Prevent infinite loops
    if (visited.contains(animeId)) return null;
    visited.add(animeId);

    try {
      _checkRateLimit();
      _trackRequest();
      final result = await _client.query(
        QueryOptions(
          document: gql(_relationsQuery),
          variables: {'id': animeId},
        ),
      );

      if (result.hasException) {
        print('AniList relations query error: ${result.exception}');
        return null;
      }

      final media = result.data?['Media'];
      if (media == null) return null;

      final relations = media['relations']?['edges'] as List<dynamic>?;
      if (relations == null || relations.isEmpty) return null;

      // Filter for meaningful relations (SEQUEL, PREQUEL, PARENT, SIDE_STORY)
      final meaningfulTypes = {
        'SEQUEL',
        'PREQUEL',
        'PARENT',
        'SIDE_STORY',
        'ALTERNATIVE',
      };
      final relatedAnime = <Anime>[];
      final relationMap = <int, String>{};
      final relatedIds = <int>[];

      for (final edge in relations) {
        final relationType = edge['relationType'] as String?;
        if (relationType == null || !meaningfulTypes.contains(relationType))
          continue;

        final node = edge['node'];
        if (node == null) continue;

        final anime = _parseAnime(node);
        relatedAnime.add(anime);
        relationMap[anime.id] = relationType;
        relatedIds.add(anime.id);

        // Cache the anime, preserving existing collection flags
        final existing = _animeBox.get(anime.id);
        if (existing != null) {
          anime.wishlist = existing.wishlist;
          anime.owned = existing.owned;
          anime.userRating = existing.userRating;
        }
        await _animeBox.put(anime.id, anime);
      }

      if (relatedAnime.isEmpty) return null;

      // Get the main anime
      final mainAnime = _animeBox.get(animeId);
      if (mainAnime == null) return null;

      // Build the initial group
      await _buildAnimeGroup(mainAnime, relatedAnime, relationMap);

      // Recursively fetch relations for related anime to build complete franchise
      // But limit depth to prevent too many API calls
      if (visited.length < 10) {
        for (final relatedId in relatedIds) {
          if (!visited.contains(relatedId)) {
            await fetchAnimeRelations(relatedId, visited: visited);
          }
        }
      }

      // Return the final merged group
      return getAnimeGroup(animeId);
    } catch (e) {
      print('Error fetching anime relations: $e');
      return null;
    }
  }

  /// Build an AnimeGroup from a main anime and its relations
  Future<AnimeGroup> _buildAnimeGroup(
    Anime mainAnime,
    List<Anime> relatedAnime,
    Map<int, String> relationMap,
  ) async {
    // Collect all anime IDs
    final allIds = <int>{mainAnime.id, ...relatedAnime.map((a) => a.id)};

    // Check if any anime are already in existing groups and merge
    final existingGroupIds = <int>{};
    for (final id in allIds) {
      final existingGroupId = _animeToGroupBox.get(id);
      if (existingGroupId != null) {
        existingGroupIds.add(existingGroupId);
      }
    }

    // If existing groups found, merge all anime into the earliest group
    int groupId;
    AnimeGroup? existingGroup;
    Map<int, String> mergedRelations = Map.from(relationMap);

    if (existingGroupIds.isNotEmpty) {
      // Use the earliest existing group as the canonical one
      groupId = existingGroupIds.reduce((a, b) => a < b ? a : b);
      existingGroup = _groupBox.get(groupId);

      // Add existing group's anime IDs to allIds
      if (existingGroup != null) {
        allIds.addAll(existingGroup.animeIds);
        mergedRelations.addAll(existingGroup.relationTypes);
      }

      // Merge all OTHER groups into this one
      for (final oldGroupId in existingGroupIds) {
        if (oldGroupId == groupId) continue;

        final oldGroup = _groupBox.get(oldGroupId);
        if (oldGroup != null) {
          allIds.addAll(oldGroup.animeIds);
          mergedRelations.addAll(oldGroup.relationTypes);

          // Delete old group
          await _groupBox.delete(oldGroupId);
        }
      }
    } else {
      // No existing groups, determine new group ID (use earliest anime)
      final allAnime = [mainAnime, ...relatedAnime];
      allAnime.sort((a, b) => a.yearReleased.compareTo(b.yearReleased));
      groupId = allAnime.first.id;
    }

    // Add relation type for mainAnime if not already there
    if (!mergedRelations.containsKey(mainAnime.id)) {
      mergedRelations[mainAnime.id] = 'MAIN';
    }

    // Determine group name and details from earliest anime
    final groupAnimeList = allIds
        .map((id) => _animeBox.get(id))
        .whereType<Anime>()
        .toList();
    groupAnimeList.sort((a, b) => a.yearReleased.compareTo(b.yearReleased));
    final primaryAnime = groupAnimeList.isNotEmpty
        ? groupAnimeList.first
        : mainAnime;

    // Create or update the group
    final group = AnimeGroup(
      groupId: groupId,
      name: existingGroup?.name ?? primaryAnime.name,
      animeIds: allIds.toList(),
      imageUrl: existingGroup?.imageUrl ?? primaryAnime.imageUrl,
      yearReleased: primaryAnime.yearReleased,
      studio: primaryAnime.studio,
      lastUpdated: DateTime.now(),
      relationTypes: mergedRelations,
    );

    // Save the group
    await _groupBox.put(groupId, group);

    // Map all anime IDs to this group
    for (final id in allIds) {
      await _animeToGroupBox.put(id, groupId);
    }

    return group;
  }

  /// Clear all anime groups (useful for testing/debugging)
  Future<void> clearAllGroups() async {
    await _groupBox.clear();
    await _animeToGroupBox.clear();
    print('Cleared all anime groups');
  }

  /// Get group box stats
  int get totalGroups => _groupBox.length;
  int get totalGroupedAnime => _animeToGroupBox.length;
  int get totalCachedAnime => _animeBox.length;

  /// Get the group for a specific anime, if it exists
  AnimeGroup? getAnimeGroup(int animeId) {
    final groupId = _animeToGroupBox.get(animeId);
    if (groupId == null) return null;
    return _groupBox.get(groupId);
  }

  /// Check if an anime belongs to a group
  bool isInGroup(int animeId) {
    return _animeToGroupBox.containsKey(animeId);
  }

  /// Get or create a group for an anime
  Future<AnimeGroup?> getOrFetchAnimeGroup(int animeId) async {
    // Check if already grouped
    final existing = getAnimeGroup(animeId);
    if (existing != null && !existing.needsUpdate()) {
      return existing;
    }

    // Fetch and create group
    return await fetchAnimeRelations(animeId);
  }

  /// Get all anime in a group, with detailed info
  List<Anime> getGroupAnimeList(int groupId) {
    final group = _groupBox.get(groupId);
    if (group == null) return [];
    return group.getAnimeList(_animeBox);
  }

  /// Get summary info about an anime's group (for display in lists)
  Map<String, dynamic>? getGroupSummary(int animeId) {
    final group = getAnimeGroup(animeId);
    if (group == null) return null;

    final animeList = group.getAnimeList(_animeBox);
    final totalEpisodes = group.getTotalEpisodes(_animeBox);

    return {
      'groupId': group.groupId,
      'name': group.name,
      'itemCount': animeList.length,
      'totalEpisodes': totalEpisodes,
      'imageUrl': group.imageUrl,
      'isGroup': true,
    };
  }

  // Parse AniList data to Anime object
  Anime _parseAnime(Map<String, dynamic> data) {
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

  void _trackRequest() {
    _sessionRequests++;
    final now = DateTime.now();
    _lastRequestTime = now;
    _recentRequests.add(now);

    // Track daily count
    final today = '${now.year}-${now.month}-${now.day}';
    final currentCount = _statsBox.get('requests_$today') ?? 0;
    _statsBox.put('requests_$today', currentCount + 1);

    // Clean up old requests (keep only last minute)
    final oneMinuteAgo = now.subtract(const Duration(minutes: 1));
    _recentRequests.removeWhere((time) => time.isBefore(oneMinuteAgo));
  }

  void dispose() {
    // GraphQL client doesn't need explicit disposal
  }
}
