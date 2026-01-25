# Anime Group Feature - Hybrid Approach Implementation

## Overview
This implementation allows you to group related anime (seasons, movies, OVAs) into a single collection page while maintaining fast search performance.

## How It Works

### The Hybrid Approach
1. **Search returns individual anime immediately** (fast response)
2. **Top 5 results get grouped in background** (progressive enhancement)
3. **Groups are cached in Hive** (persistent storage)
4. **Future searches check for existing groups** (faster over time)
5. **User clicks trigger full group fetch if needed** (on-demand)

### Rate Limit Safety
- **Normal usage**: ~6 queries per search (very safe)
- **With caching**: Often just 1 query per search
- **Never blocks**: Background grouping doesn't slow down search
- **Would need ~15 searches/minute** to hit rate limits

## Files Created/Modified

### New Files
1. **[lib/Classes/anime_group.dart](lib/Classes/anime_group.dart)** - AnimeGroup class with Hive storage
2. **[lib/Classes/anime_group.g.dart](lib/Classes/anime_group.g.dart)** - Generated Hive adapter
3. **[lib/Examples/anime_group_usage_example.dart](lib/Examples/anime_group_usage_example.dart)** - Usage examples

### Modified Files
1. **[lib/Services/anilist_service.dart](lib/Services/anilist_service.dart)** - Added grouping methods
2. **[lib/main.dart](lib/main.dart)** - Added Hive box initialization

## Key Classes

### AnimeGroup
```dart
class AnimeGroup {
  int groupId;              // Primary anime ID
  String name;              // Group name (e.g., "Demon Slayer")
  List<int> animeIds;       // All anime IDs in group
  String? imageUrl;         // Primary image
  int yearReleased;         // First release year
  String studio;            // Primary studio
  DateTime lastUpdated;     // For cache freshness
  Map<int, String> relationTypes; // How items relate (SEQUEL, PREQUEL, etc.)
}
```

## Usage Examples

### Basic Search with Grouping
```dart
final service = AniListService.instance;
final results = await service.searchAnime(
  search: 'Demon Slayer',
  enableGrouping: true,  // Enable hybrid grouping
  groupTop: 5,           // Group top 5 results
);

// Results return immediately, grouping happens in background
```

### Check if Anime is Grouped
```dart
if (service.isInGroup(animeId)) {
  final summary = service.getGroupSummary(animeId);
  print('Part of ${summary['name']} - ${summary['itemCount']} items');
}
```

### Get Full Group When User Clicks
```dart
final group = await service.getOrFetchAnimeGroup(animeId);
if (group != null) {
  final allAnime = service.getGroupAnimeList(group.groupId);
  // Display all seasons/movies together
}
```

### Display Search Results with Group Indicators
```dart
for (final anime in results) {
  if (service.isInGroup(anime.id)) {
    final summary = service.getGroupSummary(anime.id);
    // Show as: "📚 Attack on Titan - Collection (4 items)"
  } else {
    // Show as: "📺 Death Note"
  }
}
```

## API Methods Added to AniListService

### Grouping Methods
- `fetchAnimeRelations(int animeId)` - Fetch and create group from AniList API
- `getAnimeGroup(int animeId)` - Get cached group for an anime
- `isInGroup(int animeId)` - Fast check if anime has a group
- `getOrFetchAnimeGroup(int animeId)` - Get cached or fetch new group
- `getGroupAnimeList(int groupId)` - Get all anime objects in a group
- `getGroupSummary(int animeId)` - Get display info for UI

### Modified Methods
- `searchAnime()` - Added `enableGrouping` and `groupTop` parameters

## Storage

### Hive Boxes
- `anilist_groups` - Stores AnimeGroup objects (typeId: 7)
- `anilist_anime_to_group` - Maps anime.id → group.groupId (fast lookups)

