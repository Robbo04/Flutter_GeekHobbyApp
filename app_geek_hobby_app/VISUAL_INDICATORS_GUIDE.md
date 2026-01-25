# Visual Group Indicators - Quick Guide

## Where You'll See Group Indicators

### 1. 📱 Search Results (Carousel)
When you search for anime, items that belong to a collection show a **purple badge** with a bookmark icon in the top-right corner of their thumbnail.

**What it looks like:**
```
┌─────────────┐
│ [Image]  📚 │  ← Purple badge here
│             │
│ Demon Slayer│
└─────────────┘
```

### 2. 📄 Anime Detail Page
When viewing an anime that's part of a collection, you'll see a **purple button** near the top that says:
- "Part of [Collection Name] Collection (X items)"

**Example:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Demon Slayer Season 2
━━━━━━━━━━━━━━━━━━━━━━━━━━━━

┌────────────────────────────────┐
│ 📚 Part of Demon Slayer       │  ← Click this!
│    Collection (4 items)        │
└────────────────────────────────┘

Studio: ufotable
Year: 2021
...
```

**Clicking the button** takes you to the Collection Detail Page.

### 3. 📚 Collection Detail Page
Shows all anime in the group with:
- Collection header with total episodes
- List of all seasons/movies/OVAs
- Relation badges (Sequel, Prequel, Side Story, etc.)
- Icons indicating relationship type

**Layout:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
         📚 Collections
    Demon Slayer
  4 items • 48 total episodes
    ufotable • 2019+
━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Collection Items

┌──────────────────────────────┐
│ [Img] Demon Slayer          │
│       ⭐ Main Series         │
│       26 episodes • 2019     │
└──────────────────────────────┘

┌──────────────────────────────┐
│ [Img] Demon Slayer Season 2 │
│       ➡️ Sequel              │
│       18 episodes • 2021     │
└──────────────────────────────┘

┌──────────────────────────────┐
│ [Img] Demon Slayer Movie    │
│       🎬 MOVIE               │
│       1 episodes • 2020      │
└──────────────────────────────┘
```

## How to Test It

### Step 1: Search for a Series
Search for anime that have multiple seasons:
- "Attack on Titan"
- "Demon Slayer"
- "My Hero Academia"
- "One Piece"
- "Naruto"

### Step 2: Wait for Grouping
After the search results appear, **wait 2-3 seconds** for the background grouping to complete.

### Step 3: Look for the Badge
Check the **top 5 results** - some should show the purple 📚 badge in the corner.

### Step 4: Click on an Anime
Tap any anime with the badge. On the detail page, you'll see the purple collection button.

### Step 5: View the Collection
Click the collection button to see all related anime grouped together!

## Relation Type Icons

| Icon | Type | Meaning |
|------|------|---------|
| ⭐ | Main Series | Original/primary series |
| ➡️ | Sequel | Continues the story |
| ⬅️ | Prequel | Came before |
| 🔀 | Side Story | Spin-off or alternative story |
| ↔️ | Alternative | Different version |

## Troubleshooting

### "I don't see any badges"
- Make sure you've restarted the app after implementing the feature
- Try searching for popular series with multiple seasons
- Wait 2-3 seconds after search completes
- Only top 5 results get grouped automatically

### "The collection button doesn't appear"
- The anime might not have relations in AniList
- Try clicking the anime first, then wait - grouping might happen on-demand
- Check if you're connected to the internet

### "How do I know it's working?"
1. Search for "Attack on Titan"
2. Wait 3 seconds
3. Look for purple badges on thumbnails
4. Click one with a badge
5. You should see the collection button!

## Performance Notes

- First search: Might take 2-3 seconds for badges to appear
- Second search: Badges appear instantly (cached)
- Over time: More and more results will have badges automatically

## What Gets Grouped

The system automatically groups:
- ✅ TV series seasons (Season 1, 2, 3, etc.)
- ✅ Movies in the same franchise
- ✅ OVAs and specials
- ✅ Spin-offs and side stories
- ✅ Alternative versions

## Colors

- **Purple (#DB A7E3)** - Collection indicators and buttons
- **Orange** - Movie badges
- **Grey** - Relation text

Enjoy your organized anime collections! 🎉
