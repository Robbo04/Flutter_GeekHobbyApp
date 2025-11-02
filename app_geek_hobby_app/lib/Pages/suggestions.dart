import 'package:flutter/material.dart';
import 'package:app_geek_hobby_app/Classes/Widgets/swipable_itemcard.dart';
import 'package:app_geek_hobby_app/Services/rawg_service.dart';
import 'package:app_geek_hobby_app/Classes/game.dart';
import 'package:hive/hive.dart';

class SuggestionsPage extends StatefulWidget {
  const SuggestionsPage({super.key});

  @override
  State<SuggestionsPage> createState() => _SuggestionsPageState();
}

class _SuggestionsPageState extends State<SuggestionsPage> {
  final List<Game> _items = [];
  final RawgService _rawg = RawgService.instance;

  int _page = 1;
  final int _pageSize = 20;
  bool _isLoading = false;
  bool _hasMore = true; // assume true until a page proves otherwise
  final int _prefetchThreshold = 6; // when remaining items <= threshold, prefetch next page

  Offset _cardOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    _fetchNextPage();
  }

  bool _isInAnyCollection(int id) {
    try {
      final owned = Hive.isBoxOpen('games_owned_collection_id') ? Hive.box<int>('games_owned_collection_id').containsKey(id) : false;
      final wishlist = Hive.isBoxOpen('games_wishlist_collection_id') ? Hive.box<int>('games_wishlist_collection_id').containsKey(id) : false;
      final backlog = Hive.isBoxOpen('games_backlog_collection_id') ? Hive.box<int>('games_backlog_collection_id').containsKey(id) : false;
      final completed = Hive.isBoxOpen('games_completed_collection_id') ? Hive.box<int>('games_completed_collection_id').containsKey(id) : false;
      return owned || wishlist || backlog || completed;
    } catch (_) {
      // if anything goes wrong assume not in collection to avoid filtering everything
      return false;
    }
  }

  Future<void> _fetchNextPage() async {
    if (_isLoading || !_hasMore) return;
    setState(() => _isLoading = true);

    try {
      final fetched = await _rawg.fetchGames(page: _page, pageSize: _pageSize);
      // Filter out games already in any collection and deduplicate against _items
      final existingIds = _items.map((g) => g.id).toSet();
      final newGames = <Game>[];
      for (final g in fetched) {
        if (existingIds.contains(g.id)) continue;
        if (_isInAnyCollection(g.id)) continue;
        newGames.add(g);
      }

      // If the RAWG page returned less-than-pageSize, we've reached the end.
      if (fetched.length < _pageSize) _hasMore = false;

      if (newGames.isNotEmpty) {
        setState(() => _items.addAll(newGames));
      } else {
        // If all returned items were filtered out but the RAWG page wasn't final, try next page once
        if (fetched.isNotEmpty && _hasMore) {
          _page++;
          await _fetchNextPage();
        } else {
          // nothing new to add
        }
      }

      _page++;
    } catch (e) {
      // swallow errors gracefully; show a small snackbar to inform user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching suggestions: $e')));
      }
      // stop trying further pages to avoid repeated errors
      _hasMore = false;
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Shared remove handler used by swipes and buttons
  void _removeTop(bool liked) {
    if (_items.isEmpty) return;
    final removed = _items.removeAt(0);
    setState(() {
      _cardOffset = Offset.zero;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(liked ? 'Liked ${removed.name}' : 'Skipped ${removed.name}')),
    );

    // If we're getting low on items, prefetch the next page
    if (_items.length <= _prefetchThreshold && _hasMore) {
      _fetchNextPage();
    }
  }

  // Button handlers that reuse _removeTop
  void _onLikePressed() {
    _removeTop(true);
  }

  void _onSkipPressed() {
    _removeTop(false);
  }

  // Mark a game as owned (persist to the owned collection) and remove it from suggestions.
  Future<void> _markAsOwnedAndRemove() async {
    if (_items.isEmpty) return;
    final g = _items.removeAt(0);
    setState(() {
      _cardOffset = Offset.zero;
    });

    try {
      // Add to owned box and remove from other collection boxes if present.
      if (Hive.isBoxOpen('games_owned_collection_id')) {
        await Hive.box<int>('games_owned_collection_id').put(g.id, g.id);
      } else {
        // Try to open the box if not open
        await Hive.openBox<int>('games_owned_collection_id').then((b) => b.put(g.id, g.id));
      }

      // Remove from wishlist/backlog/completed if present
      if (Hive.isBoxOpen('games_wishlist_collection_id')) {
        await Hive.box<int>('games_wishlist_collection_id').delete(g.id);
      }
      if (Hive.isBoxOpen('games_backlog_collection_id')) {
        await Hive.box<int>('games_backlog_collection_id').delete(g.id);
      }
      if (Hive.isBoxOpen('games_completed_collection_id')) {
        await Hive.box<int>('games_completed_collection_id').delete(g.id);
      }

      // Optionally persist the game object in the rawg_games box if available
      try {
        if (Hive.isBoxOpen('rawg_games')) {
          final gamesBox = Hive.box<Game>('rawg_games');
          await gamesBox.put(g.id, g);
        }
      } catch (_) {
        // ignore if adapter/box issues
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Marked "${g.name}" as owned and removed from suggestions')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to mark as owned: $e')));
    }

    // If we're getting low on items, prefetch the next page
    if (_items.length <= _prefetchThreshold && _hasMore) {
      _fetchNextPage();
    }
  }

  Widget _buildCard(Game game, double width, double height) {
    final image = (game.imageUrl != null && game.imageUrl!.isNotEmpty) ? game.imageUrl! : null;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: width,
        height: height,
        child: image != null
            ? Image.network(
                image,
                fit: BoxFit.cover,
                // show a small placeholder if the network image fails
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[350],
                  child: const Center(child: Icon(Icons.broken_image, size: 48, color: Colors.black26)),
                ),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey[300],
                    child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  );
                },
              )
            : Container(
                color: Colors.grey[350],
                child: const Center(child: Icon(Icons.videogame_asset, size: 48, color: Colors.black26)),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Suggestions')),
      body: _items.isEmpty
          ? Center(
              child: _isLoading ? const CircularProgressIndicator() : const Text('No suggestions available'),
            )
          : LayoutBuilder(builder: (context, constraints) {
              // top area takes ~60% of height
              final topAreaHeight = constraints.maxHeight * 0.60;

              // Compute a responsive width based on available width:
              // - use a fraction of the width so it scales on large screens
              // - clamp to keep reasonable min/max sizes
              final rawWidth = constraints.maxWidth * 0.60;
              final boxWidth = (rawWidth.clamp(200.0, 420.0)) as double;

              // Preferred aspect ratio for card: height = width * 1.6 (like 250x400)
              final preferredHeight = boxWidth * 1.6;

              // Ensure the box height fits within the top area (leave a little padding)
              final boxHeight = (preferredHeight <= topAreaHeight * 0.92)
                  ? preferredHeight
                  : (topAreaHeight * 0.92);

              // Centering offsets for the card within the top area
              final centerTop = (topAreaHeight - boxHeight) / 2;
              final centerLeft = (constraints.maxWidth - boxWidth) / 2;

              // Compute scalable font sizes based on boxWidth (clamped to reasonable range)
              final double titleFont = (boxWidth * 0.08).clamp(14.0, 34.0);
              final double subtitleFont = (boxWidth * 0.045).clamp(11.0, 18.0);

              // Icon sizing for bottom action bar
              final double actionIconSize = (boxWidth * 0.12).clamp(20.0, 36.0);

              return Column(
                children: [
                  // TOP AREA (60%): single card centered
                  SizedBox(
                    height: topAreaHeight,
                    width: constraints.maxWidth,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // background color feedback for drag direction
                        Positioned.fill(
                          child: IgnorePointer(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 120),
                              color: _cardOffset.dx < 0
                                  ? const Color.fromARGB(255, 206, 29, 29).withOpacity((_cardOffset.dx.abs() / 200).clamp(0.0, 1.0))
                                  : _cardOffset.dx > 0
                                      ? const Color.fromARGB(255, 60, 244, 54).withOpacity((_cardOffset.dx.abs() / 200).clamp(0.0, 1.0))
                                      : Colors.transparent,
                            ),
                          ),
                        ),

                        // TOP interactive card only - centered (no visible card underneath)
                        if (_items.isNotEmpty)
                          Positioned(
                            top: centerTop,
                            left: centerLeft,
                            child: SwipeCard(
                              key: ValueKey(_items.first.id), // important: tie state to item id
                              width: boxWidth,
                              height: boxHeight,
                              onDrag: (off) => setState(() => _cardOffset = off),
                              onSwipeRight: () => _removeTop(true),
                              onSwipeLeft: () => _removeTop(false),
                              child: _buildCard(_items.first, boxWidth, boxHeight),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // BOTTOM AREA (remaining space) - can hold metadata / controls
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Title + platforms (scaled)
                          if (_items.isNotEmpty)
                            Text(
                              _items.first.name,
                              style: TextStyle(fontSize: titleFont, fontWeight: FontWeight.w700),
                              textAlign: TextAlign.center,
                            ),
                          const SizedBox(height: 8),
                          if (_items.isNotEmpty)
                            Text(
                              'Platforms: ${_items.first.platforms.map((p) => p.toString().split('.').last).join(', ')}',
                              style: TextStyle(fontSize: subtitleFont, color: Colors.black54),
                              textAlign: TextAlign.center,
                            ),
                          const SizedBox(height: 12),

                          // Action buttons row: Like, Skip, Owned
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Skip (left swipe equivalent)
                                CircleAvatar(
                                  radius: actionIconSize * 0.9,
                                  backgroundColor: Colors.grey[200],
                                  child: IconButton(
                                    icon: Icon(Icons.close, color: Colors.red, size: actionIconSize),
                                    onPressed: _onSkipPressed,
                                    tooltip: 'Skip',
                                  ),
                                ),
                                SizedBox(width: boxWidth * 0.08),
                                // Owned
                                CircleAvatar(
                                  radius: actionIconSize * 1.1,
                                  backgroundColor: Colors.grey[200],
                                  child: IconButton(
                                    icon: Icon(Icons.inventory_2, color: Colors.green, size: actionIconSize * 1.05),
                                    onPressed: _markAsOwnedAndRemove,
                                    tooltip: 'I already own this',
                                  ),
                                ),
                                SizedBox(width: boxWidth * 0.08),
                                // Like (right swipe equivalent)
                                CircleAvatar(
                                  radius: actionIconSize * 0.9,
                                  backgroundColor: Colors.grey[200],
                                  child: IconButton(
                                    icon: Icon(Icons.favorite, color: Colors.pink, size: actionIconSize),
                                    onPressed: _onLikePressed,
                                    tooltip: 'Like',
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),
                          const Text('Swipe left to skip, swipe right to keep.'),
                          const SizedBox(height: 12),
                          if (_isLoading) const Padding(
                            padding: EdgeInsets.only(top: 12),
                            child: CircularProgressIndicator(),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              );
            }),
    );
  }
}
