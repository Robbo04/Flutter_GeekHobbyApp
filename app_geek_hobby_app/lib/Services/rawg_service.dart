import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class RawgService {
  static const String _baseUrl = 'https://api.rawg.io/api';

  // Use a getter to access the API key from dotenv at runtime
  String get _apiKey => dotenv.env['RAWG_API_KEY'] ?? 'YOUR_RAWG_API_KEY';

  Future<List<Map<String, dynamic>>> fetchGames({String search = ''}) async {
    final url = Uri.parse(
      '$_baseUrl/games?key=$_apiKey${search.isNotEmpty ? '&search=$search' : ''}',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List<dynamic>;
      return results.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load games');
    }
  }
}