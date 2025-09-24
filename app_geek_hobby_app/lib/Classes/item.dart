import 'package:flutter/material.dart';

class Item
 {
  String name;
  String studio;
  Image coverImage;
  bool owned = false;
  bool wishlist = false;
  int yearReleased;
  int userRating = 0; // User rating out of 10

  Item({
    required this.name, 
    required this.studio, 
    required this.yearReleased, 
    this.coverImage = const Image(image: AssetImage('assets/placeholder.png')),});

  void toggleOwned() {
    owned = !owned;
  }
  void toggleWishlist() {
    wishlist = !wishlist;
  }
 } 