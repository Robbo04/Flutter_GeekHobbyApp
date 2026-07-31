import 'package:app_geek_hobby_app/models/item/anime.dart';
import 'package:app_geek_hobby_app/models/group/anime_group.dart';
import 'package:app_geek_hobby_app/core/constants/app_spacing.dart';
import 'package:app_geek_hobby_app/widgets/common/app_title_text.dart';
import 'package:app_geek_hobby_app/widgets/detail/anime_display.dart';
import 'package:app_geek_hobby_app/widgets/common/error_widget.dart';
import 'package:app_geek_hobby_app/widgets/common/loading_widget.dart';
import 'package:app_geek_hobby_app/services/anilist_service.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class AnimeGroupDetailPage extends StatefulWidget {
  final int animeId; // Can pass any anime ID in the group
  final AnimeGroup? existingGroup; // Optional if already loaded

  const AnimeGroupDetailPage({
    super.key,
    required this.animeId,
    this.existingGroup,
  });

  @override
  State<AnimeGroupDetailPage> createState() => _AnimeGroupDetailPageState();
}

class _AnimeGroupDetailPageState extends State<AnimeGroupDetailPage> {
  final _anilistService = AniListService.instance;
  AnimeGroup? _group;
  List<Anime> _animeList = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadGroup();
  }

  Future<void> _loadGroup() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Use existing group or fetch it
      final group = widget.existingGroup ?? 
                     await _anilistService.getOrFetchAnimeGroup(widget.animeId);

      if (group == null) {
        setState(() {
          _error = 'This anime is not part of a collection';
          _isLoading = false;
        });
        return;
      }

      final animeList = _anilistService.getGroupAnimeList(group.groupId);

      // Sort by year
      animeList.sort((a, b) => a.yearReleased.compareTo(b.yearReleased));

      setState(() {
        _group = group;
        _animeList = animeList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load group: $e';
        _isLoading = false;
      });
    }
  }

  String _getRelationLabel(int animeId) {
    if (_group == null) return '';
    final relationType = _group!.relationTypes[animeId];
    if (relationType == null) return 'Main Series';
    
    switch (relationType) {
      case 'SEQUEL':
        return 'Sequel';
      case 'PREQUEL':
        return 'Prequel';
      case 'SIDE_STORY':
        return 'Side Story';
      case 'PARENT':
        return 'Original';
      case 'ALTERNATIVE':
        return 'Alternative Version';
      default:
        return relationType;
    }
  }

  IconData _getRelationIcon(int animeId) {
    if (_group == null) return Icons.tv;
    final relationType = _group!.relationTypes[animeId];
    
    switch (relationType) {
      case 'SEQUEL':
        return Icons.arrow_forward;
      case 'PREQUEL':
        return Icons.arrow_back;
      case 'SIDE_STORY':
        return Icons.alt_route;
      case 'PARENT':
        return Icons.stars;
      case 'ALTERNATIVE':
        return Icons.swap_horiz;
      default:
        return Icons.tv;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_group?.name ?? 'Anime Collection'),
      ),
      body: _isLoading
          ? const LoadingWidget()
          : _error != null
              ? AppErrorWidget.withRetry(
                  message: _error!,
                  onRetry: () => Navigator.pop(context),
                )
              : ListView(
                  children: [
                    // Header with collection info
                    Container(
                      padding: AppSpacing.paddingAll16Responsive(context),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colorScheme.primary,
                            colorScheme.primary.withOpacity(0.5),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.collections,
                            size: 48,
                            color: colorScheme.onPrimary,
                          ),
                          AppSpacing.verticalSmResponsive(context),
                          Text(
                            _group?.name ?? '',
                            style: textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          AppSpacing.verticalSmResponsive(context),
                          Text(
                            '${_animeList.length} items • ${_group?.getTotalEpisodes(Hive.box<Anime>('anilist_anime')) ?? 0} total episodes',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onPrimary.withOpacity(0.8),
                            ),
                          ),
                          AppSpacing.verticalXsResponsive(context),
                          Text(
                            '${_group?.studio ?? ''} • ${_group?.yearReleased ?? ''}+',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onPrimary.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // List of anime in the collection
                    Padding(
                      padding: AppSpacing.paddingAll16Responsive(context),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Collection Items',
                            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          AppSpacing.verticalMdResponsive(context),
                          ..._animeList.map((anime) => _buildAnimeCard(anime)),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildAnimeCard(Anime anime) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final relationLabel = _getRelationLabel(anime.id);
    final relationIcon = _getRelationIcon(anime.id);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AnimeDisplay(anime: anime),
            ),
          );
        },
        child: Padding(
          padding: AppSpacing.paddingAll12Responsive(context),
          child: Row(
            children: [
              // Image
              Container(
                width: 60,
                height: 90,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                  image: anime.imageUrl != null && anime.imageUrl!.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(anime.imageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: anime.imageUrl == null || anime.imageUrl!.isEmpty
                    ? Icon(
                        Icons.tv,
                        size: 30,
                        color: colorScheme.onSurfaceVariant,
                      )
                    : null,
              ),
              AppSpacing.horizontalMdResponsive(context),
              
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppTitleText(
                      anime.name,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                      maxLines: 2,
                    ),
                    AppSpacing.verticalXsResponsive(context),
                    Row(
                      children: [
                        Icon(
                          relationIcon,
                          size: 14,
                          color: colorScheme.secondary,
                        ),
                        AppSpacing.horizontalXsResponsive(context),
                        Text(
                          relationLabel,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    AppSpacing.verticalXsResponsive(context),
                    Text(
                      '${anime.episodes} episodes • ${anime.yearReleased}',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (anime.isMovie)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.tertiaryContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'MOVIE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onTertiaryContainer,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              
              Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
