import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hive/hive.dart';
import 'package:app_geek_hobby_app/Classes/anime.dart';

class AniListService {
  static late AniListService instance;

  late final GraphQLClient _client;

  AniListService() {
    final httpLink = HttpLink('https://graphql.anilist.co');
    _client = GraphQLClient(
      link: httpLink,
      cache: GraphQLCache(),
    );
  }

  Box<Anime> get _animeBox => Hive.box<Anime>('anilist_anime');
  Box<List> get _searchBox => Hive.box<List>('anilist_search_results');
  Box<int> get _metaBox => Hive.box<int>('anilist_cache_meta');

  bool _isFresh(String cacheKey, Duration ttl) {
    final ts = _metaBox.get(cacheKey);
    if (ts == null) return false;
    final fetched = DateTime.fromMillisecondsSinceEpoch(ts);
    return DateTime.now().difference(fetched) <= ttl;
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

  // Search anime with caching
  Future<List<Anime>> searchAnime({
    String search = '',
    int page = 1,
    int perPage = 20,
    Duration cacheTTL = const Duration(hours: 24),
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
          return cached;
        }
      }
    }

    // Fetch from API
    try {
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

      // Cache the results
      final ids = <int>[];
      for (final anime in animeList) {
        await _animeBox.put(anime.id, anime);
        ids.add(anime.id);
      }
      await _searchBox.put(cacheKey, ids);
      await _metaBox.put(cacheKey, DateTime.now().millisecondsSinceEpoch);

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
    Duration cacheTTL = const Duration(hours: 24),
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
          return cached;
        }
      }
    }

    // Fetch from API
    try {
      final result = await _client.query(
        QueryOptions(
          document: gql(_trendingQuery),
          variables: {
            'page': page,
            'perPage': perPage,
          },
        ),
      );

      if (result.hasException) {
        print('AniList trending query error: ${result.exception}');
        return [];
      }

      final mediaList = result.data?['Page']?['media'] as List<dynamic>?;
      if (mediaList == null) return [];

      final animeList = mediaList.map((data) => _parseAnime(data)).toList();

      // Cache the results
      final ids = <int>[];
      for (final anime in animeList) {
        await _animeBox.put(anime.id, anime);
        ids.add(anime.id);
      }
      await _searchBox.put(cacheKey, ids);
      await _metaBox.put(cacheKey, DateTime.now().millisecondsSinceEpoch);

      return animeList;
    } catch (e) {
      print('Error fetching trending anime: $e');
      return [];
    }
  }
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

  void dispose() {
    // GraphQL client doesn't need explicit disposal
  }
