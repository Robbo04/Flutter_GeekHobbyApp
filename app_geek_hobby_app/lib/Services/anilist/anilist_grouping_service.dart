import 'package:app_geek_hobby_app/Classes/anime.dart';
import 'package:app_geek_hobby_app/Classes/anime_group.dart';

import 'anilist_cache.dart';
import 'anilist_api.dart';
import 'anilist_parser.dart';

/// Handles anime grouping and franchise management
class AniListGroupingService {
  /// Maximum recursion depth for anime grouping to prevent excessive API calls
  static const int maxGroupingDepth = 10;

  final AniListCache _cache;
  final AniListAPI _api;

  AniListGroupingService(this._cache, this._api);

  // ==================== PUBLIC METHODS====================

  /// Group top search results in background (don't wait for completion)
  void groupTopResults(List<Anime> topResults) {
    Future.microtask(() async {
      for (final anime in topResults) {
        // Skip if already grouped recently
        final existing = getAnimeGroup(anime.id);
        if (existing != null && !existing.needsUpdate()) continue;

        // Fetch relations and create group
        try {
          await fetchAnimeRelations(anime.id);
        } catch (e) {
          // Silently skip anime that can't be grouped (expected for some entries)
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

    final result = await _api.fetchAnimeRelations(animeId);
    if (result == null) return null;

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
      if (relationType == null || !meaningfulTypes.contains(relationType)) {
        continue;
      }

      final node = edge['node'];
      if (node == null) continue;

      final anime = AniListParser.parseAnime(node);
      relatedAnime.add(anime);
      relationMap[anime.id] = relationType;
      relatedIds.add(anime.id);

      // Cache the anime
      await _cache.cacheAnime(anime);
    }

    if (relatedAnime.isEmpty) return null;

    // Get the main anime
    final mainAnime = _cache.animeBox.get(animeId);
    if (mainAnime == null) return null;

    // Build the initial group
    await _buildAnimeGroup(mainAnime, relatedAnime, relationMap);

    // Recursively fetch relations for related anime to build complete franchise
    // But limit depth to prevent too many API calls
    if (visited.length < maxGroupingDepth) {
      for (final relatedId in relatedIds) {
        if (!visited.contains(relatedId)) {
          await fetchAnimeRelations(relatedId, visited: visited);
        }
      }
    }

    // Return the final merged group
    return getAnimeGroup(animeId);
  }

  /// Get the group for a specific anime, if it exists
  AnimeGroup? getAnimeGroup(int animeId) {
    final groupId = _cache.animeToGroupBox.get(animeId);
    if (groupId == null) return null;
    return _cache.groupBox.get(groupId);
  }

  /// Check if an anime belongs to a group
  bool isInGroup(int animeId) {
    return _cache.animeToGroupBox.containsKey(animeId);
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
    final group = _cache.groupBox.get(groupId);
    if (group == null) return [];
    return group.getAnimeList(_cache.animeBox);
  }

  /// Get summary info about an anime's group (for display in lists)
  Map<String, dynamic>? getGroupSummary(int animeId) {
    final group = getAnimeGroup(animeId);
    if (group == null) return null;

    final animeList = group.getAnimeList(_cache.animeBox);
    final totalEpisodes = group.getTotalEpisodes(_cache.animeBox);

    return {
      'groupId': group.groupId,
      'name': group.name,
      'itemCount': animeList.length,
      'totalEpisodes': totalEpisodes,
      'imageUrl': group.imageUrl,
      'isGroup': true,
    };
  }

  /// Clear all anime groups (useful for testing/debugging)
  Future<void> clearAllGroups() async {
    await _cache.groupBox.clear();
    await _cache.animeToGroupBox.clear();
  }

  // ==================== PRIVATE METHODS ====================

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
      final existingGroupId = _cache.animeToGroupBox.get(id);
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
      existingGroup = _cache.groupBox.get(groupId);

      // Add existing group's anime IDs to allIds
      if (existingGroup != null) {
        allIds.addAll(existingGroup.animeIds);
        mergedRelations.addAll(existingGroup.relationTypes);
      }

      // Merge all OTHER groups into this one
      for (final oldGroupId in existingGroupIds) {
        if (oldGroupId == groupId) continue;

        final oldGroup = _cache.groupBox.get(oldGroupId);
        if (oldGroup != null) {
          allIds.addAll(oldGroup.animeIds);
          mergedRelations.addAll(oldGroup.relationTypes);

          // Delete old group
          await _cache.groupBox.delete(oldGroupId);
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
        .map((id) => _cache.animeBox.get(id))
        .whereType<Anime>()
        .toList();
    groupAnimeList.sort((a, b) => a.yearReleased.compareTo(b.yearReleased));
    final primaryAnime = groupAnimeList.isNotEmpty ? groupAnimeList.first : mainAnime;

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
    await _cache.groupBox.put(groupId, group);

    // Map all anime IDs to this group
    for (final id in allIds) {
      await _cache.animeToGroupBox.put(id, groupId);
    }

    return group;
  }
}
