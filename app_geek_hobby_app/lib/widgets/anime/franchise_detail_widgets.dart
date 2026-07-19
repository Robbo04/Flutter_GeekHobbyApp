import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'package:app_geek_hobby_app/models/group/anime_franchise.dart';
import 'package:app_geek_hobby_app/models/item/anime.dart';
import 'package:app_geek_hobby_app/services/collections_service.dart';
import 'package:app_geek_hobby_app/widgets/common/user_rating_bar.dart';

class AnimeFranchiseHeader extends StatefulWidget {
  final AnimeFranchise franchise;
  final Color tint;
  final bool isWatched;
  final bool isFullyWatched;
  final bool isWishlisted;
  final int rating;
  final int watchedCount;
  final VoidCallback onWishlistChanged;
  final ValueChanged<int> onRatingChanged;

  const AnimeFranchiseHeader({
    super.key,
    required this.franchise,
    required this.tint,
    required this.isWatched,
    required this.isFullyWatched,
    required this.isWishlisted,
    required this.rating,
    required this.watchedCount,
    required this.onWishlistChanged,
    required this.onRatingChanged,
  });

  @override
  State<AnimeFranchiseHeader> createState() => _AnimeFranchiseHeaderState();
}

class _AnimeFranchiseHeaderState extends State<AnimeFranchiseHeader> {
  bool _showRatingSlider = false;

  @override
  void didUpdateWidget(AnimeFranchiseHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isWatched && _showRatingSlider) {
      setState(() => _showRatingSlider = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final heroImage = widget.franchise.imageUrl;
    final progress = widget.franchise.entries.isEmpty
        ? 0.0
        : widget.watchedCount / widget.franchise.entries.length;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFF0F172A),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: heroImage != null && heroImage.isNotEmpty
                ? Image.network(heroImage, fit: BoxFit.cover)
                : Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          widget.tint.withOpacity(0.7),
                          const Color(0xFF0F172A),
                        ],
                      ),
                    ),
                  ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(color: Colors.black.withOpacity(0.34)),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.10),
                    Colors.black.withOpacity(0.66),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _StatusPill(
                      colorA: const Color(0xFF7C3AED),
                      colorB: const Color(0xFF4C1D95),
                      icon: widget.isFullyWatched
                          ? Icons.check_circle
                          : widget.isWatched
                          ? Icons.visibility
                          : Icons.play_circle_outline,
                      text: widget.isFullyWatched
                          ? 'Watched'
                          : widget.isWatched
                          ? 'Watching'
                          : 'Not Started',
                    ),
                    _StatusPill(
                      colorA: const Color(0xFF2563EB),
                      colorB: const Color(0xFF1D4ED8),
                      icon: Icons.video_library_outlined,
                      text:
                          '${widget.watchedCount} / ${widget.franchise.entries.length} Watched',
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 206,
                    height: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.34),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (heroImage != null && heroImage.isNotEmpty)
                            Image.network(heroImage, fit: BoxFit.cover)
                          else
                            Container(color: const Color(0xFF1F2937)),
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.78),
                                  ],
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  12,
                                  18,
                                  12,
                                  12,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      widget.franchise.title,
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 27,
                                        fontWeight: FontWeight.w800,
                                        height: 1.06,
                                      ),
                                    ),
                                    const SizedBox(height: 7),
                                    Text(
                                      '${widget.franchise.entries.length} entries • ${widget.franchise.totalEpisodes} eps',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.85),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    const Text(
                      'Progress',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${widget.watchedCount} of ${widget.franchise.entries.length} episodes',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.88),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: SizedBox(
                    height: 8,
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.white.withOpacity(0.18),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFFA855F7),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _ActionPillButton(
                        icon: widget.isWishlisted
                            ? Icons.bookmark
                            : Icons.bookmark_add_outlined,
                        label: widget.isWishlisted
                            ? 'Wishlisted'
                            : 'Add to List',
                        onPressed: widget.onWishlistChanged,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Opacity(
                        opacity: widget.isWatched ? 1.0 : 0.45,
                        child: _ActionPillButton(
                          icon: Icons.star,
                          label: widget.rating > 0
                              ? '${widget.rating}/100'
                              : 'Rate',
                          iconColor: Colors.amber,
                          onPressed: widget.isWatched
                              ? () => setState(
                                  () => _showRatingSlider = !_showRatingSlider,
                                )
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 250),
                  crossFadeState: _showRatingSlider
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: UserRatingSlider(
                      initialRating: widget.rating,
                      onChanged: widget.onRatingChanged,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final Color colorA;
  final Color colorB;
  final IconData icon;
  final String text;

  const _StatusPill({
    required this.colorA,
    required this.colorB,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: LinearGradient(colors: [colorA, colorB]),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionPillButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? iconColor;
  final VoidCallback? onPressed;

  const _ActionPillButton({
    required this.icon,
    required this.label,
    this.iconColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: Colors.white.withOpacity(0.80),
            border: Border.all(color: Colors.white.withOpacity(0.30)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: iconColor ?? const Color(0xFF0F172A), size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
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

class FranchiseCarousel extends StatelessWidget {
  final List<Anime> entries;
  final Future<void> Function()? onWatchedChanged;

  const FranchiseCarousel({
    super.key,
    required this.entries,
    this.onWatchedChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: entries.length,
        itemBuilder: (context, index) {
          return FranchiseCarouselCard(
            anime: entries[index],
            onWatchedChanged: onWatchedChanged,
          );
        },
      ),
    );
  }
}

class FranchiseCarouselCard extends StatefulWidget {
  final Anime anime;
  final Future<void> Function()? onWatchedChanged;

  const FranchiseCarouselCard({
    super.key,
    required this.anime,
    this.onWatchedChanged,
  });

  @override
  State<FranchiseCarouselCard> createState() => _FranchiseCarouselCardState();
}

class _FranchiseCarouselCardState extends State<FranchiseCarouselCard> {
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
      await widget.onWatchedChanged?.call();
    } catch (e, st) {
      debugPrint('Failed to toggle watched status: $e\n$st');
      setState(() {
        _isWatched = !_isWatched;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Container(
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
                              color: Color(0xFF1A1A1A),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: FormatBadge.getFormatColor(
                              widget.anime.format,
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            FormatBadge.getFormatText(widget.anime.format),
                            style: TextStyle(
                              fontSize: 9,
                              color: FormatBadge.getFormatColor(
                                widget.anime.format,
                              ),
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
      ),
    );
  }

  Widget _buildEntryImage() {
    final thumbUrl = widget.anime.imageUrl ?? widget.anime.mediumImageUrl;
    if (thumbUrl == null || thumbUrl.isEmpty) {
      return const Center(child: Icon(Icons.tv, color: Colors.grey));
    }
    return Image.network(
      thumbUrl,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.high,
    );
  }
}

class FormatBadge extends StatelessWidget {
  final String format;

  const FormatBadge({super.key, required this.format});

  static String getFormatText(String format) {
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

  static Color getFormatColor(String format) {
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
    final bg = getFormatColor(format);

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
