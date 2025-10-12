import 'package:app_geek_hobby_app/Classes/game.dart';
import 'package:flutter/material.dart';
import 'package:app_geek_hobby_app/Classes/Widgets/Detail/item_display.dart';

class GameDisplay extends StatefulWidget {
  final Game game;

  const GameDisplay({super.key, required this.game});

  @override
  State<GameDisplay> createState() => _GameDisplayState();
}

class _GameDisplayState extends State<GameDisplay> {
  late bool owned;
  late bool wishlisted;
  late int userRating;

  @override
  void initState() {
    super.initState();
    owned = widget.game.owned;
    wishlisted = widget.game.wishlist;
    userRating = widget.game.userRating;
  }

  void updateOwned(bool value) async {
    setState(() {
      owned = value;
      if (owned) wishlisted = false;
      widget.game.owned = owned;
      widget.game.wishlist = wishlisted;
    });
    await widget.game.save();
  }

  void updateWishlist(bool value) async{
    setState(() {
      wishlisted = value;
      widget.game.wishlist = wishlisted;
    });
    await widget.game.save();
  }

  void updateUserRating(int rating) async {
    setState(() {
      widget.game.userRating = rating;
    });
    await widget.game.save();
  }

  @override
  Widget build(BuildContext context) {
    return ItemDisplay(
      title: "Game details",
      imageUrl: widget.game.imageUrl,
      details: [
        Text(widget.game.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Text(widget.game.studio, style: const TextStyle(fontSize: 16)),
        Text(widget.game.yearReleased.toString(), style: const TextStyle(fontSize: 16)),
        Text("Age Rating: ${widget.game.ageRating}", style: const TextStyle(fontSize: 16)),
        Text("Genres: ${widget.game.genres.map((g) => g.toString().split('.').last).join(', ')}", style: const TextStyle(fontSize: 16)),
        Text("Platforms: ${widget.game.platforms.map((p) => p.toString().split('.').last).join(', ')}", style: const TextStyle(fontSize: 16)),
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