# Fixing Split Groups (e.g., Jujutsu Kaisen)

## The Problem
Previously, if you searched for different anime in the same franchise separately, they would create separate groups. For example:
- Jujutsu Kaisen Season 1 → Group A
- Jujutsu Kaisen Season 2 → Group B

## The Solution
The updated code now:
1. **Checks for existing groups** before creating new ones
2. **Merges groups** if anime are related
3. **Recursively fetches relations** to build complete franchises
4. **Uses consistent group IDs** based on the earliest anime

## How to Fix Existing Split Groups

### Option 1: Clear and Rebuild (Recommended)
Add this code to your app temporarily to clear all groups and let them rebuild:

```dart
import 'package:app_geek_hobby_app/Services/anilist_service.dart';

// Run once to clear split groups
await AniListService.instance.clearAllGroups();

// Then search again - groups will rebuild correctly
final results = await AniListService.instance.searchAnime(
  search: 'Jujutsu Kaisen',
);
```

### Option 2: Automatic Fix
Just search for the anime again. The new code will:
1. Detect the anime is in multiple groups
2. Automatically merge them
3. Use the earliest group as the canonical one

### Testing the Fix

1. **Clear existing groups:**
```dart
await AniListService.instance.clearAllGroups();
```

2. **Search for a franchise:**
```dart
final results = await AniListService.instance.searchAnime(
  search: 'Jujutsu Kaisen',
  enableGrouping: true,
);
```

3. **Wait 3-5 seconds** (recursive fetching takes longer)

4. **Check the first result:**
```dart
final firstAnime = results.first;
final summary = AniListService.instance.getGroupSummary(firstAnime.id);
print('Group: ${summary?['name']}');
print('Items: ${summary?['itemCount']}'); // Should show all seasons/movies
```

5. **Verify all items grouped:**
```dart
final group = await AniListService.instance.getOrFetchAnimeGroup(firstAnime.id);
final allAnime = AniListService.instance.getGroupAnimeList(group!.groupId);
for (final anime in allAnime) {
  print('- ${anime.name} (${anime.yearReleased})');
}
```

## What Changed

### Before:
```
Search "Jujutsu Kaisen"
→ JJK S1 creates Group 40748
→ JJK S2 creates Group 51009
→ Result: 2 separate groups ❌
```

### After:
```
Search "Jujutsu Kaisen"
→ JJK S1 creates Group 40748
→ JJK S2 finds S1's group, merges into 40748
→ Recursively fetches JJK 0 (movie)
→ Recursively fetches JJK Season 2 Part 2
→ Result: 1 complete group ✅
```

## Improvements Made

1. **Group Merging**: Checks if any anime in the relations are already grouped
2. **Consistent Group IDs**: Always uses the earliest anime's ID
3. **Recursive Relations**: Fetches up to 10 levels of relations
4. **Deduplication**: Prevents fetching the same anime multiple times
5. **Automatic Cleanup**: Deletes old groups when merging

## Performance Impact

- **Recursive fetching** may take 3-5 seconds for large franchises
- **Limited to 10 depth** to prevent excessive API calls
- **Still respects rate limits** (~6-10 queries per franchise)
- **Caches everything** so subsequent lookups are instant

## Examples of Franchises That Benefit

These should now group correctly:
- ✅ Jujutsu Kaisen (Movie + 2 Seasons)
- ✅ Attack on Titan (4 Seasons + OVAs)
- ✅ My Hero Academia (6+ Seasons + Movies)
- ✅ Demon Slayer (2 Seasons + Movie)
- ✅ One Piece (Multiple arcs)

## Troubleshooting

### Groups still split after clearing
- Make sure you restarted the app
- Wait 5 seconds after search
- Try searching for the earliest entry (e.g., "Jujutsu Kaisen Season 1")

### Too many items in group
- Some anime have ALTERNATIVE versions that shouldn't be grouped
- This is an AniList data issue, not a code bug
- Can be filtered in future updates

### Groups taking too long to build
- Reduce the depth limit in the code (currently 10)
- Or disable recursive fetching for faster (but incomplete) groups

## Developer Notes

The key change is in `_buildAnimeGroup`:
```dart
// Check if any anime are already in existing groups
final existingGroupIds = <int>{};
for (final id in allIds) {
  final existingGroupId = _animeToGroupBox.get(id);
  if (existingGroupId != null) {
    existingGroupIds.add(existingGroupId);
  }
}

// Merge all groups into the earliest one
if (existingGroupIds.isNotEmpty) {
  groupId = existingGroupIds.reduce((a, b) => a < b ? a : b);
  // ... merge logic
}
```

This ensures franchises stay together regardless of which anime you search for first!
