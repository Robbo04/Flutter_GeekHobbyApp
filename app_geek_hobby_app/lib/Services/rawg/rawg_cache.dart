import 'package:hive/hive.dart';

import 'package:app_geek_hobby_app/Classes/game.dart';

/// Manages Hive cache storage for RAWG games
class RawgCache {
  // ==================== HIVE BOXES ====================

  Box<Game> get gamesBox => Hive.box<Game>('rawg_games');
  Box<List> get searchBox => Hive.box<List>('rawg_search_results');
  Box<int> get metaBox => Hive.box<int>('rawg_cache_meta');
  Box<int> get statsBox => Hive.box<int>('rawg_stats');

  // ==================== CACHE CHECKING ====================

  /// Check if a cache entry is still fresh (within TTL)
  bool isFresh(String cacheKey, Duration ttl) {
    final ts = metaBox.get(cacheKey);
    if (ts == null) return false;
    final fetched = DateTime.fromMillisecondsSinceEpoch(ts);
    return DateTime.now().difference(fetched) <= ttl;
  }

  // ==================== GAME CACHING ====================

  /// Cache a single game, preserving collection flags from existing entry
  Future<void> cacheGame(Game game) async {
    final existing = gamesBox.get(game.id);
    if (existing != null) {
      // Preserve user's collection state
      game.wishlist = existing.wishlist;
      game.owned = existing.owned;
      game.completed = existing.completed;
      game.userRating = existing.userRating;
    }
    await gamesBox.put(game.id, game);
  }

  /// Cache multiple games
  Future<void> cacheGameList(List<Game> games) async {
    for (final game in games) {
      await cacheGame(game);
    }
  }

  /// Get a cached game by ID
  Game? getCachedGame(int id) {
    return gamesBox.get(id);
  }

  /// Get multiple cached games by IDs
  List<Game> getCachedGameList(List<int> ids) {
    return ids.map((id) => gamesBox.get(id)).whereType<Game>().toList();
  }

  // ==================== SEARCH RESULT CACHING ====================

  /// Cache search results (list of game IDs)
  Future<void> cacheSearchResults(String cacheKey, List<int> gameIds) async {
    await searchBox.put(cacheKey, gameIds);
    await metaBox.put(cacheKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Get cached search results (returns null if not found)
  List<int>? getCachedSearchResults(String cacheKey) {
    final raw = searchBox.get(cacheKey);
    return (raw is List) ? raw.cast<int>() : null;
  }

  // ==================== CACHE MANAGEMENT ====================

  /// Clear all cached data
  Future<void> clearCache() async {
    await gamesBox.clear();
    await searchBox.clear();
  }

  /// Clear only search cache (keeps game data intact)
  Future<void> clearSearchCache() async {
    await searchBox.clear();
    // Clear search-related metadata
    final searchKeys = metaBox.keys.where((key) => key.toString().startsWith('rawg|search='));
    for (final key in searchKeys) {
      await metaBox.delete(key);
    }
  }

  /// Get total number of cached games
  int get totalCachedGames => gamesBox.length;
}
