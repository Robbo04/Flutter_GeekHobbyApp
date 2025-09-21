class Item
 {
  String name;
  String studio;
  bool owned = false;
  bool wishlist = false;
  int yearReleased;
  int userRating = 0; // User rating out of 10

  Item({required this.name, required this.studio, required this.yearReleased});

  void toggleOwned() {
    owned = !owned;
  }
  void toggleWishlist() {
    wishlist = !wishlist;
  }
 } 