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
        Container(
          height: 190,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: _getGradientColors(),
              stops: const [0.0, 0.3, 0.7, 1.0],
            ),
          ),
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

  // Get gradient colors for carousel background based on item type
  List<Color> _getGradientColors() {
    if (items.isEmpty) {
      return [
        Colors.transparent,
        Colors.transparent,
        Colors.transparent,
        Colors.transparent,
      ];
    }

    final firstItem = items.first;
    
    // Check item type from the actual classes
    final String itemType = firstItem.runtimeType.toString();
    
    if (itemType == 'Game') {
      // Blue gradient for games
      return [
        const Color(0xFF5E72E4).withOpacity(0.5),
        const Color(0xFF5E72E4).withOpacity(0.15),
        const Color(0xFF5E72E4).withOpacity(0.15),
        const Color(0xFF5E72E4).withOpacity(0.05),
      ];
    } else if (itemType == 'Anime') {
      // Pink gradient for anime
      return [
        const Color(0xFFFF6B9D).withOpacity(0.5),
        const Color(0xFFFF6B9D).withOpacity(0.15),
        const Color(0xFFFF6B9D).withOpacity(0.15),
        const Color(0xFFFF6B9D).withOpacity(0.05),
      ];
    }
    
    return [
      Colors.grey.withOpacity(0.05),
      Colors.grey.withOpacity(0.1),
      Colors.grey.withOpacity(0.1),
      Colors.grey.withOpacity(0.05),
    ];
  }
}

