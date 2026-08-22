import 'package:hive/hive.dart';

part 'franchise.g.dart';

@HiveType(typeId: 26)
class Franchise extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String? description;

  @HiveField(3)
  String? coverImageUrl;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  DateTime updatedAt;

  Franchise({
    required this.id,
    required this.name,
    this.description,
    this.coverImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();
}
