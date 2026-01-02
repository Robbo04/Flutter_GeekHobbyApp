import 'package:app_geek_hobby_app/Classes/game.dart';
import 'package:app_geek_hobby_app/Classes/anime.dart';
import 'package:app_geek_hobby_app/Classes/item.dart';
import 'package:app_geek_hobby_app/Pages/item_detail.dart';
import 'package:flutter/material.dart';
import 'package:app_geek_hobby_app/Services/rawg_service.dart';
import 'package:app_geek_hobby_app/Classes/Widgets/Detail/game_display.dart';
import 'package:app_geek_hobby_app/Classes/Widgets/Detail/anime_display.dart';

class ItemCarouselCard extends StatelessWidget {
  final dynamic item;
  final String Function(dynamic) getName;

  const ItemCarouselCard({
    super.key,
    required this.item,
    required this.getName,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async{
        if (item is Game) {
          final navigator = Navigator.of(context);
          final messenger = ScaffoldMessenger.of(context);

          showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
          try {
            final detailed = await RawgService.instance.fetchGameDetails(item.id);
            
            if (!navigator.mounted) return;
            navigator.pop(); // remove loader
            navigator.push(MaterialPageRoute(builder: (_) => GameDisplay(game: detailed)));
          } catch (e) {
            if (navigator.mounted) navigator.pop();
            messenger.showSnackBar(
              SnackBar(content: Text('Error loading details: $e')),
            );
          }
          return;
        }
        
        if (item is Anime) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AnimeDisplay(anime: item),
            ),
          );
          return;
        }
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ItemDetailPage(item: item),
          ),
        );
      },
      child: Container(
        width: 90,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            Container(
              height: 140,
              width: 90,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                height: 160,
                width: 90,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                  image: item is Item && item.imageUrl != null && item.imageUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(item.imageUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: (item is! Item || item.imageUrl == null || item.imageUrl.isEmpty)
                    ? const Icon(Icons.image, size: 60, color: Colors.grey)
                    : null,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              getName(item),
              style: const TextStyle(fontSize: 14),
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}