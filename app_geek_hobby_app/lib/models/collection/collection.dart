import 'package:hive/hive.dart';

part 'collection.g.dart';

@HiveType(typeId: 32)
class AppCollection extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String userId;

  @HiveField(2)
  String name;

  @HiveField(3)
  String? description;

  @HiveField(4)
  bool isPublic;

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  DateTime updatedAt;

  AppCollection({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    this.isPublic = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();
}
