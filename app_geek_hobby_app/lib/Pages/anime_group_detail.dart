import 'package:app_geek_hobby_app/Classes/anime.dart';
import 'package:app_geek_hobby_app/Classes/anime_group.dart';
import 'package:app_geek_hobby_app/Services/anilist_service.dart';
import 'package:app_geek_hobby_app/Classes/Widgets/Detail/anime_display.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: Text(_group?.name ?? 'Anime Collection'),
        backgroundColor: const Color.fromARGB(255, 219, 167, 227),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Go Back'),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView(
                  children: [
                    // Header with collection info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color.fromARGB(255, 219, 167, 227),
                            const Color.fromARGB(255, 219, 167, 227).withOpacity(0.5),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.collections, size: 48, color: Colors.white),
                          const SizedBox(height: 8),
                          Text(
                            _group?.name ?? '',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_animeList.length} items • ${_group?.getTotalEpisodes(Hive.box<Anime>('anilist_anime')) ?? 0} total episodes',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_group?.studio ?? ''} • ${_group?.yearReleased ?? ''}+',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // List of anime in the collection
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Collection Items',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ..._animeList.map((anime) => _buildAnimeCard(anime)),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildAnimeCard(Anime anime) {
    final relationLabel = _getRelationLabel(anime.id);
    final relationIcon = _getRelationIcon(anime.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Image
              Container(
                width: 60,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                  image: anime.imageUrl != null && anime.imageUrl!.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(anime.imageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: anime.imageUrl == null || anime.imageUrl!.isEmpty
                    ? const Icon(Icons.tv, size: 30, color: Colors.grey)
                    : null,
              ),
              const SizedBox(width: 12),
              
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      anime.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(relationIcon, size: 14, color: Colors.purple),
                        const SizedBox(width: 4),
                        Text(
                          relationLabel,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.purple[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${anime.episodes} episodes • ${anime.yearReleased}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
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
                            color: Colors.orange[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'MOVIE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
