import 'package:hive/hive.dart';

part 'media.g.dart';

@HiveType(typeId: 25)
class Media extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String type;

  @HiveField(3)
  String? studioId;

  @HiveField(4)
  String? franchiseId;

  @HiveField(5)
  int releaseYear;

  @HiveField(6)
  String? imageUrl;

  @HiveField(7)
  String? description;

  @HiveField(8)
  List<String> genres;

  @HiveField(9)
  List<String> platforms;

  @HiveField(10)
  DateTime createdAt;

  @HiveField(11)
  DateTime updatedAt;

  Media({
    required this.id,
    required this.title,
    required this.type,
    this.studioId,
    this.franchiseId,
    required this.releaseYear,
    this.imageUrl,
    this.description,
    List<String>? genres,
    List<String>? platforms,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : genres = genres ?? const [],
        platforms = platforms ?? const [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();
}
