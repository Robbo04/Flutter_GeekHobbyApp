import 'package:flutter/material.dart';
import 'package:app_geek_hobby_app/core/constants/app_spacing.dart';

import '../cards/item_carousel_card.dart';

class ItemCarousel extends StatelessWidget {
  final String title;
  final List items;
  final String Function(dynamic) getName;
  final EdgeInsets titlePadding;
  final double carouselHeight;
  final double itemWidth;
  final double itemImageHeight;
  final double itemHorizontalMargin;

  const ItemCarousel({
    super.key,
    required this.title,
    required this.items,
    required this.getName,
    this.titlePadding = AppSpacing.paddingH16,
    this.carouselHeight = 205,
    this.itemWidth = 104,
    this.itemImageHeight = 150,
    this.itemHorizontalMargin = 8,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: titlePadding,
          child: Text(
            title,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Container(
          height: carouselHeight,
          color: const Color(0x00000000),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const ClampingScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return ItemCarouselCard(
                item: items[index],
                getName: getName,
                cardWidth: itemWidth,
                imageHeight: itemImageHeight,
                horizontalMargin: itemHorizontalMargin,
              );
            },
          ),
        ),
      ],
    );
  }
}
