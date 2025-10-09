import 'package:flutter/material.dart';

import 'item_carousel_card.dart';

class ItemCarousel extends StatelessWidget {
  final String title;
  final List items;
  final String Function(dynamic) getName;

  const ItemCarousel({
    super.key,
    required this.title,
    required this.items,
    required this.getName,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          height: 190,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (context, index) {
              return ItemCarouselCard(
                item: items[index],
                getName: getName,
              );
            },
          ),
        ),
      ],
    );      
  }
}

