import 'package:flutter/material.dart';
import 'package:app_geek_hobby_app/Classes/Widgets/swipable_itemcard.dart';
import 'package:app_geek_hobby_app/Services/rawg_service.dart';
import 'package:app_geek_hobby_app/Classes/game.dart';
import 'package:app_geek_hobby_app/Services/collections_service.dart';

class SuggestionsPage extends StatefulWidget {
  const SuggestionsPage({super.key});

  @override
  State<SuggestionsPage> createState() => _SuggestionsPageState();
}

class _SuggestionsPageState extends State<SuggestionsPage> {
  final List<Game> _items = [];
  final RawgService _rawg = RawgService.instance;
  final CollectionsService _collections = CollectionsService.instance;

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

  Future<void> _fetchNextPage() async {
    if (_isLoading || !_hasMore) return;
    setState(() => _isLoading = true);

    try {
      final fetched = await _rawg.fetchGames(page: _page, pageSize: _pageSize);
      print('Fetched ${fetched.length} games from RAWG: ${fetched.map((g) => g.id).toList()}');
      // Filter out games already in any collection and deduplicate against _items
      final existingIds = _items.map((g) => g.id).toSet();
      final newGames = <Game>[];
      for (final g in fetched) {
        if (existingIds.contains(g.id)) continue;
        if (await _collections.isGameInAnyCollection(g.id)) continue;
        newGames.add(g);
      }
      print('New games after filtering: ${newGames.map((g) => g.id).toList()}');

      // If the RAWG page returned less-than-pageSize, we've reached the end.
      if (fetched.length < _pageSize) _hasMore = false;

      if (newGames.isNotEmpty) {
        setState(() => _items.addAll(newGames));
        print('Added new games to _items. Total now: ${_items.length}');
      } else {
        // If all returned items were filtered out but the RAWG page wasn't final, try next page once
        if (fetched.isNotEmpty && _hasMore) {
          _page++;
          print('All games filtered out, fetching next page...');
          await _fetchNextPage();
        } else {
          print('No new games to add and no more pages.');
        }
      }

      _page++;
    } catch (e) {
      print('Error fetching suggestions: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching suggestions: $e')));
      }
      _hasMore = false;
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Shared remove handler
  void _removeTop() {
    if (_items.isEmpty) return;
    _items.removeAt(0);
    setState(() {
      _cardOffset = Offset.zero;
    });

    // Prefetch next page if running low
    if (_items.length <= _prefetchThreshold && _hasMore) {
      _fetchNextPage();
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  // Add to wishlist and remove from suggestions
  Future<void> _addToWishlistAndRemove() async {
    if (_items.isEmpty) return;
    final g = _items.first;

    try {
      await _collections.addToWishlist(g);
      _showSnackBar('Added "${g.name}" to wishlist');
    } catch (e) {
      _showSnackBar('Failed to add to wishlist: $e');
      return;
    }

    _removeTop();
  }

  void _onSkipPressed() {
    if (_items.isEmpty) return;
    final name = _items.first.name;
    _removeTop();
    _showSnackBar('Skipped $name');
  }

  // Mark a game as owned and remove it from suggestions
  Future<void> _markAsOwnedAndRemove() async {
    if (_items.isEmpty) return;
    final g = _items.first;

    try {
      await _collections.addToOwned(g, removeFromOthers: true);
      _showSnackBar('Marked "${g.name}" as owned');
    } catch (e) {
      _showSnackBar('Failed to mark as owned: $e');
      return;
    }

    _removeTop();
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

  // Swipe handlers - delegate to button handlers for consistency
  Future<void> _onSwipedRight() => _addToWishlistAndRemove();
  
  void _onSwipedLeft() => _onSkipPressed();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Suggestions')),
      body: _items.isEmpty
          ? Center(
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('No suggestions available'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _hasMore = true;
                            });
                            _fetchNextPage();
                          },
                          child: const Text('Fetch More Suggestions'),
                        ),
                      ],
                    ),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                // top area takes ~60% of height
                final topAreaHeight = constraints.maxHeight * 0.60;

                // Compute a responsive width based on available width:
                // - use a fraction of the width so it scales on large screens
                // - clamp to keep reasonable min/max sizes
                final rawWidth = constraints.maxWidth * 0.60;
                final boxWidth = rawWidth.clamp(200.0, 420.0);

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
                                onSwipeRight: () => _onSwipedRight(),
                                onSwipeLeft: () => _onSwipedLeft(),
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
                                      onPressed: _addToWishlistAndRemove,
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
