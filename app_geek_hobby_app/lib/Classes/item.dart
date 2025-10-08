import 'package:hive/hive.dart';

part 'item.g.dart';

@HiveType(typeId: 1)
class Item {
  @HiveField(0)
  String name;
  @HiveField(1)
  String studio;
  @HiveField(2)
  String? imageUrl;
  @HiveField(3)
  bool owned = false;
  @HiveField(4) 
  bool wishlist = false;
  @HiveField(5)
  int yearReleased;
  @HiveField(6)
  int userRating = 0; // User rating out of 10

  Item({
    required this.name, 
    required this.studio, 
    required this.yearReleased, 
    this.imageUrl,
  });

  void toggleOwned() {
    owned = !owned;
  }
  void toggleWishlist() {
    wishlist = !wishlist;
  }
  
 } 