import 'package:app_geek_hobby_app/Classes/show.dart';
import 'package:flutter/material.dart';
import 'package:app_geek_hobby_app/Constants/app_spacing.dart';
import 'package:app_geek_hobby_app/Classes/Widgets/Detail/item_display.dart';

class ShowDisplay extends StatefulWidget {
  final Show show;

  const ShowDisplay({super.key, required this.show});

  @override
  State<ShowDisplay> createState() => _ShowDisplayState();
}

class _ShowDisplayState extends State<ShowDisplay> {
  late bool owned;
  late bool wishlisted;
  late int userRating;

  @override
  void initState() {
    super.initState();
    owned = widget.show.owned;
    wishlisted = widget.show.wishlist;
    userRating = widget.show.userRating;
  }

  void updateOwned(bool value) async {
    setState(() {
      owned = value;
      if (owned) wishlisted = false;
      widget.show.owned = owned;
      widget.show.wishlist = wishlisted;
    });
    await widget.show.save();
  }

  void updateWishlist(bool value) async {
    setState(() {
      wishlisted = value;
      widget.show.wishlist = wishlisted;
    });
    await widget.show.save();
  }

  void updateUserRating(int rating) async {
    setState(() {
      userRating = rating;
      widget.show.userRating = rating;
    });
    await widget.show.save();
  }

  @override
  Widget build(BuildContext context) {
    return ItemDisplay(
      title: "Show details",
      imageUrl: widget.show.imageUrl,
      details: [
        Text(widget.show.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        AppSpacing.verticalLg,
        Text(widget.show.studio, style: const TextStyle(fontSize: 16)),
        Text(widget.show.yearReleased.toString(), style: const TextStyle(fontSize: 16)),
        Text("Runtime: ${widget.show.runtime} minutes", style: const TextStyle(fontSize: 16)),
        Text("Age Rating: ${widget.show.ageRating}", style: const TextStyle(fontSize: 16)),
        Text("Genres: ${widget.show.genres.map((g) => g.toString().split('.').last).join(', ')}", style: const TextStyle(fontSize: 16)),
      ],
      owned: owned,
      wishlisted: wishlisted,
      onOwnedChanged: updateOwned,
      onWishlistChanged: updateWishlist,
      userRating: userRating,
      onUserRatingChanged: updateUserRating,
    );
  }
}