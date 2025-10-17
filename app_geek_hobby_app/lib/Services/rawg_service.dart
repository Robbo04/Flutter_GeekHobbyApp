import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:app_geek_hobby_app/Classes/game.dart';

class RawgService {
  static const String _baseUrl = 'https://api.rawg.io/api';
  String get _apiKey {
    final key = dotenv.env['RAWG_API_KEY'];
    if (key == null || key.isEmpty) {
      throw Exception('RAWG API key is missing. Please set it in your .env file.');
    }
    return key;
  }

  Box<Game> get _gamesBox => Hive.box<Game>('rawg_games');
  Box<List> get _searchBox => Hive.box<List>('rawg_search_results');

  // Fetch games with persistent cache
  Future<List<Game>> fetchGames({String search = ''}) async {
    final cacheKey = search.isEmpty ? 'all' : search;
    
    final raw = _searchBox.get(cacheKey);
    final idList = (raw is List) ? raw.cast<int>() : null;

    if (idList != null && idList.isNotEmpty) {
      final games = idList
          .map((id) => _gamesBox.get(id))
          .whereType<Game>()
          .toList();
      if (games.length == idList.length) {
        print('Loaded games from cache');
        return games;
      }
    }

    final url = Uri.parse(
      '$_baseUrl/games?key=$_apiKey${search.isNotEmpty ? '&search=$search' : ''}',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List<dynamic>;
      final gamesList = results.map((e) => Game.fromRawg(e)).toList();

      // Store each game by its ID
      for (final game in gamesList) {
        await _gamesBox.put(game.id, game);
      }
      // Store the list of IDs for this search
      await _searchBox.put(cacheKey, gamesList.map((g) => g.id).toList());
      return gamesList;
    } else {
      throw Exception('Failed to load games');
    }
  }

  // Fetch game details with persistent cache
  Future<Game> fetchGameDetails(int id) async {
    final cached = _gamesBox.get(id);
    if (cached != null && cached.isDetailed) return cached;

    final url = Uri.parse('$_baseUrl/games/$id?key=$_apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final game = Game.fromRawg(data);
      await _gamesBox.put(game.id, game);
      return game;
    } else {
      throw Exception('Failed to load game details');
    }
  }
}