import 'package:flutter/material.dart';

class ItemCarousel extends StatelessWidget {
  final List<String> items;

  const ItemCarousel({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          return Container(
            width: 150,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: Card(
              child: Center(
                child: Text(items[index]),
              ),
            ),
          );
        },
      ),
    );
  }
}
