import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'package:app_geek_hobby_app/models/group/anime_franchise.dart';
import 'package:app_geek_hobby_app/models/item/anime.dart';
import 'package:app_geek_hobby_app/services/anilist_service.dart';
import 'package:app_geek_hobby_app/services/collections_service.dart';
import 'package:app_geek_hobby_app/core/utils/text_formatter.dart';
import 'package:app_geek_hobby_app/widgets/common/user_rating_bar.dart';

class AnimeFranchiseDetailPage extends StatefulWidget {
  final AnimeFranchise franchise;

  const AnimeFranchiseDetailPage({super.key, required this.franchise});

  @override
  State<AnimeFranchiseDetailPage> createState() => _AnimeFranchiseDetailPageState();
}

class _AnimeFranchiseDetailPageState extends State<AnimeFranchiseDetailPage> {
  final _aniListService = AniListService.instance;
  late AnimeFranchise _franchise;
  bool _isLoading = true;
  late bool _isFranchiseWatched;
  late bool _isFranchiseWishlisted;
  late int _franchiseRating;
  int _watchedCount = 0;

  @override
  void initState() {
    super.initState();
    _franchise = widget.franchise;
    _isFranchiseWatched = false;
    _isFranchiseWishlisted = false;
    _franchiseRating = 0;
    _loadFullInstallments();
  }

  void _loadCollectionStatus() {
    final watchedBox = Hive.box<int>('anime_watched_collection_id');
    // Individual progress bar count
    int watchedCount = 0;
    for (final anime in _franchise.entries) {
      if (watchedBox.containsKey(anime.id)) {
        watchedCount++;
      }
    }
    // Franchise-level state uses only the primary anime ID
    final isFranchiseWatched = watchedBox.containsKey(_franchise.primaryAnimeId);

    final wishlistBox = Hive.box<int>('anime_wishlist_collection_id');
    final isFranchiseWishlisted = wishlistBox.containsKey(_franchise.primaryAnimeId);

    if (mounted) {
      setState(() {
        _watchedCount = watchedCount;
        _isFranchiseWatched = isFranchiseWatched;
        _isFranchiseWishlisted = isFranchiseWishlisted;
        _franchiseRating = _franchise.franchiseRating;
      });
    }
  }

  Future<void> _loadFullInstallments() async {
    try {
      final group = await _aniListService.getOrFetchAnimeGroup(widget.franchise.primaryAnimeId);
      if (!mounted) return;
      if (group != null) {
        final entries = _aniListService.getGroupAnimeList(group.groupId);
        entries.sort((a, b) {
          final yearCmp = a.yearReleased.compareTo(b.yearReleased);
          if (yearCmp != 0) return yearCmp;
          return a.id.compareTo(b.id);
        });

        setState(() {
          _franchise = AnimeFranchise(
            franchiseId: widget.franchise.franchiseId,
            primaryAnimeId: widget.franchise.primaryAnimeId,
            title: widget.franchise.title,
            heroTitle: widget.franchise.heroTitle,
            description: widget.franchise.description,
            imageUrl: widget.franchise.imageUrl,
            coverColor: widget.franchise.coverColor,
            entries: entries,
            fromExplicitRelations: true,
          );
          _isLoading = false;
        });
        _loadCollectionStatus();
        return;
      }
    } catch (_) {
      // Fall back to existing franchise payload.
    }

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
    _loadCollectionStatus();
  }

