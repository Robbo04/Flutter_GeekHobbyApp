import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'package:app_geek_hobby_app/core/utils/text_formatter.dart';
import 'package:app_geek_hobby_app/models/group/anime_franchise.dart';
import 'package:app_geek_hobby_app/models/item/anime.dart';
import 'package:app_geek_hobby_app/services/anilist_service.dart';
import 'package:app_geek_hobby_app/services/collections_service.dart';
import 'package:app_geek_hobby_app/widgets/anime/franchise_detail_widgets.dart';

class AnimeFranchiseDetailPage extends StatefulWidget {
  final AnimeFranchise franchise;

  const AnimeFranchiseDetailPage({super.key, required this.franchise});

  @override
  State<AnimeFranchiseDetailPage> createState() =>
      _AnimeFranchiseDetailPageState();
}

class _AnimeFranchiseDetailPageState extends State<AnimeFranchiseDetailPage> {
  final _aniListService = AniListService.instance;
  late AnimeFranchise _franchise;
  bool _isLoading = true;
  bool _isDescriptionExpanded = false;
  late bool _isFranchiseWatched;
  bool _isFranchiseFullyWatched = false;
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

  Future<void> _loadCollectionStatus() async {
    final watchedBox = Hive.box<int>('anime_watched_collection_id');
    int watchedCount = 0;
    for (final anime in _franchise.entries) {
      if (watchedBox.containsKey(anime.id)) {
        watchedCount++;
      }
    }

    final hasAnyWatched = watchedCount > 0;
    final isFullyWatched =
        _franchise.entries.isNotEmpty &&
        watchedCount == _franchise.entries.length;

    final primaryAnime = _primaryAnimeEntry;
    if (primaryAnime != null) {
      if (hasAnyWatched && !watchedBox.containsKey(primaryAnime.id)) {
        await watchedBox.put(primaryAnime.id, primaryAnime.id);
      } else if (!hasAnyWatched && watchedBox.containsKey(primaryAnime.id)) {
        await watchedBox.delete(primaryAnime.id);
      }
    }

    final wishlistBox = Hive.box<int>('anime_wishlist_collection_id');
    final isFranchiseWishlisted = wishlistBox.containsKey(
      _franchise.primaryAnimeId,
    );

    if (mounted) {
      setState(() {
        _watchedCount = watchedCount;
        _isFranchiseWatched = hasAnyWatched;
        _isFranchiseFullyWatched = isFullyWatched;
        _isFranchiseWishlisted = isFranchiseWishlisted;
        _franchiseRating = _franchise.franchiseRating;
      });
    }
  }

  Future<void> _loadFullInstallments() async {
    try {
      final group = await _aniListService.getOrFetchAnimeGroup(
        widget.franchise.primaryAnimeId,
      );
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
        await _loadCollectionStatus();
        return;
      }
    } catch (_) {
      // Fall back to existing franchise payload.
    }

