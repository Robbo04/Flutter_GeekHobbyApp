import 'package:hive/hive.dart';

part 'game_age.g.dart';

@HiveType(typeId: 21)
enum GameAge {
  @HiveField(0)
  pegi3,   // Suitable for all ages
  @HiveField(1)
  pegi7,   // Suitable for ages 7+
  @HiveField(2)
  pegi12,  // Suitable for ages 12+
  @HiveField(3)
  pegi16,  // Suitable for ages 16+
  @HiveField(4)
  pegi18,  // Suitable for adults only
}