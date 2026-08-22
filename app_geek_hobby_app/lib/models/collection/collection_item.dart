import 'package:hive/hive.dart';

part 'collection_item.g.dart';

@HiveType(typeId: 33)
class CollectionItem extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String collectionId;

  @HiveField(2)
  String mediaId;

  @HiveField(3)
  int order;

  @HiveField(4)
  DateTime addedAt;

  CollectionItem({
    required this.id,
    required this.collectionId,
    required this.mediaId,
    this.order = 0,
    DateTime? addedAt,
  }) : addedAt = addedAt ?? DateTime.now();
}
