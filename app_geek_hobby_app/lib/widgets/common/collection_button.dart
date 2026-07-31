import 'package:flutter/material.dart';
import 'package:app_geek_hobby_app/models/collection/itemlist.dart';
import 'package:app_geek_hobby_app/core/constants/app_spacing.dart';

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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final String collectionName = collectionList.name;
    final List<String> items = collectionList.items.length > 1 ? collectionList.items.sublist(1).map((item) => item.name).toList() : [];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: AppSpacing.paddingV12,
        padding: AppSpacing.paddingAll16,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh,
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
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  AppSpacing.verticalSm,
                  ...items.take(3).map((item) => Text(
                        item,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                  color: colorScheme.surfaceContainerHighest,
                  child: Icon(
                    Icons.image,
                    color: colorScheme.onSurfaceVariant,
                    size: 40,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}