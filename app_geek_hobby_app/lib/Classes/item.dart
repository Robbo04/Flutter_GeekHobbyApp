class Item
 {
  String name;
  String studio;
  String? imageUrl;
  bool owned = false;
  bool wishlist = false;
  int yearReleased;
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