import 'package:hive/hive.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 30)
class UserProfile extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String username;

  @HiveField(2)
  String email;

  @HiveField(3)
  String? displayName;

  @HiveField(4)
  String? avatarUrl;

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  DateTime updatedAt;

  UserProfile({
    required this.id,
    required this.username,
    required this.email,
    this.displayName,
    this.avatarUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();
}
