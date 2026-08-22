import 'package:hive/hive.dart';

part 'studio.g.dart';

@HiveType(typeId: 28)
class Studio extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String? country;

  @HiveField(3)
  String? logoUrl;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  DateTime updatedAt;

  Studio({
    required this.id,
    required this.name,
    this.country,
    this.logoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();
}
