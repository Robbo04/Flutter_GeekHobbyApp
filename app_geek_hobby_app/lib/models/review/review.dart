import 'package:hive/hive.dart';

part 'review.g.dart';

@HiveType(typeId: 34)
class Review extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String userId;

  @HiveField(2)
  String mediaId;

  @HiveField(3)
  int rating;

  @HiveField(4)
  String? title;

  @HiveField(5)
  String? body;

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  DateTime updatedAt;

  Review({
    required this.id,
    required this.userId,
    required this.mediaId,
    required this.rating,
    this.title,
    this.body,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();
}
