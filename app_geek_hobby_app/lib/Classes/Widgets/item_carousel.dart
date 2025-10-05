import 'package:flutter/material.dart';

import 'package:app_geek_hobby_app/Pages/item_detail.dart';
import 'package:app_geek_hobby_app/Classes/game.dart';

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
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ItemDetailPage(item: items[index]),
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
                            image: items[index] is Game && items[index].imageUrl != null && items[index].imageUrl.isNotEmpty
                                ? DecorationImage(
                                    image: NetworkImage(items[index].imageUrl),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                        ),
                        child: (items[index] is! Game || items[index].imageUrl == null || items[index].imageUrl.isEmpty)
                            ? const Icon(Icons.image, size: 60, color: Colors.grey)
                            : null,
                      ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        getName(items[index]),
                        style: const TextStyle(fontSize: 14),
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

