import 'package:hive/hive.dart';

part 'franchise_member.g.dart';

@HiveType(typeId: 27)
class FranchiseMember extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String franchiseId;

  @HiveField(2)
  String mediaId;

  @HiveField(3)
  String role;

  @HiveField(4)
  int order;

  @HiveField(5)
  bool isPrimary;

  FranchiseMember({
    required this.id,
    required this.franchiseId,
    required this.mediaId,
    required this.role,
    this.order = 0,
    this.isPrimary = false,
  });
}
