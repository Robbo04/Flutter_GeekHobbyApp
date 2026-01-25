import 'item.dart';
import 'package:hive/hive.dart';

part 'group_item.g.dart';

@HiveType(typeId: 6)
class GroupItem extends Item {
  @HiveField(7)
  final List<Item> items;

  GroupItem({
    required super.name,
    required super.studio,
    required super.yearReleased,
    super.imageUrl,
    required this.items,
  });
}