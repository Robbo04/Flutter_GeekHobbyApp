import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 0)
class User {
  @HiveField(0)
  String username;
  @HiveField(1)
  String email;
  @HiveField(2)
  String password; // In a real app, passwords should be hashed and secured

  User({required this.username, required this.email, required this.password});
}