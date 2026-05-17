import 'package:hive/hive.dart';

part 'item.g.dart';

@HiveType(typeId: 1)
class Item extends HiveObject {
  @HiveField(0)
  String name;
  @HiveField(1)
  String studio;
  @HiveField(2)
  String? imageUrl;
  @HiveField(3)
  bool owned;
  @HiveField(4) 
  bool wishlist;
  @HiveField(5)
  int yearReleased;
  @HiveField(6)
  int userRating = 0; // User rating out of 10

  Item({
    required this.name, 
    required this.studio, 
    required this.yearReleased, 
    this.imageUrl,
    this.owned = false,
    this.wishlist = false,
  });

  void toggleOwned() {
    owned = !owned;
  }
  void toggleWishlist() {
    wishlist = !wishlist;
  }
  void setUserRating(int rating) {
    if (rating < 0 || rating > 100) {
      throw ArgumentError('Rating must be between 0 and 10');
    }
    userRating = rating;
  }
  
 } 