import 'package:hive/hive.dart';

import 'package:app_geek_hobby_app/Classes/anime.dart';
import 'package:app_geek_hobby_app/Classes/anime_group.dart';

/// Manages caching for AniList data using Hive
class AniListCache {
  // ==================== HIVE BOXES ====================

  Box<Anime> get animeBox => Hive.box<Anime>('anilist_anime');
  Box<List> get searchBox => Hive.box<List>('anilist_search_results');
  Box<int> get metaBox => Hive.box<int>('anilist_cache_meta');
  Box<AnimeGroup> get groupBox => Hive.box<AnimeGroup>('anilist_groups');
  Box<int> get animeToGroupBox => Hive.box<int>('anilist_anime_to_group');
  Box<int> get statsBox => Hive.box<int>('anilist_stats');

  // ==================== PUBLIC GETTERS ====================

  int get totalGroups => groupBox.length;
  int get totalGroupedAnime => animeToGroupBox.length;
  int get totalCachedAnime => animeBox.length;

  // ==================== CACHE METHODS ====================

  /// Check if a cache entry is still fresh (within TTL)
  bool isFresh(String cacheKey, Duration ttl) {
    final ts = metaBox.get(cacheKey);
    if (ts == null) return false;
    final fetched = DateTime.fromMillisecondsSinceEpoch(ts);
    return DateTime.now().difference(fetched) <= ttl;
  }

  /// Get cached anime list by IDs
  List<Anime> getCachedAnimeList(List<int> ids) {
    return ids
        .map((id) => animeBox.get(id))
        .whereType<Anime>()
        .toList();
  }

  /// Cache a single anime, preserving collection flags if it already exists
  Future<void> cacheAnime(Anime anime) async {
    final existing = animeBox.get(anime.id);
    if (existing != null) {
      // Preserve user's collection state
      anime.wishlist = existing.wishlist;
      anime.owned = existing.owned;
      anime.userRating = existing.userRating;
    }
    await animeBox.put(anime.id, anime);
  }

  /// Cache a list of anime
  Future<List<int>> cacheAnimeList(List<Anime> animeList) async {
    final ids = <int>[];
    for (final anime in animeList) {
      await cacheAnime(anime);
      ids.add(anime.id);
    }
    return ids;
  }

  /// Cache search results
  Future<void> cacheSearchResults(String cacheKey, List<int> ids) async {
    await searchBox.put(cacheKey, ids);
    await metaBox.put(cacheKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Get cached search results
  List<int>? getCachedSearchResults(String cacheKey) {
    final raw = searchBox.get(cacheKey);
    return (raw is List) ? raw.cast<int>() : null;
  }

  /// Clear all search cache (useful when search algorithm changes)
  Future<void> clearSearchCache() async {
    await searchBox.clear();
    // Clear search-related metadata
    final searchKeys = metaBox.keys.where((key) => key.toString().startsWith('anilist|search='));
    for (final key in searchKeys) {
      await metaBox.delete(key);
    }
  }
}
