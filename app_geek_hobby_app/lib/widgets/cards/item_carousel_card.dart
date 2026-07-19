import 'package:flutter/material.dart';

import 'package:app_geek_hobby_app/models/group/anime_franchise.dart';
import 'package:app_geek_hobby_app/models/item/anime.dart';
import 'package:app_geek_hobby_app/models/item/game.dart';
import 'package:app_geek_hobby_app/models/item/item.dart';
import 'package:app_geek_hobby_app/screens/anime_franchise_detail.dart';
import 'package:app_geek_hobby_app/widgets/detail/anime_display.dart';
import 'package:app_geek_hobby_app/widgets/detail/game_display.dart';
import 'package:app_geek_hobby_app/widgets/common/loading_widget.dart';
import 'package:app_geek_hobby_app/screens/item_detail.dart';
import 'package:app_geek_hobby_app/services/rawg_service.dart';

class ItemCarouselCard extends StatelessWidget {
  final dynamic item;
  final String Function(dynamic) getName;
  final double cardWidth;
  final double imageHeight;
  final double horizontalMargin;

  const ItemCarouselCard({
    super.key,
    required this.item,
    required this.getName,
    this.cardWidth = 90,
    this.imageHeight = 140,
    this.horizontalMargin = 8,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        if (item is Game) {
          final navigator = Navigator.of(context);
          final messenger = ScaffoldMessenger.of(context);

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const LoadingWidget(),
          );
          try {
            final detailed = await RawgService.instance.fetchGameDetails(
              item.id,
            );

            if (!navigator.mounted) return;
            navigator.pop(); // remove loader
            navigator.push(
              MaterialPageRoute(builder: (_) => GameDisplay(game: detailed)),
            );
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
            MaterialPageRoute(builder: (context) => AnimeDisplay(anime: item)),
          );
          return;
        }

        if (item is AnimeFranchise) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AnimeFranchiseDetailPage(franchise: item),
            ),
          );
          return;
        }

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ItemDetailPage(item: item)),
        );
      },
      child: Container(
        width: cardWidth,
        margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
        child: Column(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: imageHeight,
                    width: cardWidth,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      border: Border.all(color: Colors.black12),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Image
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            image: _getImageUrl(item) != null
                                ? DecorationImage(
                                    image: NetworkImage(_getImageUrl(item)!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: _getImageUrl(item) == null
                              ? const Icon(
                                  Icons.image,
                                  size: 60,
                                  color: Colors.grey,
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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

  String? _getImageUrl(dynamic value) {
    if (value is AnimeFranchise) {
      if (value.imageUrl != null && value.imageUrl!.isNotEmpty) {
        return value.imageUrl;
      }
      return null;
    }
    if (value is Item) {
      if (value.imageUrl != null && value.imageUrl!.isNotEmpty) {
        return value.imageUrl;
      }
    }
    return null;
  }
}
