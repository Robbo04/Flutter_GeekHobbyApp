import 'package:flutter/material.dart';
import 'package:app_geek_hobby_app/Classes/itemlist.dart';
import 'package:app_geek_hobby_app/Constants/app_spacing.dart';

class CollectionButton extends StatelessWidget {
  final ItemList collectionList; // The first item is the name, the rest are items
  final String imageUrl;
  final VoidCallback? onTap;

  const CollectionButton({
    super.key,
    required this.collectionList,
    required this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String collectionName = collectionList.name;
    final List<String> items = collectionList.items.length > 1 ? collectionList.items.sublist(1).map((item) => item.name).toList() : [];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: AppSpacing.paddingV12,
        padding: AppSpacing.paddingAll16,
        decoration: BoxDecoration(
          color: const Color(0xFF181820),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    collectionName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  AppSpacing.verticalSm,
                  ...items.take(3).map((item) => Text(
                        item,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      )),
                ],
              ),
            ),
            AppSpacing.horizontalLg,
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                width: 120,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 120,
                  height: 80,
                  color: Colors.grey[800],
                  child: const Icon(Icons.image, color: Colors.white, size: 40),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}