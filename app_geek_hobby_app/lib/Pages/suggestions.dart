import 'package:flutter/material.dart';

import 'package:app_geek_hobby_app/Classes/Widgets/empty_state_widget.dart';
import 'package:app_geek_hobby_app/Classes/Widgets/loading_widget.dart';
import 'package:app_geek_hobby_app/Classes/Widgets/swipable_itemcard.dart';
import 'package:app_geek_hobby_app/Services/rawg_service.dart';
import 'package:app_geek_hobby_app/Services/anilist_service.dart';
import 'package:app_geek_hobby_app/Classes/game.dart';
import 'package:app_geek_hobby_app/Classes/anime.dart';
import 'package:app_geek_hobby_app/Services/collections_service.dart';

enum ContentType { games, anime }

class SuggestionsPage extends StatefulWidget {
  const SuggestionsPage({super.key});

  @override
  State<SuggestionsPage> createState() => _SuggestionsPageState();
}

class _SuggestionsPageState extends State<SuggestionsPage> {
  final List<Game> _gameItems = [];
  final List<Anime> _animeItems = [];
  final RawgService _rawg = RawgService.instance;
  final AniListService _anilist = AniListService.instance;
  final CollectionsService _collections = CollectionsService.instance;

  int _gamePage = 1;
  int _animePage = 1;
  final int _pageSize = 20;
  bool _isLoading = false;
  bool _gamesHasMore = true;
  bool _animeHasMore = true;
  final int _prefetchThreshold = 6;

  Offset _cardOffset = Offset.zero;
  ContentType _contentType = ContentType.games;
  String? _selectedGenre; // For games only

  // RAWG genre slugs
  static const Map<String, String> _gameGenres = {
    'all': 'All Genres',
    'action': 'Action',
    'indie': 'Indie',
    'adventure': 'Adventure',
    'rpg': 'RPG',
    'strategy': 'Strategy',
    'shooter': 'Shooter',
    'casual': 'Casual',
    'simulation': 'Simulation',
    'puzzle': 'Puzzle',
    'arcade': 'Arcade',
    'platformer': 'Platformer',
    'racing': 'Racing',
    'sports': 'Sports',
    'fighting': 'Fighting',
  };

  @override
  void initState() {
    super.initState();
    _fetchNextPage();
  }

  void _onContentTypeChanged(ContentType newType) {
    if (newType == _contentType) return;
    
    setState(() {
      _contentType = newType;
      _cardOffset = Offset.zero;
      if (newType == ContentType.anime) {
        _selectedGenre = null; // Clear genre filter for anime
      }
    });
    
    // Only fetch if the new content type has no items yet
    if (newType == ContentType.games && _gameItems.isEmpty) {
      _fetchNextPage();
    } else if (newType == ContentType.anime && _animeItems.isEmpty) {
      _fetchNextPage();
    }
  }

  void _onGenreChanged(String? newGenre) {
    if (newGenre == _selectedGenre || _contentType != ContentType.games) return;
    
    setState(() {
      _selectedGenre = newGenre == 'all' ? null : newGenre;
      _gameItems.clear();
      _gamePage = 1;
      _gamesHasMore = true;
      _cardOffset = Offset.zero;
    });
    
    _fetchNextPage();
  }

