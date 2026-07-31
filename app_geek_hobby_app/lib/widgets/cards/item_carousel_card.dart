import 'package:flutter/material.dart';

import 'package:app_geek_hobby_app/models/group/anime_franchise.dart';
import 'package:app_geek_hobby_app/models/item/anime.dart';
import 'package:app_geek_hobby_app/models/item/game.dart';
import 'package:app_geek_hobby_app/models/item/item.dart';
import 'package:app_geek_hobby_app/screens/anime_franchise_detail.dart';
import 'package:app_geek_hobby_app/widgets/detail/anime_display.dart';
import 'package:app_geek_hobby_app/widgets/detail/game_display.dart';
import 'package:app_geek_hobby_app/widgets/common/app_title_text.dart';
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final title = getName(item);
    final nameFontSize = (cardWidth * 0.13).clamp(11.0, 13.0);

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
                      color: colorScheme.surfaceContainerHighest,
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Image
                        Container(
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            image: _getImageUrl(item) != null
                                ? DecorationImage(
                                    image: NetworkImage(_getImageUrl(item)!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: _getImageUrl(item) == null
                              ? Icon(
                                  Icons.image,
                                  size: 60,
                                  color: colorScheme.onSurfaceVariant,
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
            AppTitleText(
              title,
              style: textTheme.bodySmall?.copyWith(
                fontSize: nameFontSize,
                fontWeight: FontWeight.w600,
                height: 1.18,
              ),
              maxLines: 3,
              textAlign: TextAlign.center,
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
