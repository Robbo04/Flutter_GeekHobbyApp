import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class RawgService {
  static const String _baseUrl = 'https://api.rawg.io/api';
  // Use a getter to access the API key from dotenv at runtime
  String get _apiKey {
  final key = dotenv.env['RAWG_API_KEY'];
  if (key == null || key.isEmpty) {
    throw Exception('RAWG API key is missing. Please set it in your .env file.');
  }
  return key;
}

// In-memory caches
  final Map<String, List<Map<String, dynamic>>> _gamesCache = {};
  final Map<int, Map<String, dynamic>> _detailsCache = {};

  // Fetch a list of games with optional search query
  Future<List<Map<String, dynamic>>> fetchGames({String search = ''}) async {
    if (_gamesCache.containsKey(search)) {
      return _gamesCache[search]!;
    }
    final url = Uri.parse(
      '$_baseUrl/games?key=$_apiKey${search.isNotEmpty ? '&search=$search' : ''}',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List<dynamic>;
      final gamesList = results.cast<Map<String, dynamic>>();
      _gamesCache[search] = gamesList;
      return gamesList;
    } else {
      throw Exception('Failed to load games');
    }
  }

  // Fetch detailed information about a specific game by ID
  Future<Map<String, dynamic>?> fetchGameDetails(int id) async {
    if (_detailsCache.containsKey(id)) {
      return _detailsCache[id];
    }

    final url = Uri.parse('$_baseUrl/games/$id?key=$_apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final gameDetails = json.decode(response.body) as Map<String, dynamic>;
      _detailsCache[id] = gameDetails;
      return gameDetails;
    } else {
      throw Exception('Failed to load game details');
    }
  }
}
