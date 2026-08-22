import 'package:hive/hive.dart';

part 'user_media.g.dart';

@HiveType(typeId: 31)
class UserMedia extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String userId;

  @HiveField(2)
  String mediaId;

  @HiveField(3)
  String status;

  @HiveField(4)
  int progress;

  @HiveField(5)
  int? rating;

  @HiveField(6)
  String? notes;

  @HiveField(7)
  DateTime createdAt;

  @HiveField(8)
  DateTime updatedAt;

  UserMedia({
    required this.id,
    required this.userId,
    required this.mediaId,
    required this.status,
    this.progress = 0,
    this.rating,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();
}
