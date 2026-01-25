/// Example usage of the Anime Group hybrid approach
/// 
/// This demonstrates how the system works:
/// 1. Search returns individual anime quickly
/// 2. Top 5 results get grouped in background
/// 3. Future searches benefit from cached groups
/// 4. When user clicks an anime, it can show the full group

import 'package:app_geek_hobby_app/Services/anilist_service.dart';
import 'package:app_geek_hobby_app/Classes/anime.dart';
import 'package:app_geek_hobby_app/Classes/anime_group.dart';

/// Example 1: Basic search with automatic grouping
Future<void> exampleBasicSearch() async {
  final service = AniListService.instance;
  
  // Search - top 5 results will be grouped in background
  final results = await service.searchAnime(
    search: 'Demon Slayer',
    enableGrouping: true, // Enable hybrid grouping (default: true)
    groupTop: 5,          // Group top 5 results (default: 5)
  );
  
  // Results are returned immediately, grouping happens async
  print('Found ${results.length} anime');
  
  // Later, check if any results were grouped
  for (final anime in results.take(5)) {
    final groupSummary = service.getGroupSummary(anime.id);
    if (groupSummary != null) {
      print('${anime.name} is part of group: ${groupSummary['name']}');
      print('  - ${groupSummary['itemCount']} items in collection');
      print('  - ${groupSummary['totalEpisodes']} total episodes');
    }
  }
}

/// Example 2: When user clicks an anime, show its group
Future<void> exampleShowAnimeGroup(int animeId) async {
  final service = AniListService.instance;
  
  // Get or fetch the group for this anime
  final group = await service.getOrFetchAnimeGroup(animeId);
  
  if (group != null) {
    // This anime is part of a collection
    print('Collection: ${group.name}');
    
    // Get all anime in the group
    final allAnime = service.getGroupAnimeList(group.groupId);
    
    print('Contains ${allAnime.length} anime:');
    for (final anime in allAnime) {
      final relationType = group.relationTypes[anime.id] ?? 'Main';
      print('  - ${anime.name} ($relationType)');
      print('    ${anime.episodes} episodes, ${anime.yearReleased}');
    }
  } else {
    // This anime has no related entries
    print('This is a standalone anime');
  }
}

/// Example 3: Check if anime is already grouped (fast lookup)
Future<void> exampleCheckGroupStatus(int animeId) async {
  final service = AniListService.instance;
  
  if (service.isInGroup(animeId)) {
    // Already grouped - can show group badge in UI
    final groupSummary = service.getGroupSummary(animeId);
    print('Part of collection: ${groupSummary?['name']}');
    print('${groupSummary?['itemCount']} items');
  } else {
    // Not yet grouped - show as individual item
    print('Individual anime (no collection yet)');
  }
}

/// Example 4: Display search results with group indicators
Future<void> exampleDisplayWithGroups() async {
  final service = AniListService.instance;
  
  final results = await service.searchAnime(
    search: 'Attack on Titan',
    enableGrouping: true,
  );
  
  for (final anime in results) {
    if (service.isInGroup(anime.id)) {
      final summary = service.getGroupSummary(anime.id);
      // Show as collection in UI
      print('📚 ${summary?['name']} - Collection (${summary?['itemCount']} items)');
    } else {
      // Show as individual item
      print('📺 ${anime.name}');
    }
  }
}

/// Example 5: Performance - how the cache builds over time
Future<void> exampleCacheGrowth() async {
  final service = AniListService.instance;
  
  // First search - top 5 get grouped
  await service.searchAnime(search: 'naruto', enableGrouping: true);
  print('Search 1: Top 5 grouped in background');
  
  // Wait a moment for background grouping
  await Future.delayed(const Duration(seconds: 2));
  
  // Second search - if any results were in first search, they're already grouped
  final results2 = await service.searchAnime(search: 'ninja', enableGrouping: true);
  
  int alreadyGrouped = 0;
  for (final anime in results2) {
    if (service.isInGroup(anime.id)) alreadyGrouped++;
  }
  
  print('Search 2: $alreadyGrouped results already grouped from cache!');
}
