import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'package:app_geek_hobby_app/core/constants/app_spacing.dart';
import 'package:app_geek_hobby_app/models/group/anime_franchise.dart';
import 'package:app_geek_hobby_app/screens/anime_franchise_detail.dart';
import 'package:app_geek_hobby_app/services/collections_service.dart';
import 'package:app_geek_hobby_app/widgets/common/app_title_text.dart';

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
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTitleText(
          sectionTitle ?? 'Anime Franchises - "$query"',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          maxLines: 2,
        ),
        AppSpacing.verticalResponsive(context, AppSpacing.sm + 2),
        SizedBox(
          height: 206,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemCount: franchises.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              return SizedBox(
                width: 120,
                child: _FranchiseCard(franchise: franchises[index]),
              );
            },
          ),
        ),
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
  final GlobalKey _cardKey = GlobalKey();
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

  Future<void> _showCollectionMenu() async {
    final cardRenderObject = _cardKey.currentContext?.findRenderObject();
    final overlayRenderObject = Overlay.of(context).context.findRenderObject();
    if (cardRenderObject is! RenderBox || overlayRenderObject is! RenderBox) {
      return;
    }

    final globalPosition = cardRenderObject.localToGlobal(
      cardRenderObject.size.center(Offset.zero),
    );
    final overlaySize = overlayRenderObject.size;
    final colorScheme = Theme.of(context).colorScheme;
    final selection = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        globalPosition.dx,
        globalPosition.dy,
        overlaySize.width - globalPosition.dx,
        overlaySize.height - globalPosition.dy,
      ),
      items: [
        PopupMenuItem(
          value: 'watched',
          child: Row(
            children: [
              Icon(
                _isFranchiseWatched
                    ? Icons.remove_circle_outline
                    : Icons.add_circle_outline,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Text(_isFranchiseWatched
                  ? 'Remove from watched'
                  : 'Add to watched'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'wishlist',
          child: Row(
            children: [
              Icon(
                _isFranchiseWishlisted
                    ? Icons.bookmark_remove_outlined
                    : Icons.bookmark_add_outlined,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Text(_isFranchiseWishlisted
                  ? 'Remove from wishlist'
                  : 'Add to wishlist'),
            ],
          ),
        ),
      ],
    );

    if (!mounted) return;
    switch (selection) {
      case 'watched':
        await _toggleFranchiseWatched();
      case 'wishlist':
        await _toggleFranchiseWishlist();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final tint =
        _parseAniListColor(widget.franchise.coverColor) ?? const Color(0xFF1F7A8C);
    final cleanedTitle = _cleanMasterTitle(widget.franchise.title);
    final progressPercent = widget.franchise.entries.isEmpty
        ? 0.0
        : _watchedCount / widget.franchise.entries.length;

    return Card(
      key: _cardKey,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onLongPress: _showCollectionMenu,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AnimeFranchiseDetailPage(franchise: widget.franchise),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                tint.withOpacity(0.14),
                colorScheme.surface,
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 104,
                child: Stack(
                  children: [
                    _HeroImage(url: widget.franchise.imageUrl),
                    Positioned(
                      left: 0,
                      top: 0,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomRight: Radius.circular(8),
                        ),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.scrim.withValues(alpha: 0.56),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.18),
                              ),
                              borderRadius: const BorderRadius.only(
                                bottomRight: Radius.circular(8),
                              ),
                            ),
                            child: Text(
                              '$_watchedCount / ${widget.franchise.entries.length}',
                              style: textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              AppTitleText(
                cleanedTitle,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1.15,
                  fontSize: 15,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: SizedBox(
                  height: 4,
                  child: LinearProgressIndicator(
                    value: progressPercent,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      tint.withOpacity(0.7),
                    ),
                  ),
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
    final colorScheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 104,
        height: 130,
        child: Container(
          color: colorScheme.surfaceContainerHighest,
          child: (url != null && url!.isNotEmpty)
              ? Image.network(url!, fit: BoxFit.cover)
              : Icon(
                  Icons.movie_creation_outlined,
                  color: colorScheme.onSurfaceVariant,
                ),
        ),
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