  Future<void> _toggleFranchiseWatched() async {
    final newState = !_isFranchiseWatched;
    setState(() {
      _isFranchiseWatched = newState;
      if (newState) _isFranchiseWishlisted = false;
    });

    // Find the primary anime entry to store as the single collection item
    final primaryAnime = _franchise.entries.where(
      (e) => e.id == _franchise.primaryAnimeId,
    ).firstOrNull ?? _franchise.entries.firstOrNull;

    if (primaryAnime == null) return;

    try {
      if (newState) {
        await CollectionsService.instance.addAnimeToWatched(
          primaryAnime,
          removeFromWishlist: true,
        );
      } else {
        await CollectionsService.instance.removeAnimeFromWatched(primaryAnime);
      }
    } catch (e, st) {
      debugPrint('Failed to toggle franchise watched: $e\n$st');
      _loadCollectionStatus();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e')),
        );
      }
    }
  }

  Future<void> _toggleFranchiseWishlist() async {
    setState(() {
      _isFranchiseWishlisted = !_isFranchiseWishlisted;
    });

    final primaryAnime = _franchise.entries.where(
      (e) => e.id == _franchise.primaryAnimeId,
    ).firstOrNull ?? _franchise.entries.firstOrNull;

    if (primaryAnime == null) return;

    try {
      if (_isFranchiseWishlisted) {
        await CollectionsService.instance.addAnimeToWishlist(primaryAnime);
      } else {
        await CollectionsService.instance.removeAnimeFromWishlist(primaryAnime);
      }
    } catch (e, st) {
      debugPrint('Failed to toggle franchise wishlist: $e\n$st');
      setState(() {
        _isFranchiseWishlisted = !_isFranchiseWishlisted;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e')),
        );
      }
    }
  }

  Future<void> _setFranchiseRating(int rating) async {
    setState(() {
      _franchiseRating = rating;
    });

    final primaryAnime = _franchise.entries.where(
      (e) => e.id == _franchise.primaryAnimeId,
    ).firstOrNull ?? _franchise.entries.firstOrNull;

    if (primaryAnime == null) return;

    try {
      primaryAnime.userRating = rating;
      await primaryAnime.save();
    } catch (e, st) {
      debugPrint('Failed to set franchise rating: $e\n$st');
      setState(() {
        _franchiseRating = _franchise.franchiseRating;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update rating: $e')),
        );
      }
    }
  }

  List<Widget> _buildCategorizedCarousels() {
    final mainSeries = _franchise.entries
        .where((a) => a.format.toUpperCase() == 'TV' || a.format.toUpperCase() == 'TV_SHORT')
        .toList();
    final movies = _franchise.entries
        .where((a) => a.format.toUpperCase() == 'MOVIE')
        .toList();
    final specials = _franchise.entries
        .where((a) {
          final fmt = a.format.toUpperCase();
          return fmt == 'OVA' || fmt == 'ONA' || fmt == 'SPECIAL';
        })
        .toList();

    final widgets = <Widget>[];

    if (mainSeries.isNotEmpty) {
      widgets.addAll([
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 4, 0, 10),
          child: Text(
            'Main Series',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700, fontSize: 16, letterSpacing: 0.3),
          ),
        ),
        _FranchiseCarousel(entries: mainSeries),
        const SizedBox(height: 20),
      ]);
    }

    if (movies.isNotEmpty) {
      widgets.addAll([
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 4, 0, 10),
          child: Text(
            'Movies',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700, fontSize: 16, letterSpacing: 0.3),
          ),
        ),
        _FranchiseCarousel(entries: movies),
        const SizedBox(height: 20),
      ]);
    }

    if (specials.isNotEmpty) {
      widgets.addAll([
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 4, 0, 10),
          child: Text(
            'Specials',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700, fontSize: 16, letterSpacing: 0.3),
          ),
        ),
        _FranchiseCarousel(entries: specials),
      ]);
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    final tint =
        _parseAniListColor(_franchise.coverColor) ?? const Color(0xFF1F7A8C);

    return Scaffold(
      appBar: AppBar(
        title: Text(_franchise.title),
        backgroundColor: tint.withOpacity(0.3),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Header(
            franchise: _franchise,
            tint: tint,
            isWatched: _isFranchiseWatched,
            isWishlisted: _isFranchiseWishlisted,
            rating: _franchiseRating,
            watchedCount: _watchedCount,
            onWatchedChanged: _toggleFranchiseWatched,
            onWishlistChanged: _toggleFranchiseWishlist,
            onRatingChanged: _setFranchiseRating,
          ),
          const SizedBox(height: 16),
          if ((_franchise.description ?? '').trim().isNotEmpty) ...[
            Text(
              'Description',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              TextFormatter.normalizeDescription(_franchise.description!),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 18),
          ],
          ..._buildCategorizedCarousels(),
        ],
      ),
    );
  }
}

class _Header extends StatefulWidget {
  final AnimeFranchise franchise;
  final Color tint;
  final bool isWatched;
  final bool isWishlisted;
  final int rating;
  final int watchedCount;
  final VoidCallback onWatchedChanged;
  final VoidCallback onWishlistChanged;
  final Function(int) onRatingChanged;

  const _Header({
    required this.franchise,
    required this.tint,
    required this.isWatched,
    required this.isWishlisted,
    required this.rating,
    required this.watchedCount,
    required this.onWatchedChanged,
    required this.onWishlistChanged,
    required this.onRatingChanged,
  });

  @override
  State<_Header> createState() => _HeaderState();
}

class _HeaderState extends State<_Header> {
  bool _showRatingSlider = false;

