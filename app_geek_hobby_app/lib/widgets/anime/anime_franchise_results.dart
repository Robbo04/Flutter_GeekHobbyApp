import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'package:app_geek_hobby_app/models/group/anime_franchise.dart';
import 'package:app_geek_hobby_app/screens/anime_franchise_detail.dart';
import 'package:app_geek_hobby_app/services/collections_service.dart';

class AnimeFranchiseResults extends StatelessWidget {
  final List<AnimeFranchise> franchises;
  final String query;
  final String? sectionTitle;

  const AnimeFranchiseResults({
    super.key,
    required this.franchises,
    this.query = '',
    this.sectionTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          sectionTitle ?? 'Anime Franchises - "$query"',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ...franchises.map((franchise) => _FranchiseCard(franchise: franchise)),
      ],
    );
  }
}

class _FranchiseCard extends StatefulWidget {
  final AnimeFranchise franchise;

  const _FranchiseCard({required this.franchise});

  @override
  State<_FranchiseCard> createState() => _FranchiseCardState();
}

class _FranchiseCardState extends State<_FranchiseCard> {
  late bool _isFranchiseWatched;
  late bool _isFranchiseWishlisted;
  int _watchedCount = 0;

  @override
  void initState() {
    super.initState();
    _loadCollectionStatus();
  }

  void _loadCollectionStatus() {
    final watchedBox = Hive.box<int>('anime_watched_collection_id');
    // Individual progress bar count
    int watchedCount = 0;
    for (final anime in widget.franchise.entries) {
      if (watchedBox.containsKey(anime.id)) {
        watchedCount++;
      }
    }
    // Franchise-level state uses only the primary anime ID
    final isFranchiseWatched = watchedBox.containsKey(widget.franchise.primaryAnimeId);

    final wishlistBox = Hive.box<int>('anime_wishlist_collection_id');
    final isFranchiseWishlisted = wishlistBox.containsKey(widget.franchise.primaryAnimeId);

    if (mounted) {
      setState(() {
        _watchedCount = watchedCount;
        _isFranchiseWatched = isFranchiseWatched;
        _isFranchiseWishlisted = isFranchiseWishlisted;
      });
    }
  }

  Future<void> _toggleFranchiseWatched() async {
    final newWatchedState = !_isFranchiseWatched;
    setState(() {
      _isFranchiseWatched = newWatchedState;
      if (newWatchedState) _isFranchiseWishlisted = false;
    });

    final primaryAnime = widget.franchise.entries.where(
      (e) => e.id == widget.franchise.primaryAnimeId,
    ).firstOrNull ?? widget.franchise.entries.firstOrNull;

    if (primaryAnime == null) return;

    try {
      if (newWatchedState) {
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

    final primaryAnime = widget.franchise.entries.where(
      (e) => e.id == widget.franchise.primaryAnimeId,
    ).firstOrNull ?? widget.franchise.entries.firstOrNull;

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

  @override
  Widget build(BuildContext context) {
    final tint =
        _parseAniListColor(widget.franchise.coverColor) ?? const Color(0xFF1F7A8C);
    final cleanedTitle = _cleanMasterTitle(widget.franchise.title);
    final progressPercent = widget.franchise.entries.isEmpty
        ? 0.0
        : _watchedCount / widget.franchise.entries.length;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AnimeFranchiseDetailPage(franchise: widget.franchise),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [tint.withOpacity(0.2), Colors.white],
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  _HeroImage(url: widget.franchise.imageUrl),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cleanedTitle,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.franchise.entries.length > 1
                              ? '${widget.franchise.entries.length} entries • ${widget.franchise.totalEpisodes} total eps'
                              : 'Standalone',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          _isFranchiseWatched
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          color: _isFranchiseWatched ? Colors.green : Colors.grey,
                        ),
                        onPressed: _toggleFranchiseWatched,
                        tooltip: _isFranchiseWatched
                            ? 'Mark all as unwatched'
                            : 'Mark all as watched',
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(8),
                      ),
                      IconButton(
                        icon: Icon(
                          _isFranchiseWishlisted
                              ? Icons.bookmark
                              : Icons.bookmark_outline,
                          color: _isFranchiseWishlisted
                              ? Colors.blue
                              : Colors.grey,
                        ),
                        onPressed: _toggleFranchiseWishlist,
                        tooltip: _isFranchiseWishlisted
                            ? 'Remove from wishlist'
                            : 'Add to wishlist',
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(8),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SizedBox(
                  height: 6,
                  child: LinearProgressIndicator(
                    value: progressPercent,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      tint.withOpacity(0.7),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$_watchedCount/${widget.franchise.entries.length} watched',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _cleanMasterTitle(String title) {
  return title
      .replaceAll(
        RegExp(
          r'\b(season|part|cour|arc|chapter)\s*\d+\b',
          caseSensitive: false,
        ),
        '',
      )
      .replaceAll(
        RegExp(r'\b(season|part|cour|arc|chapter)\b', caseSensitive: false),
        '',
      )
      .replaceAll(RegExp(r'\s*[-:|]\s*', caseSensitive: false), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

class _HeroImage extends StatelessWidget {
  final String? url;

  const _HeroImage({required this.url});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 48,
        height: 70,
        color: Colors.grey.shade300,
        child: (url != null && url!.isNotEmpty)
            ? Image.network(url!, fit: BoxFit.cover)
            : const Icon(Icons.movie_creation_outlined, color: Colors.grey),
      ),
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
