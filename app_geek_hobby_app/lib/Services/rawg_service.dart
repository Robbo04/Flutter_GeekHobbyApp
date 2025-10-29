import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:app_geek_hobby_app/Classes/game.dart';

class RawgService {
  static const String _host = 'api.rawg.io';
  static const String _basePath = '/api';

  static late RawgService instance;

  final String apiKey;
  final http.Client httpClient;

  RawgService({
    required this.apiKey,
    http.Client? httpClient,
  }) : httpClient = httpClient ?? http.Client();

  Box<Game> get _gamesBox => Hive.box<Game>('rawg_games');
  Box<List> get _searchBox => Hive.box<List>('rawg_search_results');

  // Fetch games with persistent cache
  // Accepts optional genre (RAWG slug), page, pageSize, ordering
  Future<List<Game>> fetchGames({
    String search = '',
    String? genre, // RAWG slug like 'action' or comma-separated 'action,indie'
    int page = 1,
    int pageSize = 20,
    String ordering = '',
  }) async {
    // Compose a cache key that includes all relevant query params
    final cacheKey =
        'rawg|search=${search}|genre=${genre ?? ''}|page=$page|pageSize=$pageSize|ordering=$ordering';

    final raw = _searchBox.get(cacheKey);
    final idList = (raw is List) ? raw.cast<int>() : null;

    if (idList != null && idList.isNotEmpty) {
      final games = idList.map((id) => _gamesBox.get(id)).whereType<Game>().toList();
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
    if (genre != null && genre.isNotEmpty) params['genres'] = genre; // RAWG uses 'genres' param
    if (ordering.isNotEmpty) params['ordering'] = ordering;

    final uri = Uri.https(_host, '$_basePath/games', params);
    final response = await httpClient.get(uri);

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

    final uri = Uri.https(_host, '$_basePath/games/$id', {'key': apiKey});
    final response = await httpClient.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final game = Game.fromRawg(data);
      await _gamesBox.put(game.id, game);
      return game;
    } else {
      throw Exception('Failed to load game details (status: ${response.statusCode})');
    }
  }

  /// Do not close an injected client here. If you created the client locally,
  /// caller can manage lifecycle. Provide a dispose only if you create/own client.
  void dispose() {}
}