  Future<void> _fetchNextPage() async {
    final hasMore = _contentType == ContentType.games ? _gamesHasMore : _animeHasMore;
    if (_isLoading || !hasMore) return;
    setState(() => _isLoading = true);

    try {
      if (_contentType == ContentType.games) {
        await _fetchGames();
      } else {
        await _fetchAnime();
      }
    } catch (e) {
      print('Error fetching suggestions: $e');
      if (mounted) {
        _showSnackBar('Error fetching suggestions: $e');
      }
      if (_contentType == ContentType.games) {
        _gamesHasMore = false;
      } else {
        _animeHasMore = false;
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchGames() async {
    final fetched = await _rawg.fetchGames(
      page: _gamePage,
      pageSize: _pageSize,
      genre: _selectedGenre,
    );
    print('Fetched ${fetched.length} games from RAWG: ${fetched.map((g) => g.id).toList()}');
    
    final existingIds = _gameItems
        .map((item) => item.id)
        .toSet();
    final newGames = <Game>[];
    for (final g in fetched) {
      if (existingIds.contains(g.id)) continue;
      if (await _collections.isGameInAnyCollection(g.id)) continue;
      newGames.add(g);
    }
    print('New games after filtering: ${newGames.map((g) => g.id).toList()}');

    if (fetched.length < _pageSize) _gamesHasMore = false;

    if (newGames.isNotEmpty) {
      setState(() => _gameItems.addAll(newGames));
      print('Added new games to _gameItems. Total now: ${_gameItems.length}');
    } else {
      if (fetched.isNotEmpty && _gamesHasMore) {
        _gamePage++;
        print('All games filtered out, fetching next page...');
        await _fetchNextPage();
        return;
      } else {
        print('No new games to add and no more pages.');
      }
    }

    _gamePage++;
  }

  Future<void> _fetchAnime() async {
    final fetched = await _anilist.fetchTrending(
      page: _animePage,
      perPage: _pageSize,
    );
    print('Fetched ${fetched.length} anime from AniList: ${fetched.map((a) => a.id).toList()}');
    
    final existingIds = _animeItems
        .map((item) => item.id)
        .toSet();
    final newAnime = <Anime>[];
    for (final a in fetched) {
      if (existingIds.contains(a.id)) continue;
      newAnime.add(a);
    }
    print('New anime after filtering: ${newAnime.map((a) => a.id).toList()}');

    if (fetched.length < _pageSize) _animeHasMore = false;

    if (newAnime.isNotEmpty) {
      setState(() => _animeItems.addAll(newAnime));
      print('Added new anime to _animeItems. Total now: ${_animeItems.length}');
    } else {
      if (fetched.isNotEmpty && _animeHasMore) {
        _animePage++;
        print('All anime filtered out, fetching next page...');
        await _fetchNextPage();
        return;
      } else {
        print('No new anime to add and no more pages.');
      }
    }

    _animePage++;
  }

  // Shared remove handler
  void _removeTop() {
    final items = _contentType == ContentType.games ? _gameItems : _animeItems;
    if (items.isEmpty) return;
    items.removeAt(0);
    setState(() {
      _cardOffset = Offset.zero;
    });

    // Prefetch next page if running low
    final hasMore = _contentType == ContentType.games ? _gamesHasMore : _animeHasMore;
    if (items.length <= _prefetchThreshold && hasMore) {
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
    final items = _contentType == ContentType.games ? _gameItems : _animeItems;
    if (items.isEmpty) return;
    final item = items.first;

    try {
      if (_contentType == ContentType.games) {
        final game = item as Game;
        await _collections.addToWishlist(game);
        _showSnackBar('Added "${game.name}" to wishlist');
      } else {
        final anime = item as Anime;
        _showSnackBar('Anime wishlist coming soon! (${anime.name})');
        _removeTop();
        return;
      }
    } catch (e) {
      _showSnackBar('Failed to add to wishlist: $e');
      return;
    }

    _removeTop();
  }

  void _onSkipPressed() {
    final items = _contentType == ContentType.games ? _gameItems : _animeItems;
    if (items.isEmpty) return;
    final name = _contentType == ContentType.games 
        ? (items.first as Game).name 
        : (items.first as Anime).name;
    _removeTop();
    _showSnackBar('Skipped $name');
  }

  // Mark a game as owned and remove it from suggestions (games only)
  Future<void> _markAsOwnedAndRemove() async {
    if (_gameItems.isEmpty || _contentType != ContentType.games) return;
    final game = _gameItems.first;

    try {
      await _collections.addToOwned(game, removeFromOthers: true);
      _showSnackBar('Marked "${game.name}" as owned');
    } catch (e) {
      _showSnackBar('Failed to mark as owned: $e');
      return;
    }

    _removeTop();
  }

  Widget _buildCard(dynamic item, double width, double height) {
    final String? image;
    final IconData fallbackIcon;
    
    if (item is Game) {
      image = (item.imageUrl != null && item.imageUrl!.isNotEmpty) ? item.imageUrl! : null;
      fallbackIcon = Icons.videogame_asset;
    } else if (item is Anime) {
      image = (item.imageUrl != null && item.imageUrl!.isNotEmpty) ? item.imageUrl! : null;
      fallbackIcon = Icons.movie;
    } else {
      image = null;
      fallbackIcon = Icons.help_outline;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: width,
        height: height,
        child: image != null
            ? Image.network(
                image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[350],
                  child: Center(child: Icon(fallbackIcon, size: 48, color: Colors.black26)),
                ),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey[300],
                    child: const LoadingWidget.compact(),
                  );
                },
              )
            : Container(
                color: Colors.grey[350],
                child: Center(child: Icon(fallbackIcon, size: 48, color: Colors.black26)),
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
      body: Column(
        children: [
          // Filter bar with content type and genre selectors
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Column(
              children: [
                // Content type selector (Games vs Anime)
                Row(
                  children: [
                    Expanded(
                      child: SegmentedButton<ContentType>(
                        segments: const [
                          ButtonSegment(
                            value: ContentType.games,
                            label: Text('Games'),
                            icon: Icon(Icons.videogame_asset, size: 18),
                          ),
                          ButtonSegment(
                            value: ContentType.anime,
                            label: Text('Anime'),
                            icon: Icon(Icons.movie, size: 18),
                          ),
                        ],
                        selected: {_contentType},
                        onSelectionChanged: (Set<ContentType> selection) {
                          _onContentTypeChanged(selection.first);
                        },
                      ),
                    ),
                  ],
                ),
                
                // Genre filter (only for games)
                if (_contentType == ContentType.games) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.filter_list, size: 18),
                      const SizedBox(width: 8),
                      const Text('Genre:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButton<String>(
                          value: _selectedGenre ?? 'all',
                          isExpanded: true,
                          underline: Container(),
                          isDense: true,
                          items: _gameGenres.entries.map((entry) {
                            return DropdownMenuItem<String>(
                              value: entry.key,
                              child: Text(entry.value, style: const TextStyle(fontSize: 13)),
                            );
                          }).toList(),
                          onChanged: _onGenreChanged,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          
          // Main content area
          Expanded(
            child: (_contentType == ContentType.games ? _gameItems : _animeItems).isEmpty
                ? Center(
                    child: _isLoading
                        ? const LoadingWidget.inline()
                        : EmptyStateWidget.withAction(
                            message: 'No suggestions available',
                            actionLabel: 'Fetch More Suggestions',
                            onAction: () {
                              setState(() {
                                if (_contentType == ContentType.games) {
                                  _gamesHasMore = true;
                                } else {
                                  _animeHasMore = true;
                                }
                              });
                              _fetchNextPage();
                            },
                          ),
                  )
          : LayoutBuilder(
              builder: (context, constraints) {
                // Reserve minimum space for bottom content (~180px)
                final minBottomSpace = 180.0;
                final availableForTop = constraints.maxHeight - minBottomSpace;
                
                // Top area takes 50-55% of height, but respect minimum bottom space
                final topAreaHeight = (constraints.maxHeight * 0.52).clamp(
                  constraints.maxHeight * 0.45,
                  availableForTop,
                );

                // Compute a responsive width based on available width
                final rawWidth = constraints.maxWidth * 0.55;
                final boxWidth = rawWidth.clamp(180.0, 380.0);

                // Preferred aspect ratio for card: height = width * 1.5 (slightly shorter)
                final preferredHeight = boxWidth * 1.5;

                // Ensure the box height fits within the top area (leave padding)
                final boxHeight = (preferredHeight <= topAreaHeight * 0.88)
                    ? preferredHeight
                    : (topAreaHeight * 0.88);

                // Centering offsets for the card within the top area
                final centerTop = (topAreaHeight - boxHeight) / 2;
                final centerLeft = (constraints.maxWidth - boxWidth) / 2;

                // Compute scalable font sizes based on boxWidth (slightly smaller)
                final double titleFont = (boxWidth * 0.065).clamp(13.0, 28.0);
                final double subtitleFont = (boxWidth * 0.04).clamp(10.0, 16.0);

                // Icon sizing for bottom action bar (slightly smaller)
                final double actionIconSize = (boxWidth * 0.10).clamp(18.0, 32.0);

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
                          if ((_contentType == ContentType.games ? _gameItems : _animeItems).isNotEmpty)
                            Positioned(
                              top: centerTop,
                              left: centerLeft,
                              child: SwipeCard(
                                key: ValueKey(
                                  _contentType == ContentType.games 
                                    ? _gameItems.first.id 
                                    : _animeItems.first.id
                                ),
                                width: boxWidth,
                                height: boxHeight,
                                onDrag: (off) => setState(() => _cardOffset = off),
                                onSwipeRight: () => _onSwipedRight(),
                                onSwipeLeft: () => _onSwipedLeft(),
                                child: _buildCard(
                                  _contentType == ContentType.games ? _gameItems.first : _animeItems.first,
                                  boxWidth,
                                  boxHeight
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // BOTTOM AREA (remaining space) - can hold metadata / controls
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Title + metadata (scaled)
                            if ((_contentType == ContentType.games ? _gameItems : _animeItems).isNotEmpty)
                              Text(
                                _contentType == ContentType.games
                                    ? _gameItems.first.name
                                    : _animeItems.first.name,
                                style: TextStyle(fontSize: titleFont, fontWeight: FontWeight.w700),
                                textAlign: TextAlign.center,
                              ),
                            const SizedBox(height: 8),
                            if (_gameItems.isNotEmpty && _contentType == ContentType.games)
                              Text(
                                'Platforms: ${_gameItems.first.platforms.map((p) => p.toString().split('.').last).join(', ')}',
                                style: TextStyle(fontSize: subtitleFont, color: Colors.black54),
                                textAlign: TextAlign.center,
                              ),
                            if (_animeItems.isNotEmpty && _contentType == ContentType.anime) ...[
                              Text(
                                _animeItems.first.isMovie 
                                    ? 'Movie • ${_animeItems.first.yearReleased}'
                                    : 'Series • ${_animeItems.first.episodes} episodes',
                                style: TextStyle(fontSize: subtitleFont, color: Colors.black54),
                                textAlign: TextAlign.center,
                              ),
                            ],
                            const SizedBox(height: 12),

                            // Action buttons row: Skip, Owned (games only), Like
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
                                  // Owned (games only)
                                  if (_contentType == ContentType.games) ...[
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
                                  ],
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

                            const SizedBox(height: 8),
                            const Text('Swipe left to skip, swipe right to keep.', style: TextStyle(fontSize: 12)),
                            const SizedBox(height: 8),
                            if (_isLoading) const Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: LoadingWidget.inline(),
                            ),
                          ],
                        ),
                      ),
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                );
              }),
          ),
        ],
      ),
    );
  }
}