  @override
  void didUpdateWidget(_Header oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Collapse slider if watched is removed
    if (!widget.isWatched && _showRatingSlider) {
      setState(() => _showRatingSlider = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [widget.tint.withOpacity(0.22), Colors.white],
        ),
        border: Border.all(color: widget.tint.withOpacity(0.18)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 84,
                  height: 120,
                  color: Colors.grey.shade300,
                  child: (widget.franchise.imageUrl != null && widget.franchise.imageUrl!.isNotEmpty)
                      ? Image.network(widget.franchise.imageUrl!, fit: BoxFit.cover)
                      : const Icon(
                          Icons.movie_creation_outlined,
                          size: 36,
                          color: Colors.grey,
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.franchise.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${widget.franchise.entries.length} entries',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${widget.franchise.totalEpisodes} total episodes',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 6,
              child: LinearProgressIndicator(
                value: widget.franchise.entries.isEmpty
                    ? 0.0
                    : widget.watchedCount / widget.franchise.entries.length,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(
                  widget.tint.withOpacity(0.7),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${widget.watchedCount}/${widget.franchise.entries.length} watched',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ControlButton(
                icon: widget.isWatched ? Icons.check_circle : Icons.circle_outlined,
                label: 'Watched',
                isActive: widget.isWatched,
                onPressed: widget.onWatchedChanged,
              ),
              _ControlButton(
                icon: widget.isWishlisted ? Icons.bookmark : Icons.bookmark_outline,
                label: 'Wishlist',
                isActive: widget.isWishlisted,
                onPressed: widget.onWishlistChanged,
              ),
              // Rate button — disabled if not watched
              Opacity(
                opacity: widget.isWatched ? 1.0 : 0.35,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.star,
                        color: (widget.isWatched && widget.rating > 0)
                            ? Colors.amber
                            : Colors.grey,
                        size: 32,
                      ),
                      onPressed: widget.isWatched
                          ? () => setState(() => _showRatingSlider = !_showRatingSlider)
                          : null,
                      iconSize: 32,
                    ),
                    Text(
                      widget.rating > 0 ? '${widget.rating}/100' : 'Rate',
                      style: const TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Expandable rating slider
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: _showRatingSlider
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: UserRatingSlider(
                initialRating: widget.rating,
                onChanged: widget.onRatingChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onPressed;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon, color: isActive ? Colors.green : Colors.grey),
          onPressed: onPressed,
          iconSize: 32,
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11),
        ),
      ],
    );
  }
}

class _FranchiseEntryTile extends StatefulWidget {
  final Anime anime;

  const _FranchiseEntryTile({required this.anime});

  @override
  State<_FranchiseEntryTile> createState() => _FranchiseEntryTileState();
}

class _FranchiseEntryTileState extends State<_FranchiseEntryTile> {
  late bool _isWatched;

  @override
  void initState() {
    super.initState();
    _loadWatchedStatus();
  }

  void _loadWatchedStatus() async {
    final watchedBox = Hive.box<int>('anime_watched_collection_id');
    final isWatched = watchedBox.containsKey(widget.anime.id);
    if (mounted) {
      setState(() {
        _isWatched = isWatched;
      });
    }
  }