    if (!mounted) return;
    setState(() => _isLoading = false);
    await _loadCollectionStatus();
  }

  Anime? get _primaryAnimeEntry {
    final matched = _franchise.entries
        .where((e) => e.id == _franchise.primaryAnimeId)
        .firstOrNull;
    return matched ?? _franchise.entries.firstOrNull;
  }

  Future<void> _toggleFranchiseWishlist() async {
    setState(() {
      _isFranchiseWishlisted = !_isFranchiseWishlisted;
    });

    final primaryAnime = _primaryAnimeEntry;
    if (primaryAnime == null) return;

    try {
      if (_isFranchiseWishlisted) {
        await CollectionsService.instance.addAnimeToWishlist(primaryAnime);
      } else {
        await CollectionsService.instance.removeAnimeFromWishlist(primaryAnime);
      }
      await _loadCollectionStatus();
    } catch (e, st) {
      debugPrint('Failed to toggle franchise wishlist: $e\n$st');
      setState(() {
        _isFranchiseWishlisted = !_isFranchiseWishlisted;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update: $e')));
      }
    }
  }

  Future<void> _setFranchiseRating(int rating) async {
    setState(() {
      _franchiseRating = rating;
    });

    final primaryAnime = _primaryAnimeEntry;
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update rating: $e')));
      }
    }
  }

  List<Widget> _buildCategorizedCarousels() {
    final mainSeries = _franchise.entries
        .where(
          (a) =>
              a.format.toUpperCase() == 'TV' ||
              a.format.toUpperCase() == 'TV_SHORT',
        )
        .toList();
    final movies = _franchise.entries
        .where((a) => a.format.toUpperCase() == 'MOVIE')
        .toList();
    final specials = _franchise.entries.where((a) {
      final fmt = a.format.toUpperCase();
      return fmt == 'OVA' || fmt == 'ONA' || fmt == 'SPECIAL';
    }).toList();

    final sections = <Widget>[];

    void addSection(
      String title,
      List<Anime> items, {
      bool addBottomGap = true,
    }) {
      if (items.isEmpty) return;
      sections.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 4, 0, 10),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              letterSpacing: 0.3,
              color: Colors.white,
            ),
          ),
        ),
      );
      sections.add(
        FranchiseCarousel(
          entries: items,
          onWatchedChanged: _loadCollectionStatus,
        ),
      );
      if (addBottomGap) {
        sections.add(const SizedBox(height: 20));
      }
    }

    addSection('Main Series', mainSeries);
    addSection('Movies', movies);
    addSection('Specials', specials, addBottomGap: false);

    return sections;
  }

  @override
  Widget build(BuildContext context) {
    final tint =
        _parseAniListColor(_franchise.coverColor) ?? const Color(0xFF1F7A8C);
    final heroImage = _franchise.imageUrl;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: Text(_franchise.title),
        backgroundColor: Colors.black.withOpacity(0.35),
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Positioned.fill(
                  child: heroImage != null && heroImage.isNotEmpty
                      ? Image.network(heroImage, fit: BoxFit.cover)
                      : Container(color: const Color(0xFF0F172A)),
                ),
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                    child: Container(color: Colors.black.withOpacity(0.35)),
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.18),
                          Colors.black.withOpacity(0.72),
                        ],
                      ),
                    ),
                  ),
                ),
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    AnimeFranchiseHeader(
                      franchise: _franchise,
                      tint: tint,
                      isWatched: _isFranchiseWatched,
                      isFullyWatched: _isFranchiseFullyWatched,
                      isWishlisted: _isFranchiseWishlisted,
                      rating: _franchiseRating,
                      watchedCount: _watchedCount,
                      onWishlistChanged: _toggleFranchiseWishlist,
                      onRatingChanged: _setFranchiseRating,
                    ),
                    const SizedBox(height: 16),
                    if ((_franchise.description ?? '').trim().isNotEmpty) ...[
                      Text(
                        'Description',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Builder(
                        builder: (context) {
                          final normalizedDescription =
                              TextFormatter.normalizeDescription(
                                _franchise.description!,
                              );
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AnimatedSize(
                                duration: const Duration(milliseconds: 180),
                                curve: Curves.easeOut,
                                child: Text(
                                  normalizedDescription,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(color: Colors.white70),
                                  maxLines: _isDescriptionExpanded ? null : 4,
                                  overflow: _isDescriptionExpanded
                                      ? TextOverflow.visible
                                      : TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _isDescriptionExpanded =
                                        !_isDescriptionExpanded;
                                  });
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 0,
                                    vertical: 2,
                                  ),
                                  minimumSize: const Size(0, 0),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                ),
                                child: Text(
                                  _isDescriptionExpanded
                                      ? 'See less'
                                      : 'See more',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white.withOpacity(0.95),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 18),
                    ],
                    ..._buildCategorizedCarousels(),
                  ],
                ),
              ],
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
