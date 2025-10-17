import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:app_geek_hobby_app/Classes/item.dart';
import 'package:app_geek_hobby_app/Classes/game.dart'; // If you want to use Game-specific fields
import 'package:app_geek_hobby_app/Classes/movie.dart';
import 'package:app_geek_hobby_app/Classes/anime.dart';
import 'package:app_geek_hobby_app/Classes/show.dart';
import 'package:app_geek_hobby_app/Classes/Widgets/Detail/game_display.dart';
import 'package:app_geek_hobby_app/Classes/Widgets/Detail/movie_display.dart';
import 'package:app_geek_hobby_app/Classes/Widgets/Detail/anime_display.dart';
import 'package:app_geek_hobby_app/Classes/Widgets/Detail/show_display.dart';
import 'package:app_geek_hobby_app/Pages/item_detail.dart';

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
    // Fetch items from the main box using the IDs
    final gamesBox = Hive.box<Game>('rawg_games');
    items = widget.itemIds
        .map((id) => gamesBox.get(id))
        .whereType<Item>()
        .toList();
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
              // Navigate to the correct detail page based on the item's runtime type
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AnimeDisplay(anime: item)),
                );
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