### Cache Behavior
- Groups expire after **7 days** (configurable via `AnimeGroup.needsUpdate()`)
- Background grouping is **fire-and-forget** (doesn't block search)
- Failed background grouping is **silent** (doesn't affect user experience)

## AniList Relations Supported

The system recognizes these relationship types:
- **SEQUEL** - Direct sequels (Season 2, 3, etc.)
- **PREQUEL** - Previous entries
- **PARENT** - Parent story
- **SIDE_STORY** - Spin-offs
- **ALTERNATIVE** - Alternative versions

## Performance Characteristics

### First Search (Cold Cache)
- **Query count**: 1 + 5 background = 6 total
- **User wait time**: ~200-500ms (just the initial search)
- **Background grouping**: 2-5 seconds after search completes

### Subsequent Searches (Warm Cache)
- **Query count**: 1 (just the search)
- **User wait time**: ~200-500ms
- **Cache hit rate**: Increases over time as more groups are discovered

### When User Clicks an Anime
- **If grouped**: Instant (from cache)
- **If not grouped**: 1-2 queries + 1-3 seconds
- **Result**: Permanent group cached for future

## UI Integration Suggestions

### Search Results Page
```dart
// Show badge for grouped items
if (service.isInGroup(anime.id)) {
  final summary = service.getGroupSummary(anime.id);
  return Card(
    child: Column(
      children: [
        Image.network(summary['imageUrl']),
        Text('${summary['name']} (Collection)'),
        Text('${summary['itemCount']} items • ${summary['totalEpisodes']} episodes'),
        Badge(label: 'SERIES'),
      ],
    ),
  );
}
```

### Detail Page
```dart
final group = await service.getOrFetchAnimeGroup(animeId);
if (group != null) {
  final allAnime = service.getGroupAnimeList(group.groupId);
  
  return ListView.builder(
    itemCount: allAnime.length,
    itemBuilder: (context, index) {
      final anime = allAnime[index];
      final relation = group.relationTypes[anime.id] ?? 'Main';
      
      return ListTile(
        title: Text(anime.name),
        subtitle: Text('$relation • ${anime.episodes} episodes'),
        trailing: Text(anime.yearReleased.toString()),
      );
    },
  );
}
```

## Testing

Run the example code:
```dart
import 'package:app_geek_hobby_app/Examples/anime_group_usage_example.dart';

await exampleBasicSearch();
await exampleShowAnimeGroup(21);  // One Piece ID
await exampleCheckGroupStatus(21);
await exampleDisplayWithGroups();
await exampleCacheGrowth();
```

## Future Enhancements

### Possible Improvements
1. **Franchise detection** - Group by franchise name instead of relations
2. **Manual grouping** - Let users create custom collections
3. **Smart sorting** - Order by chronology, not just year
4. **Batch relation fetching** - Fetch multiple anime relations in one query
5. **Group-first search** - Option to search for collections directly
6. **Preload popular franchises** - Pre-cache major series on app start

### Extending to Other Media
The same pattern can be applied to:
- **Games** - Series like "Final Fantasy" or "Mass Effect"
- **Movies** - Film series like "Lord of the Rings"
- **Shows** - TV series with multiple seasons

## Troubleshooting

### Groups not appearing
- Wait 2-3 seconds after search for background grouping
- Check Hive boxes are properly opened in main.dart
- Verify AnimeGroupAdapter is registered

### Rate limit errors
- Reduce `groupTop` parameter (default 5)
- Increase cache TTL to reduce fetches
- Disable grouping temporarily: `enableGrouping: false`

### Stale data
- Groups auto-refresh after 7 days
- Manual refresh: Delete `anilist_groups` and `anilist_anime_to_group` boxes
- Force refresh: `group.needsUpdate()` returns true

## Summary

✅ **Fast searches** - No delay for users
✅ **Progressive enhancement** - Gets better over time
✅ **Rate limit safe** - Background processing prevents API abuse
✅ **Persistent storage** - Groups cached in Hive
✅ **Flexible display** - Can show individual or grouped
✅ **Future-proof** - Easy to extend to other media types

The hybrid approach balances performance, user experience, and API efficiency!
