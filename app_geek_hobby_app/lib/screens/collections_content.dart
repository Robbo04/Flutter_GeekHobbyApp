import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:app_geek_hobby_app/models/item/item.dart';
import 'package:app_geek_hobby_app/models/item/game.dart';
import 'package:app_geek_hobby_app/models/item/movie.dart';
import 'package:app_geek_hobby_app/models/item/anime.dart';
import 'package:app_geek_hobby_app/models/item/show.dart';
import 'package:app_geek_hobby_app/models/group/anime_franchise.dart';
import 'package:app_geek_hobby_app/widgets/detail/game_display.dart';
import 'package:app_geek_hobby_app/widgets/detail/movie_display.dart';
import 'package:app_geek_hobby_app/widgets/detail/show_display.dart';
import 'package:app_geek_hobby_app/screens/item_detail.dart';
import 'package:app_geek_hobby_app/screens/anime_franchise_detail.dart';
import 'package:app_geek_hobby_app/screens/spin_wheel.dart';
import 'package:app_geek_hobby_app/services/anilist_service.dart';

class CollectionsContentPage extends StatefulWidget {
  final List<int> itemIds;
  final String title;

  const CollectionsContentPage({
    super.key,
    required this.itemIds,
    required this.title,
  });

  @override
  State<CollectionsContentPage> createState() => _CollectionsContentPageState();
}

class _CollectionsContentPageState extends State<CollectionsContentPage> {
  int crossAxisCount = 3;
  late List<Item> items;

  @override
  void initState() {
    super.initState();
    final gamesBox = Hive.box<Game>('rawg_games');
    final animeBox = Hive.box<Anime>('anilist_anime');
    
    items = widget.itemIds.map((id) {
      final game = gamesBox.get(id);
      if (game != null) return game;
      
      final anime = animeBox.get(id);
      if (anime != null) return anime;
      
      return null;
    }).whereType<Item>().toList();
  }

  Future<void> _openAnime(Anime anime) async {
    final service = AniListService.instance;
    AnimeFranchise? franchise;

    try {
      final group = await service.getOrFetchAnimeGroup(anime.id);
      if (group != null && mounted) {
        final entries = service.getGroupAnimeList(group.groupId);
        entries.sort((a, b) {
          final yearCmp = a.yearReleased.compareTo(b.yearReleased);
          if (yearCmp != 0) return yearCmp;
          return a.id.compareTo(b.id);
        });
        franchise = AnimeFranchise(
          franchiseId: anime.id,
          primaryAnimeId: anime.id,
          title: anime.name,
          heroTitle: anime.name,
          description: anime.description,
          imageUrl: anime.imageUrl,
          coverColor: anime.coverColor,
          entries: entries.isNotEmpty ? entries : [anime],
          fromExplicitRelations: false,
        );
      }
    } catch (_) {
      // Fall through to single-anime display
    }

    if (!mounted) return;

    if (franchise != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AnimeFranchiseDetailPage(franchise: franchise!),
        ),
      );
    } else {
      // Fallback: build a standalone franchise wrapper
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AnimeFranchiseDetailPage(
            franchise: AnimeFranchise(
              franchiseId: anime.id,
              primaryAnimeId: anime.id,
              title: anime.name,
              heroTitle: anime.name,
              description: anime.description,
              imageUrl: anime.imageUrl,
              coverColor: anime.coverColor,
              entries: [anime],
              fromExplicitRelations: false,
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: const Color.fromARGB(255, 219, 167, 227),
        actions: [
          IconButton(
            icon: Icon(crossAxisCount == 3 ? Icons.grid_on : Icons.grid_view),
            onPressed: () {
              setState(() {
                crossAxisCount = crossAxisCount == 3 ? 6 : 3;
              });
            },
            tooltip: 'Toggle grid size',
          ),
          IconButton(
            icon: Icon(Icons.casino_rounded),
            color: Colors.red,
            tooltip: 'Spin the Wheel',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SpinWheelPage()),
              );
            },
    ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 135 / 190, // width / height ≈ 0.71 for DVD/game box
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return GestureDetector(
            onTap: () {
              if (item is Game) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => GameDisplay(game: item)),
                );
              } else if (item is Movie) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => MovieDisplay(movie: item)),
                );
              } else if (item is Anime) {
                _openAnime(item);
              } else if (item is Show) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ShowDisplay(show: item)),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ItemDetailPage(item: item)),
                );
              }
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: (item.imageUrl != null && item.imageUrl!.isNotEmpty)
                  ? Image.network(item.imageUrl!, fit: BoxFit.cover)
                  : Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, size: 40, color: Colors.grey),
                    ),
            ),
          );
        },
      ),
    );
  }
}

