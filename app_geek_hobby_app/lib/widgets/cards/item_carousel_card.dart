import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:app_geek_hobby_app/models/group/anime_franchise.dart';
import 'package:app_geek_hobby_app/models/item/anime.dart';
import 'package:app_geek_hobby_app/models/item/game.dart';
import 'package:app_geek_hobby_app/models/item/item.dart';
import 'package:app_geek_hobby_app/enums/platforms/game_platform.dart';
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
                        if (item is Game)
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: _buildPlatformFooterStrip(
                              context,
                              item as Game,
                            ),
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

  Widget _buildPlatformFooterStrip(BuildContext context, Game game) {
    final colorScheme = Theme.of(context).colorScheme;
    final opacity = 0.65;
    final uniquePlatforms = game.platforms.toSet().toList();

    if (uniquePlatforms.isEmpty) {
      return const SizedBox.shrink();
    }

    final visible = uniquePlatforms.take(2).toList();
    final hiddenCount = uniquePlatforms.length - visible.length;
    final iconSize = (cardWidth * 0.11).clamp(9.0, 13.0);
    final bubbleSize = (cardWidth * 0.18).clamp(15.0, 20.0);
    final stripHeight = bubbleSize + 8;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(12),
        bottomRight: Radius.circular(12),
      ),
      child: Container(
        height: stripHeight,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.scrim.withOpacity(0.10),
              colorScheme.scrim.withOpacity(0.62),
            ],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            for (var i = 0; i < visible.length; i++) ...[
              if (i > 0) const SizedBox(width: 4),
              Container(
                width: bubbleSize,
                height: bubbleSize,
                decoration: BoxDecoration(
                  color: colorScheme.surface.withOpacity(opacity),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.outlineVariant,
                    width: 0.7,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(3),
                  child: _platformLogoWidget(
                    platform: visible[i],
                    size: iconSize,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
            if (hiddenCount > 0) ...[
              const SizedBox(width: 4),
              Container(
                height: bubbleSize,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  color: colorScheme.surface.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: colorScheme.outlineVariant,
                    width: 0.7,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  '+$hiddenCount',
                  style: TextStyle(
                    fontSize: (cardWidth * 0.09).clamp(9.0, 11.0),
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                    height: 1,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _platformLogoWidget({
    required GamePlatform platform,
    required double size,
    required Color color,
  }) {
    final logoPath = _platformLogoPath(platform);
    if (logoPath == null) {
      return Icon(Icons.devices_other, size: size, color: color);
    }

    return SvgPicture.asset(
      logoPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }

  String? _platformLogoPath(GamePlatform platform) {
    switch (platform) {
      case GamePlatform.pc:
        return 'assets/logos/platforms/Logo_Windows.svg';
      case GamePlatform.playstation:
        return 'assets/logos/platforms/Logo_Playstation.svg';
      case GamePlatform.xbox:
        return 'assets/logos/platforms/Logo_Xbox.svg';
      case GamePlatform.nintendo:
        return 'assets/logos/platforms/Logo_Nintendo.svg';
      case GamePlatform.mobile:
        return null;
      case GamePlatform.vr:
        return 'assets/logos/platforms/Logo_Meta.svg';
      case GamePlatform.other:
        return null;
    }
  }
}
