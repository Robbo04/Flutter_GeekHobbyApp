import 'package:hive/hive.dart';

part 'studio_member.g.dart';

@HiveType(typeId: 29)
class StudioMember extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String studioId;

  @HiveField(2)
  String mediaId;

  @HiveField(3)
  String role;

  @HiveField(4)
  int order;

  @HiveField(5)
  bool isPrimary;

  StudioMember({
    required this.id,
    required this.studioId,
    required this.mediaId,
    required this.role,
    this.order = 0,
    this.isPrimary = false,
  });
}
