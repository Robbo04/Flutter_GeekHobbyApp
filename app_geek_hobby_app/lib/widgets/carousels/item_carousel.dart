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
    this.carouselHeight = 190,
    this.itemWidth = 90,
    this.itemImageHeight = 140,
    this.itemHorizontalMargin = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: titlePadding,
          child: Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          height: carouselHeight,
          color: Colors.transparent,
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
