import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'package:app_geek_hobby_app/models/group/anime_franchise.dart';
import 'package:app_geek_hobby_app/models/item/anime.dart';
import 'package:app_geek_hobby_app/services/anilist_service.dart';
import 'package:app_geek_hobby_app/services/collections_service.dart';
import 'package:app_geek_hobby_app/core/utils/text_formatter.dart';

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

  @override
  void initState() {
    super.initState();
    _franchise = widget.franchise;
    _loadFullInstallments();
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
        return;
      }
    } catch (_) {
      // Fall back to existing franchise payload.
    }

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
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
          _Header(franchise: _franchise, tint: tint),
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
          Text(
            'Installments',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          ..._franchise.entries.map(
            (anime) => _FranchiseEntryTile(anime: anime),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final AnimeFranchise franchise;
  final Color tint;

  const _Header({required this.franchise, required this.tint});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [tint.withOpacity(0.22), Colors.white],
        ),
        border: Border.all(color: tint.withOpacity(0.18)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 84,
              height: 120,
              color: Colors.grey.shade300,
              child:
                  (franchise.imageUrl != null && franchise.imageUrl!.isNotEmpty)
                  ? Image.network(franchise.imageUrl!, fit: BoxFit.cover)
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
                  franchise.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${franchise.entries.length} entries',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 3),
                Text(
                  '${franchise.totalEpisodes} total episodes',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
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

  @override
  Widget build(BuildContext context) {
    final normalized = format.toUpperCase();
    final Color bg;

    switch (normalized) {
      case 'TV':
      case 'TV_SHORT':
        bg = const Color(0xFF2E6FD8);
        break;
      case 'MOVIE':
        bg = const Color(0xFF6B4CD6);
        break;
      case 'OVA':
        bg = const Color(0xFF2A9D5B);
        break;
      case 'ONA':
      case 'SPECIAL':
        bg = const Color(0xFF2E8D8D);
        break;
      default:
        bg = const Color(0xFF6F6F6F);
        break;
    }

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



Color? _parseAniListColor(String? hex) {
  if (hex == null || hex.isEmpty) return null;
  final cleaned = hex.replaceAll('#', '');
  if (cleaned.length != 6) return null;
  final value = int.tryParse(cleaned, radix: 16);
  if (value == null) return null;
  return Color(0xFF000000 | value);
}