  void _toggleWatched() async {
    setState(() {
      _isWatched = !_isWatched;
    });

    try {
      if (_isWatched) {
        await CollectionsService.instance.addAnimeToWatched(
          widget.anime,
          removeFromWishlist: true,
        );
      } else {
        await CollectionsService.instance.removeAnimeFromWatched(widget.anime);
      }
    } catch (e, st) {
      debugPrint('Failed to toggle watched status: $e\n$st');
      setState(() {
        _isWatched = !_isWatched;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Container(
                width: 56,
                height: 80,
                color: Colors.grey.shade300,
                child: _buildEntryImage(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.anime.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _FormatBadge(format: widget.anime.format),
                      Text(
                        widget.anime.yearReleased > 0
                            ? '${widget.anime.yearReleased}'
                            : 'Unknown year',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      Text(
                        widget.anime.episodes > 0
                            ? '${widget.anime.episodes} eps'
                            : 'Ongoing',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                _isWatched ? Icons.check_circle : Icons.circle_outlined,
                color: _isWatched ? Colors.green : Colors.grey,
                size: 28,
              ),
              onPressed: _toggleWatched,
              tooltip: _isWatched ? 'Mark as unwatched' : 'Mark as watched',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEntryImage() {
    final thumbUrl = widget.anime.mediumImageUrl ?? widget.anime.imageUrl;
    if (thumbUrl == null || thumbUrl.isEmpty) {
      return const Icon(Icons.tv, color: Colors.grey);
    }
    return Image.network(thumbUrl, fit: BoxFit.cover);
  }
}

class _FormatBadge extends StatelessWidget {
  final String format;

  const _FormatBadge({required this.format});

  static String _getFormatText(String format) {
    final normalized = format.toUpperCase();
    switch (normalized) {
      case 'TV':
        return 'TV Series';
      case 'TV_SHORT':
        return 'Short';
      case 'MOVIE':
        return 'Movie';
      case 'OVA':
        return 'OVA';
      case 'ONA':
        return 'ONA';
      case 'SPECIAL':
        return 'Special';
      default:
        return normalized;
    }
  }

  static Color _getFormatColor(String format) {
    final normalized = format.toUpperCase();
    switch (normalized) {
      case 'TV':
      case 'TV_SHORT':
        return const Color(0xFF2E6FD8);
      case 'MOVIE':
        return const Color(0xFF6B4CD6);
      case 'OVA':
        return const Color(0xFF2A9D5B);
      case 'ONA':
      case 'SPECIAL':
        return const Color(0xFF2E8D8D);
      default:
        return const Color(0xFF6F6F6F);
    }
  }

  @override
  Widget build(BuildContext context) {
    final normalized = format.toUpperCase();
    final bg = _getFormatColor(format);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        normalized,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _FranchiseCarousel extends StatelessWidget {
  final List<Anime> entries;

  const _FranchiseCarousel({required this.entries});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: entries.length,
        itemBuilder: (context, index) {
          return _FranchiseCarouselCard(anime: entries[index]);
        },
      ),
    );
  }
}

class _FranchiseCarouselCard extends StatefulWidget {
  final Anime anime;

  const _FranchiseCarouselCard({required this.anime});

  @override
  State<_FranchiseCarouselCard> createState() => _FranchiseCarouselCardState();
}

class _FranchiseCarouselCardState extends State<_FranchiseCarouselCard> {
  late bool _isWatched;

  @override
  void initState() {
    super.initState();
    _loadWatchedStatus();
  }

  void _loadWatchedStatus() async {
    final watchedBox = Hive.box<int>('anime_watched_collection_id');
    final isWatched = watchedBox.containsKey(widget.anime.id);
    if (mounted) {
      setState(() {
        _isWatched = isWatched;
      });
    }
  }

  void _toggleWatched() async {
    setState(() {
      _isWatched = !_isWatched;
    });

    try {
      if (_isWatched) {
        await CollectionsService.instance.addAnimeToWatched(
          widget.anime,
          removeFromWishlist: true,
        );
      } else {
        await CollectionsService.instance.removeAnimeFromWatched(widget.anime);
      }
    } catch (e, st) {
      debugPrint('Failed to toggle watched status: $e\n$st');
      setState(() {
        _isWatched = !_isWatched;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 10),
      child: Material(
        elevation: 3,
        borderRadius: BorderRadius.circular(12),
        shadowColor: Colors.black.withOpacity(0.15),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      child: Container(
                        color: Colors.grey.shade300,
                        width: double.infinity,
                        height: double.infinity,
                        child: _buildEntryImage(),
                      ),
                    ),
                    Positioned(
                      bottom: 6,
                      right: 6,
                      child: GestureDetector(
                        onTap: _toggleWatched,
                        child: Container(
                          decoration: BoxDecoration(
                            color: _isWatched
                                ? Colors.green.withOpacity(0.9)
                                : Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(5),
                          child: Icon(
                            _isWatched ? Icons.check : Icons.add,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.anime.name,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            height: 1.3,
                            color: Color(0xFF1a1a1a),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: _FormatBadge._getFormatColor(widget.anime.format)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _FormatBadge._getFormatText(widget.anime.format),
                          style: TextStyle(
                            fontSize: 9,
                            color:
                                _FormatBadge._getFormatColor(widget.anime.format),
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEntryImage() {
    final thumbUrl = widget.anime.imageUrl ?? widget.anime.mediumImageUrl;
    if (thumbUrl == null || thumbUrl.isEmpty) {
      return const Center(
        child: Icon(Icons.tv, color: Colors.grey),
      );
    }
    return Image.network(
      thumbUrl,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.high,
    );
  }
}



Color? _parseAniListColor(String? hex) {
  if (hex == null || hex.isEmpty) return null;
  final cleaned = hex.replaceAll('#', '');
  if (cleaned.length != 6) return null;
  final value = int.tryParse(cleaned, radix: 16);
  if (value == null) return null;
  return Color(0xFF000000 | value);
}
